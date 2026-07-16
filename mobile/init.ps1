# init.ps1 - Script khởi tạo và chạy nhanh dự án Sportswear Shop Mobile (PowerShell)
# Hướng dẫn sử dụng:
#   .\init.ps1          : Hiển thị menu tương tác
#   .\init.ps1 -Restore : Tự động tải dependencies
#   .\init.ps1 -Test    : Chạy bộ kiểm thử (automated tests)
#   .\init.ps1 -Build   : Build file cài đặt APK cho Android
#   .\init.ps1 -Clean   : Dọn dẹp cache và build artifacts

param (
    [switch]$Clean,
    [switch]$Restore,
    [switch]$Test,
    [switch]$Build,
    [switch]$Web,
    [switch]$Analyze,
    [switch]$Help
)

$ErrorActionPreference = "Stop"

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

function Get-MobileDartDefines {
    $defines = @()
    $keys = @(
        "SPORTSHOP_API_URL",
        "SPORTSHOP_AUTH_API_URL",
        "SPORTSHOP_CATALOG_API_URL",
        "SPORTSHOP_ORDER_API_URL",
        "SPORTSHOP_CHAT_API_URL"
    )
    foreach ($key in $keys) {
        $value = [Environment]::GetEnvironmentVariable($key, "Process")
        if ($value) {
            $defines += "--dart-define=$key=$value"
        }
    }
    return $defines
}

function Get-WebPort {
    if ($env:SPORTSHOP_WEB_URL) {
        try {
            return ([Uri]$env:SPORTSHOP_WEB_URL).Port
        } catch {
            return 52777
        }
    }
    return 52777
}

Import-DotEnv -Path (Join-Path (Resolve-Path (Join-Path $PSScriptRoot "..")) ".env")

# Tiêu đề script
function Show-Header {
    Clear-Host
    Write-Host "==========================================================" -ForegroundColor Cyan
    Write-Host "    SPORTSWEAR SHOP SYSTEM - FLUTTER INITIALIZATION       " -ForegroundColor Yellow
    Write-Host "==========================================================" -ForegroundColor Cyan
}

# Kiểm tra môi trường Flutter SDK
function Assert-FlutterEnv {
    Write-Host "[*] Đang kiểm tra môi trường Flutter SDK..." -ForegroundColor Cyan
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        $version = flutter --version | Select-Object -First 1
        Write-Host "[+] Tìm thấy $version" -ForegroundColor Green
    } else {
        Write-Host "[-] Lỗi: Không tìm thấy Flutter SDK trên máy tính này!" -ForegroundColor Red
        Write-Host "    Vui lòng cài đặt Flutter và thêm vào biến môi trường PATH." -ForegroundColor Yellow
        exit 1
    }
}

# Dọn dẹp dự án (Clean)
function Run-Clean {
    Write-Host "[*] Đang dọn dẹp bộ nhớ đệm và file build cũ..." -ForegroundColor Cyan
    flutter clean
    Write-Host "[+] Dọn dẹp hoàn tất!" -ForegroundColor Green
}

# Tải dependencies (Restore)
function Run-Restore {
    Write-Host "[*] Đang tải các thư viện dependencies (flutter pub get)..." -ForegroundColor Cyan
    flutter pub get
    Write-Host "[+] Tải thư viện hoàn tất!" -ForegroundColor Green
}

# Phân tích tĩnh code (Analyze)
function Run-Analyze {
    Write-Host "[*] Đang kiểm tra lỗi cú pháp và linter (flutter analyze)..." -ForegroundColor Cyan
    flutter analyze
    Write-Host "[+] Kiểm tra hoàn tất! Code sạch sẽ." -ForegroundColor Green
}

# Chạy kiểm thử (Test)
function Run-Test {
    Write-Host "[*] Đang chạy bộ test tự động (flutter test)..." -ForegroundColor Cyan
    flutter test
    Write-Host "[+] Chạy test thành công!" -ForegroundColor Green
}

