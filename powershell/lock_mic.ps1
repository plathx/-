# 1. Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

$InstallDir = "C:\phwyverysad"
$DownloadUrl = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/lock_mic_volume.zip"

# UI Helper
function Write-Color { param($text, $color) Write-Host $text -ForegroundColor $color }

# Menu
Clear-Host
Write-Color "=== Mic Volume Locker Manager ===" Cyan
Write-Color "1. Install" Green
Write-Color "2. Uninstall" Yellow
$choice = Read-Host "Select Option"

if ($choice -eq '1') {
    New-Item -Path $InstallDir -ItemType Directory -Force | Out-Null
    Write-Color "Downloading files..." Cyan
    Invoke-WebRequest -Uri $DownloadUrl -OutFile "$InstallDir\data.zip"
    Expand-Archive "$InstallDir\data.zip" -DestinationPath $InstallDir -Force
    
    # ย้ายไฟล์จากโฟลเดอร์ย่อยมาที่ Root (สมมติว่าแตกแล้วได้โฟลเดอร์ชื่อ lock_mic_volume)
    $subFolder = Get-ChildItem $InstallDir -Directory | Select-Object -First 1
    Move-Item "$($subFolder.FullName)\*" $InstallDir -Force
    
    Write-Color "Select Volume Lock Level:" Cyan
    Write-Host "1) 100% | 2) 75% | 3) 50% | 4) 25%"
    $vol = Read-Host "Input Number"
    $levels = @("100", "75", "50", "25")
    $selectedPath = "$InstallDir\$($levels[$vol-1])"

    Write-Color "Starting background process..." Green
    Start-Process "$selectedPath\Run_atomatically.bat" -WindowStyle Hidden
    
    # Monitoring
    while (Get-Process "cmd" -ErrorAction SilentlyContinue | Where-Object {$_.Path -like "*$InstallDir*"}) {
        Start-Sleep -Seconds 5
    }
    Remove-Item $InstallDir -Recurse -Force
    Write-Color "Cleanup complete!" Green

} elseif ($choice -eq '2') {
    Write-Color "Uninstalling..." Yellow
    Stop-Process -Name "nircmdc" -Force -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\lock_mic_vol.bat" -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\hide_cmd_window2.vbs" -ErrorAction SilentlyContinue
    Remove-Item "C:\Windows\nircmdc.exe" -ErrorAction SilentlyContinue
    Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\start_lock_mic_vol.bat" -ErrorAction SilentlyContinue
    Write-Color "Uninstalled successfully." Green
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
