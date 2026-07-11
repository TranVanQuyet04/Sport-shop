param(
  [string]$ApiUrl = "",
  [string]$WebUrl = "",
  [switch]$SkipProjectChecks,
  [switch]$SkipAdminUiAudit,
  [switch]$SkipApiSmoke,
  [switch]$RunFullMvpE2E,
  [switch]$RunOrderE2E,
  [switch]$RunAdminOps,
  [switch]$RunBrowserSmoke
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$Failures = New-Object System.Collections.Generic.List[string]

function Import-DotEnv {
  param([string]$Path)

  if (-not (Test-Path $Path)) {
    return
  }

  Get-Content $Path | ForEach-Object {
    $line = $_.Trim()
    if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#") -or -not $line.Contains("=")) {
      return
    }

    $parts = $line.Split("=", 2)
    $key = $parts[0].Trim()
    $value = $parts[1].Trim().Trim('"').Trim("'")
    if ($key -and -not [Environment]::GetEnvironmentVariable($key, "Process")) {
      [Environment]::SetEnvironmentVariable($key, $value, "Process")
    }
  }
}

Import-DotEnv -Path (Join-Path $Root ".env")
if ([string]::IsNullOrWhiteSpace($ApiUrl)) {
  $ApiUrl = if ($env:SPORTSHOP_API_URL) { $env:SPORTSHOP_API_URL } else { "http://localhost:8080/api" }
}
if ([string]::IsNullOrWhiteSpace($WebUrl) -and $env:SPORTSHOP_WEB_URL) {
  $WebUrl = $env:SPORTSHOP_WEB_URL
}

function Run-HarnessStep {
  param(
    [string]$Name,
    [scriptblock]$Action
  )

  Write-Host "[*] $Name" -ForegroundColor Cyan
  try {
    & $Action
    if ($LASTEXITCODE -ne 0) {
      throw "Exit code $LASTEXITCODE"
    }
    Write-Host "[+] $Name passed" -ForegroundColor Green
  } catch {
    Write-Host "[-] $Name failed: $_" -ForegroundColor Red
    $Failures.Add($Name) | Out-Null
  }
}

if (-not $SkipProjectChecks) {
  Run-HarnessStep -Name "Project checks: backend/mobile/frontend" -Action {
    Push-Location $Root
    try {
      powershell -ExecutionPolicy Bypass -File ".\ai-harness\scripts\run-checks.ps1"
    } finally {
      Pop-Location
    }
  }
}

if (-not $SkipAdminUiAudit) {
  Run-HarnessStep -Name "Admin Mobile UI audit + safe retry" -Action {
    Push-Location $Root
    try {
      powershell -ExecutionPolicy Bypass -File ".\ai-harness\scripts\Invoke-AdminMobileUiHarness.ps1" -StrictButtonAudit -ApplySafeFixes -MaxAttempts 2 -RunMobileChecks
    } finally {
      Pop-Location
    }
  }
}

if (-not $SkipApiSmoke) {
  Run-HarnessStep -Name "MVP API smoke: auth + CRUD + role flows" -Action {
    Push-Location $Root
    try {
      $env:SPORTSHOP_API_URL = $ApiUrl
      node ".\ai-harness\scripts\mvp-api-smoke.mjs"
    } finally {
      Pop-Location
    }
  }
}

if ($RunFullMvpE2E) {
  Run-HarnessStep -Name "Full MVP E2E: customer + staff + shipper + admin + guards + settings" -Action {
    Push-Location $Root
    try {
      $env:SPORTSHOP_API_URL = $ApiUrl
      node ".\ai-harness\scripts\full-mvp-e2e-smoke.mjs"
    } finally {
      Pop-Location
    }
  }
}

if ($RunOrderE2E) {
  Run-HarnessStep -Name "Order E2E smoke: customer checkout + staff + shipper + admin verify" -Action {
    Push-Location $Root
    try {
      $env:SPORTSHOP_API_URL = $ApiUrl
      node ".\ai-harness\scripts\order-e2e-smoke.mjs"
    } finally {
      Pop-Location
    }
  }
}

if ($RunAdminOps) {
  Run-HarnessStep -Name "Admin operations smoke: shifts + leave + assignment + delivery report" -Action {
    Push-Location $Root
    try {
      $env:SPORTSHOP_API_URL = $ApiUrl
      node ".\ai-harness\scripts\admin-ops-smoke.mjs"
    } finally {
      Pop-Location
    }
  }
}

if ($RunBrowserSmoke) {
  if ([string]::IsNullOrWhiteSpace($WebUrl)) {
    Write-Host "[!] Browser smoke skipped because -WebUrl was not provided." -ForegroundColor Yellow
  } else {
    Run-HarnessStep -Name "Admin browser smoke" -Action {
      Push-Location $Root
      try {
        $env:SPORTSHOP_API_URL = $ApiUrl
        $env:SPORTSHOP_WEB_URL = $WebUrl
        node ".\ai-harness\scripts\admin-ui-browser-smoke.mjs"
      } finally {
        Pop-Location
      }
    }
    Run-HarnessStep -Name "Customer & Staff browser smoke" -Action {
      Push-Location $Root
      try {
        $env:SPORTSHOP_API_URL = $ApiUrl
        $env:SPORTSHOP_WEB_URL = $WebUrl
        node ".\ai-harness\scripts\customer-staff-ui-browser-smoke.mjs"
      } finally {
        Pop-Location
      }
    }
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "`nFull MVP harness failed:" -ForegroundColor Red
  $Failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host "`nFull MVP harness passed." -ForegroundColor Green