# Build ứng dụng (Build Android APK)
function Run-Build {
    Write-Host "[*] Đang chuẩn bị build file cài đặt Android APK..." -ForegroundColor Cyan
    $defines = Get-MobileDartDefines
    flutter build apk --release --split-per-abi @defines
    Write-Host "[+] Build APK thành công!" -ForegroundColor Green
    Write-Host "    File APK lưu tại: build\app\outputs\flutter-apk\" -ForegroundColor Yellow
}

function Run-Web {
    Write-Host "[*] Đang chạy Flutter web-server với cấu hình từ .env..." -ForegroundColor Cyan
    $defines = Get-MobileDartDefines
    $port = Get-WebPort
    flutter run -d web-server --web-hostname 127.0.0.1 --web-port $port @defines
}

# Hiển thị hướng dẫn
if ($Help) {
    Show-Header
    Write-Host "Các tham số dòng lệnh hỗ trợ:" -ForegroundColor Yellow
    Write-Host "  -Clean   : Xóa thư mục build và cache."
    Write-Host "  -Restore : Tải toàn bộ các thư viện pubspec."
    Write-Host "  -Analyze : Chạy linter phân tích code tĩnh."
    Write-Host "  -Test    : Chạy toàn bộ các file widget/unit test."
    Write-Host "  -Build   : Biên dịch ứng dụng ra file APK release."
    Write-Host "  -Web     : Chạy Flutter web-server, tự lấy cấu hình API/WEB từ .env."
    Write-Host "  -Help    : Hiển thị hướng dẫn này."
    exit 0
}

# Thực thi theo tham số nếu có truyền vào
$hasParams = $Clean -or $Restore -or $Test -or $Build -or $Web -or $Analyze

if ($hasParams) {
    Assert-FlutterEnv
    if ($Clean) { Run-Clean }
    if ($Restore) { Run-Restore }
    if ($Analyze) { Run-Analyze }
    if ($Test) { Run-Test }
    if ($Build) { Run-Build }
    if ($Web) { Run-Web }
    exit 0
}

# Chế độ Menu tương tác (Interactive Mode)
Show-Header
Assert-FlutterEnv

while ($true) {
    Write-Host ""
    Write-Host "Vui lòng chọn thao tác muốn thực hiện:" -ForegroundColor Yellow
    Write-Host "  1) Dọn dẹp dự án (Clean)"
    Write-Host "  2) Tải lại toàn bộ thư viện (Restore - pub get)"
    Write-Host "  3) Phân tích tĩnh code (Analyze)"
    Write-Host "  4) Chạy bộ test tự động (Test)"
    Write-Host "  5) Build ứng dụng Android (Build APK)"
    Write-Host "  6) Chạy Flutter web-server theo .env"
    Write-Host "  7) Thực hiện toàn bộ (Clean -> Restore -> Test -> Build)"
    Write-Host "  q) Thoát"
    Write-Host ""
    
    $choice = Read-Host "Lựa chọn của bạn"
    
    try {
        switch ($choice) {
            "1" { Run-Clean }
            "2" { Run-Restore }
            "3" { Run-Analyze }
            "4" { Run-Test }
            "5" { Run-Build }
            "6" {
                Run-Web
            }
            "7" {
                Run-Clean
                Run-Restore
                Run-Analyze
                Run-Test
                Run-Build
            }
            "q" {
                Write-Host "Cảm ơn bạn đã sử dụng. Hẹn gặp lại!" -ForegroundColor Green
                exit 0
            }
            default {
                Write-Host "Lựa chọn không hợp lệ, vui lòng thử lại." -ForegroundColor Red
            }
        }
    } catch {
        Write-Host "[-] Có lỗi xảy ra trong quá trình thực hiện: $_" -ForegroundColor Red
    }
    
    Write-Host ""
    Read-Host "Ấn Enter để tiếp tục..."
    Show-Header
}
