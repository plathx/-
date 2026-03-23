# ==============================================================================
# 1. Administrator Auto-Check (ตรวจสอบและขอสิทธิ์แอดมินอัตโนมัติ)
# ==============================================================================
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process PowerShell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ==============================================================================
# 2. Configuration (ตั้งค่าการทำงาน)
# ==============================================================================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

$DL_URL   = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/opengl32.dll"
$PATH_NXT = "C:\Program Files\BlueStacks_nxt"
$PATH_MSI = "C:\Program Files\BlueStacks_msi5"

# ==============================================================================
# 3. Functions (ฟังก์ชันการทำงาน)
# ==============================================================================

# ฟังก์ชันรีสตาร์ทโปรแกรม
function Restart-Emulator ($dir) {
    $exe = Join-Path $dir "HD-Player.exe"
    $proc = Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exe }
    
    if ($proc) {
        Write-Host "`n[!] ตรวจพบ HD-Player กำลังทำงานอยู่" -ForegroundColor Cyan
        Read-Host "กดปุ่ม Enter เพื่อรีสตาร์ท (บังคับปิดและเปิดใหม่)"
        Stop-Process -Id $proc.Id -Force
        Start-Sleep -Seconds 1
        if (Test-Path $exe) { Start-Process -FilePath $exe }
        Write-Host "[+] กดปุ่ม INS เพื่อเปิด เมนูมอง" -ForegroundColor Green
    } else {
        Write-Host "`n[+] กดปุ่ม INS เพื่อเปิด เมนูมอง" -ForegroundColor Green
    }
}

# ฟังก์ชันปิด PowerShell แบบเบ็ดเสร็จ
function Finalize-Exit {
    Write-Host "`nกดปุ่มอะไรก็ได้เพื่อปิดหน้าต่างนี้..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    Stop-Process -Id $PID -Force
}

# ==============================================================================
# 4. Main Menu & Logic (เมนูหลักและการทำงาน)
# ==============================================================================
Clear-Host
Write-Host "================================" -ForegroundColor Magenta
Write-Host "      MOD INSTALLER CLEAN       "
Write-Host "================================" -ForegroundColor Magenta
Write-Host "1. Install (ติดตั้ง)"
Write-Host "2. Remove (ลบ)"
$cmd = Read-Host "`nเลือกคำสั่ง (1-2)"

if ($cmd -match '1|2') {
    Clear-Host
    Write-Host "--- เลือก Emulator ---" -ForegroundColor Cyan
    Write-Host "1. BlueStacks App Player"
    Write-Host "2. MSI App Player x BlueStacks"
    $emu = Read-Host "เลือกรายการ (1-2)"
    
    $targetDir  = if ($emu -eq '1') { $PATH_NXT } else { $PATH_MSI }
    $targetFile = Join-Path $targetDir "opengl32.dll"
    $exePath    = Join-Path $targetDir "HD-Player.exe"

    # --- โหมดติดตั้ง ---
    if ($cmd -eq '1') {
        if (!(Test-Path $targetDir)) { New-Item -ItemType Directory -Path $targetDir -Force | Out-Null }
        Write-Host "`n[*] กำลังติดตั้ง Mod (TLS 1.2 WebClient)..." -ForegroundColor Yellow
        try {
            (New-Object System.Net.WebClient).DownloadFile($DL_URL, $targetFile)
            Write-Host "[OK] ติดตั้งเสร็จสิ้น!" -ForegroundColor Green
            Restart-Emulator $targetDir
        } catch {
            Write-Host "[ERR] ติดตั้งล้มเหลว: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
    # --- โหมดลบ ---
    else {
        Write-Host "`n[*] กำลังลบ Mod..." -ForegroundColor Yellow
        # บังคับปิดก่อนลบ
        $proc = Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue | Where-Object { $_.Path -eq $exePath }
        if ($proc) { Stop-Process -Id $proc.Id -Force; Start-Sleep -Seconds 1 }
        
        if (Test-Path $targetFile) {
            Remove-Item $targetFile -Force
            Write-Host "[OK] ลบสำเร็จแล้ว!" -ForegroundColor Green
            Read-Host "กดปุ่ม Enter เพื่อรีสตาร์ท"
            if (Test-Path $exePath) { Start-Process $exePath }
        } else {
            Write-Host "[!] ไม่พบไฟล์ในระบบ" -ForegroundColor Red
        }
    }
}

Finalize-Exit
