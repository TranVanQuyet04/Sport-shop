param(
  [int]$MaxLines = 450,
  [int]$TargetLines = 400,
  [string]$BaselineFile = ""
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..\..")
$MobileLib = Join-Path $Root "mobile\lib"
if ([string]::IsNullOrWhiteSpace($BaselineFile)) {
  $BaselineFile = Join-Path $Root "ai-harness\config\mobile-solid-baseline.json"
}

if (-not (Test-Path $MobileLib)) {
  Write-Host "[!] mobile/lib not found, skipping SOLID file-size check" -ForegroundColor Yellow
  exit 0
}

$tooLarge = Get-ChildItem $MobileLib -Recurse -Filter *.dart |
  Where-Object { $_.FullName -notmatch '\\.dart_tool\\|\\build\\' } |
  ForEach-Object {
    $raw = Get-Content -Raw $_.FullName
    [PSCustomObject]@{
      Path = $_.FullName.Replace("$Root\", "")
      Lines = ($raw -split "`r?`n").Count
    }
  } |
  Where-Object { $_.Lines -gt $MaxLines } |
  Sort-Object Lines -Descending

if ($tooLarge.Count -eq 0) {
  Write-Host "[+] Mobile SOLID file-size check passed. No Dart file exceeds $MaxLines lines." -ForegroundColor Green
  exit 0
}

$baselineMap = @{}
if (Test-Path $BaselineFile) {
  try {
    $baseline = Get-Content $BaselineFile -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($item in $baseline.files) {
      $baselineMap[$item.path] = [int]$item.lines
    }
  } catch {
    Write-Host "[-] Mobile SOLID baseline is invalid: $BaselineFile" -ForegroundColor Red
    Write-Host "    $_" -ForegroundColor Red
    exit 1
  }
}

$newDebt = New-Object System.Collections.Generic.List[object]
$grownDebt = New-Object System.Collections.Generic.List[object]
$trackedDebt = New-Object System.Collections.Generic.List[object]

foreach ($item in $tooLarge) {
  $normalizedPath = $item.Path.Replace("\", "/")
  if (-not $baselineMap.ContainsKey($normalizedPath)) {
    $newDebt.Add($item) | Out-Null
    continue
  }

  $baselineLines = [int]$baselineMap[$normalizedPath]
  if ($item.Lines -gt $baselineLines) {
    $grownDebt.Add([PSCustomObject]@{
      Path = $item.Path
      Lines = $item.Lines
      Baseline = $baselineLines
      Growth = $item.Lines - $baselineLines
    }) | Out-Null
  } else {
    $trackedDebt.Add([PSCustomObject]@{
      Path = $item.Path
      Lines = $item.Lines
      Baseline = $baselineLines
    }) | Out-Null
  }
}

if ($newDebt.Count -eq 0 -and $grownDebt.Count -eq 0) {
  Write-Host "[+] Mobile SOLID file-size check passed with tracked debt baseline." -ForegroundColor Green
  Write-Host "    Existing files above $MaxLines lines remain tracked; split them toward $TargetLines lines when touching those areas." -ForegroundColor Yellow
  if ($trackedDebt.Count -gt 0) {
    $trackedDebt | Sort-Object Lines -Descending | Format-Table -AutoSize
  }
  exit 0
}

Write-Host "[-] Mobile SOLID file-size check failed." -ForegroundColor Red
if ($newDebt.Count -gt 0) {
  Write-Host "    New files above $MaxLines lines:" -ForegroundColor Yellow
  $newDebt | Sort-Object Lines -Descending | Format-Table -AutoSize
}
if ($grownDebt.Count -gt 0) {
  Write-Host "    Baseline files grew beyond their tracked line count:" -ForegroundColor Yellow
  $grownDebt | Sort-Object Growth -Descending | Format-Table -AutoSize
}
exit 1
