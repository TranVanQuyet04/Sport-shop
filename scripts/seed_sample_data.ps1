# ==============================================================================
# SCRIPT: seed_sample_data.ps1
# DESCRIPTION: Automates seeding sample data into all 4 SportSwearShop databases
# USAGE: .\scripts\seed_sample_data.ps1 [-ContainerName <string>] [-Username <string>] [-Password <string>]
# ==============================================================================

param(
    [string]$ContainerName = "sport-swear-shop-postgres",
    [string]$Username = "postgres",
    [string]$Password = "CHANGE_ME_DATABASE_PASSWORD",
    [switch]$LocalPostgres
)

$ErrorActionPreference = "Stop"

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " SPORT SWEAR SHOP - AUTOMATING DATABASE SAMPLE DATA SEEDING" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
$SampleDataDir = Join-Path $ProjectRoot "backend\sample_data"

if (-not (Test-Path $SampleDataDir)) {
    Write-Host "ERROR: Could not find sample_data directory at: $SampleDataDir" -ForegroundColor Red
    exit 1
}

$Databases = @(
    @{ Name = "auth_db"; File = "01_auth_db.sql" },
    @{ Name = "product_catalog_db"; File = "02_product_catalog_db.sql" },
    @{ Name = "order_fulfillment_db"; File = "03_order_fulfillment_db.sql" },
    @{ Name = "support_chat_db"; File = "04_support_chat_db.sql" }
)

if ($LocalPostgres) {
    Write-Host "`n[INFO] Mode: Local PostgreSQL Server ($Username)" -ForegroundColor Yellow
    $env:PGPASSWORD = $Password
    
    # Auto-detect psql command or path
    $psqlCmd = "psql"
    if (-not (Get-Command "psql" -ErrorAction SilentlyContinue)) {
        $foundPsql = Get-ChildItem "C:\Program Files\PostgreSQL\*\bin\psql.exe" -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName
        if ($foundPsql) {
            $psqlCmd = $foundPsql
            Write-Host "[INFO] Auto-detected psql at: $psqlCmd" -ForegroundColor Gray
        } else {
            Write-Host "ERROR: psql not found in PATH or in C:\Program Files\PostgreSQL\*\bin\psql.exe" -ForegroundColor Red
            exit 1
        }
    }

    foreach ($db in $Databases) {
        $filePath = Join-Path $SampleDataDir $db.File
        Write-Host "Seeding database '$($db.Name)' from $($db.File)... " -NoNewline
        try {
            & $psqlCmd -h localhost -p 5432 -U $Username -d $db.Name -f $filePath | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS]" -ForegroundColor Green
            } else {
                Write-Host "[FAILED]" -ForegroundColor Red
            }
        } catch {
            Write-Host "[FAILED]" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
} else {
    Write-Host "`n[INFO] Mode: Docker Container ('$ContainerName')" -ForegroundColor Yellow
    
    # Check if container is running
    $running = docker ps --filter "name=$ContainerName" --format "{{.Names}}"
    if ($running -ne $ContainerName) {
        Write-Host "ERROR: Docker container '$ContainerName' is not running!" -ForegroundColor Red
        Write-Host "Please start your containers first using 'docker-compose up -d'" -ForegroundColor Yellow
        exit 1
    }

    foreach ($db in $Databases) {
        $filePath = Join-Path $SampleDataDir $db.File
        Write-Host "Seeding database '$($db.Name)' from $($db.File)... " -NoNewline
        try {
            Get-Content $filePath -Raw -Encoding UTF8 | docker exec -i $ContainerName psql -U $Username -d $db.Name | Out-Null
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[SUCCESS]" -ForegroundColor Green
            } else {
                Write-Host "[FAILED]" -ForegroundColor Red
            }
        } catch {
            Write-Host "[FAILED]" -ForegroundColor Red
            Write-Host $_.Exception.Message -ForegroundColor Red
        }
    }
}

Write-Host "`n==============================================================================" -ForegroundColor Cyan
Write-Host " All database seeding operations completed!" -ForegroundColor Green
Write-Host "==============================================================================`n" -ForegroundColor Cyan
