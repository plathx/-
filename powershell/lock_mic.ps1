# บังคับรันในฐานะ Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
$InstallDir = "C:\phwyverysad"
$ZipPath = "$InstallDir\lock_mic_volume.zip"
# แก้ไขลิงก์โดยใช้การ Encode ตัวอักษรไทยให้เป็นรหัส URL
$Url = [System.Uri]::EscapeUriString("https://github.com/plathx/-/releases/download/จูนคอม/lock_mic_volume.zip")

Function Install-Process {
    Write-Host "Installing..." -ForegroundColor Cyan
    if (!(Test-Path $InstallDir)) { New-Item -Path $InstallDir -ItemType Directory | Out-Null }
    Add-MpPreference -ExclusionPath $InstallDir
    
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($Url, $ZipPath)
        Write-Host "Download Success." -ForegroundColor Green
    } catch {
        Write-Error "Download Failed: $_"
        return
    }
    
    Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
    Remove-Item $ZipPath -ErrorAction SilentlyContinue
    
    # เมนูเลือกความดัง
    Write-Host "`nSelect Microphone Volume Level:"
    $levels = @{"1" = "100%"; "2" = "75%"; "3" = "50%"; "4" = "25%"}
    foreach($key in $levels.Keys) { Write-Host "$key. $($levels[$key])" }
    $choice = Read-Host "Enter choice (1-4)"
    
    # หาโฟลเดอร์ข้างใน (สมมติว่าเป็นโฟลเดอร์ที่แตกออกมา)
    $innerFolder = Get-ChildItem -Path $InstallDir -Directory | Select-Object -First 1
    $runPath = Join-Path $innerFolder.FullName "$($levels[$choice])\Run_atomatically.bat"
    
    if (Test-Path $runPath) {
        Start-Process -FilePath $runPath -WindowStyle Hidden
        Write-Host "Running process in background..." -ForegroundColor Yellow
        
        # ตรวจสอบทุกๆ 5 วิ ว่า nircmdc ปิดหรือยัง
        while (Get-Process "nircmdc" -ErrorAction SilentlyContinue) {
            Start-Sleep -Seconds 5
        }
        
        # ลบโฟลเดอร์เมื่อจบการทำงาน
        Remove-Item $InstallDir -Recurse -Force
        Write-Host "Task finished. Cleanup complete." -ForegroundColor Green
    } else {
        Write-Error "Could not find Run_atomatically.bat at $runPath"
    }
}

Function Uninstall-Process {
    Write-Host "Uninstalling..." -ForegroundColor Yellow
    Stop-Process -Name "nircmdc" -Force -ErrorAction SilentlyContinue
    
    $filesToRemove = @("C:\Windows\lock_mic_vol.bat", "C:\Windows\hide_cmd_window2.vbs", "C:\Windows\nircmdc.exe")
    foreach ($f in $filesToRemove) { if (Test-Path $f) { Remove-Item $f -Force } }
    
    $shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\start_lock_mic_vol.bat"
    if (Test-Path $shortcut) { Remove-Item $shortcut -Force }
    Write-Host "Uninstall Complete." -ForegroundColor Green
}

# เมนูหลัก
Write-Host "--- Main Menu ---"
Write-Host "1. Install"
Write-Host "2. Uninstall"
$opt = Read-Host "Select Option"

switch ($opt) {
    "1" { Install-Process }
    "2" { Uninstall-Process }
    Default { Write-Host "Invalid option" }
}
