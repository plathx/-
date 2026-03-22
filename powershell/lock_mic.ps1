# บังคับรันในฐานะ Administrator
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$InstallDir = "C:\phwyverysad"
$ZipPath = "$InstallDir\lock_mic_volume.zip"
$Url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/lock_mic_volume.zip"

Function Install-Process {
    Write-Host "Installing..." -ForegroundColor Cyan
    if (!(Test-Path $InstallDir)) { New-Item -Path $InstallDir -ItemType Directory | Out-Null }
    Add-MpPreference -ExclusionPath $InstallDir
    
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $wc = New-Object System.Net.WebClient
    $wc.DownloadFile($Url, $ZipPath)
    
    Expand-Archive -Path $ZipPath -DestinationPath $InstallDir -Force
    Remove-Item $ZipPath
    
    # เมนูเลือกความดัง
    Write-Host "Select Microphone Volume Level:"
    $levels = @{"1" = "100%"; "2" = "75%"; "3" = "50%"; "4" = "25%"}
    foreach($key in $levels.Keys) { Write-Host "$key. $($levels[$key])" }
    $choice = Read-Host "Enter choice (1-4)"
    
    $targetFolder = Get-ChildItem -Path $InstallDir -Directory | Select-Object -First 1
    $runPath = Join-Path $targetFolder.FullName "$($levels[$choice])\Run_atomatically.bat"
    
    Start-Process -FilePath $runPath -WindowStyle Hidden
    
    # รอจนกว่า process จะปิด
    while (Get-Process "nircmdc" -ErrorAction SilentlyContinue) {
        Start-Sleep -Seconds 5
    }
    Remove-Item $InstallDir -Recurse -Force
    Write-Host "Installation cleaned up." -ForegroundColor Green
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
Write-Host "1. Install"
Write-Host "2. Uninstall"
$opt = Read-Host "Select Option"

switch ($opt) {
    "1" { Install-Process }
    "2" { Uninstall-Process }
    Default { Write-Host "Invalid option" }
}
