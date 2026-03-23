# ==========================================
# ขอสิทธิ์ Administrator อัตโนมัติ (จำเป็นสำหรับการเขียนไฟล์ลง Drive C:\Program Files)
# ==========================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ==========================================
# ตั้งค่าระบบพื้นฐานตามเงื่อนไข
# ==========================================
# บังคับใช้ TLS 1.2 เพื่อการเชื่อมต่อที่เสถียรและเร็วขึ้น
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ปิด Progress Bar เพื่อลดการใช้ทรัพยากร UI และทำให้โหลดเร็วขึ้น
$ProgressPreference = 'SilentlyContinue'

$url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/opengl32.dll"

# ฟังก์ชันสำหรับรอการกดปุ่ม Enter
function Wait-ForEnter {
    while ($true) {
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        if ($key.VirtualKeyCode -eq 13) { break } # 13 คือปุ่ม Enter
    }
}

# ฟังก์ชันสำหรับรอการกดปุ่มอะไรก็ได้
function Wait-ForAnyKey {
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ==========================================
# เมนูหลัก
# ==========================================
Clear-Host
Write-Host "กรุณาเลือกคำสั่ง:" -ForegroundColor Cyan
Write-Host "1. Install"
Write-Host "2. Remove"
$mainChoice = Read-Host "เลือก (1 หรือ 2)"

if ($mainChoice -notin @('1','2')) {
    Write-Host "เลือกไม่ถูกต้อง ปิดโปรแกรม..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

# ==========================================
# เมนูย่อย (เลือก Emulator)
# ==========================================
Clear-Host
Write-Host "กรุณาเลือก Emulator:" -ForegroundColor Cyan
Write-Host "1. BlueStacks App Player"
Write-Host "2. MSI App Player x BlueStacks"
$emuChoice = Read-Host "เลือก (1 หรือ 2)"

$targetFolder = ""
if ($emuChoice -eq '1') {
    $targetFolder = "C:\Program Files\BlueStacks_nxt"
} elseif ($emuChoice -eq '2') {
    $targetFolder = "C:\Program Files\BlueStacks_msi5"
} else {
    Write-Host "เลือกไม่ถูกต้อง ปิดโปรแกรม..." -ForegroundColor Red
    Start-Sleep -Seconds 2
    exit
}

$dllPath = "$targetFolder\opengl32.dll"
$exePath = "$targetFolder\HD-Player.exe"

# ==========================================
# Process: 1. Install
# ==========================================
if ($mainChoice -eq '1') {
    Clear-Host
    # ตรวจสอบว่ามีโฟลเดอร์อยู่หรือไม่ ถ้าไม่มีให้สร้าง
    if (!(Test-Path $targetFolder)) {
        New-Item -ItemType Directory -Force -Path $targetFolder | Out-Null
    }

    Write-Host "กำลังดาวน์โหลดไฟล์ opengl32.dll..." -ForegroundColor Yellow
    
    # ใช้ .NET WebClient ดาวน์โหลดไฟล์แบบ Synchronous
    $webClient = New-Object System.Net.WebClient
    try {
        $webClient.DownloadFile($url, $dllPath)
        Write-Host "ดาวน์โหลดและติดตั้งไฟล์เสร็จสิ้น!" -ForegroundColor Green
    } catch {
        Write-Host "เกิดข้อผิดพลาดในการดาวน์โหลด: $($_.Exception.Message)" -ForegroundColor Red
        Wait-ForAnyKey
        exit
    }

    # ตรวจสอบว่า HD-Player.exe ของโฟลเดอร์ที่เลือกเปิดอยู่หรือไม่
    $isRunning = Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exePath }

    if ($isRunning) {
        Write-Host "พบว่าโปรแกรมกำลังทำงานอยู่..." -ForegroundColor Yellow
        Write-Host "กดปุ่ม Enter เพื่อ รีสตาร์ท (บังคับปิด HD-Player.exe และเปิดใหม่)" -ForegroundColor Cyan
        Wait-ForEnter
        
        # บังคับปิดและเปิดใหม่
        Stop-Process -Name "HD-Player" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2 # รอให้โปรแกรมปิดสนิท
        if (Test-Path $exePath) {
            Start-Process -FilePath $exePath
        }
        
        Write-Host "กดปุ่ม ins เพื่อเปิด เมนูมอง" -ForegroundColor Green
    } else {
        Write-Host "กดปุ่ม ins เพื่อเปิด เมนูมอง" -ForegroundColor Green
    }

    Write-Host "`nกดปุ่มอะไรก็ได้ เพื่อปิด powershell หรือ เทอมินอล..." -ForegroundColor Gray
    Wait-ForAnyKey
}

# ==========================================
# Process: 2. Remove
# ==========================================
elseif ($mainChoice -eq '2') {
    Clear-Host
    Write-Host "กำลังดำเนินการลบ..." -ForegroundColor Yellow
    
    # บังคับปิด HD-Player.exe
    Stop-Process -Name "HD-Player" -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 2 # รอให้โปรแกรมปิดสนิท เพื่อไม่ให้ไฟล์ติด Process

    # ลบไฟล์
    if (Test-Path $dllPath) {
        Remove-Item -Path $dllPath -Force
        Write-Host "ลบสำเร็จแล้ว" -ForegroundColor Green
    } else {
        Write-Host "ไม่พบไฟล์ opengl32.dll ในเครื่อง (อาจจะถูกลบไปแล้ว)" -ForegroundColor Yellow
    }

    Write-Host "กดปุ่ม Enter เพื่อ รีสตาร์ท (เปิดโปรแกรมใหม่)" -ForegroundColor Cyan
    Wait-ForEnter
    
    # เปิดโปรแกรมใหม่หลังจากลบ
    if (Test-Path $exePath) {
        Start-Process -FilePath $exePath
    }

    Write-Host "`nกดปุ่มอะไรก็ได้ เพื่อปิด powershell หรือ เทอมินอล..." -ForegroundColor Gray
    Wait-ForAnyKey
}