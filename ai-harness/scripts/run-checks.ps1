param(
  [switch]$BackendOnly,
  [switch]$MobileOnly,
  [switch]$SkipMobileFormat,
  [switch]$SkipSolid,
  [switch]$SkipFrontend
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$Failures = New-Object System.Collections.Generic.List[string]

function Run-Step {
  param(
    [string]$Name,
    [string]$WorkingDirectory,
    [string[]]$Command
  )

  Write-Host "[*] $Name" -ForegroundColor Cyan
  Push-Location $WorkingDirectory
  try {
    & $Command[0] @($Command | Select-Object -Skip 1)
    if ($LASTEXITCODE -ne 0) {
      throw "Exit code $LASTEXITCODE"
    }
    Write-Host "[+] $Name passed" -ForegroundColor Green
  } catch {
    Write-Host "[-] $Name failed: $_" -ForegroundColor Red
    $Failures.Add($Name) | Out-Null
  } finally {
    Pop-Location
  }
}

if (-not $MobileOnly) {
  $backend = Join-Path $Root "backend"
  if (Test-Path (Join-Path $backend "mvnw.cmd")) {
    Run-Step -Name "Backend Maven tests" -WorkingDirectory $backend -Command @(".\mvnw.cmd", "test")
  } elseif (Test-Path (Join-Path $backend "mvnw")) {
    Run-Step -Name "Backend Maven tests" -WorkingDirectory $backend -Command @(".\mvnw", "test")
  } else {
    Write-Host "[!] Backend Maven wrapper not found, skipping" -ForegroundColor Yellow
  }
}

if (-not $BackendOnly) {
  $mobile = Join-Path $Root "mobile"
  if (Test-Path $mobile) {
    if (-not $SkipMobileFormat) {
      Run-Step -Name "Mobile dart format" -WorkingDirectory $mobile -Command @("dart", "format", "lib", "test")
    }
    Run-Step -Name "Mobile Vietnamese text encoding check" -WorkingDirectory $Root -Command @("node", ".\ai-harness\scripts\check-vietnamese-text.mjs")
    if (-not $SkipSolid) {
      Run-Step -Name "Mobile SOLID file-size check" -WorkingDirectory $Root -Command @("powershell", "-ExecutionPolicy", "Bypass", "-File", ".\ai-harness\scripts\check-mobile-solid.ps1")
    }
    Run-Step -Name "Mobile analyze" -WorkingDirectory $mobile -Command @("powershell", "-ExecutionPolicy", "Bypass", "-File", ".\init.ps1", "-Analyze")
    Run-Step -Name "Mobile tests" -WorkingDirectory $mobile -Command @("powershell", "-ExecutionPolicy", "Bypass", "-File", ".\init.ps1", "-Test")
  } else {
    Write-Host "[!] Mobile folder not found, skipping" -ForegroundColor Yellow
  }
}

if (-not $SkipFrontend -and -not $BackendOnly -and -not $MobileOnly) {
  $frontend = Join-Path $Root "frontend"
  if ((Test-Path $frontend) -and (Test-Path (Join-Path $frontend "package.json"))) {
    Run-Step -Name "Frontend npm test/build if present" -WorkingDirectory $frontend -Command @("npm", "run", "build", "--if-present")
  }
}

if ($Failures.Count -gt 0) {
  Write-Host "`nHarness checks failed:" -ForegroundColor Red
  $Failures | ForEach-Object { Write-Host " - $_" -ForegroundColor Red }
  exit 1
}

Write-Host "`nAll enabled StrideX harness checks passed." -ForegroundColor Green
