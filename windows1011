# ==========================================================
# 1. Windows Update Check & Install
# ==========================================================
Write-Host "--- 1. Checking Windows Updates ---" -ForegroundColor Cyan
Install-Module PSWindowsUpdate -Force -SkipPublisherCheck -Scope CurrentUser -ErrorAction SilentlyContinue
Import-Module PSWindowsUpdate
$updates = Get-WindowsUpdate -AcceptAll -Install -AutoReboot:$false

if ($updates) {
    Write-Host "Updates found and installed. You will need to RESTART after all tasks are done." -ForegroundColor Yellow
} else {
    Write-Host "No updates found. Skipping..." -ForegroundColor Green
}

# ==========================================================
# 2. Microsoft Store Check & Re-register
# ==========================================================
Write-Host "`n--- 2. Checking/Refreshing Microsoft Store ---" -ForegroundColor Cyan
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppxManifest.xml"}

# ==========================================================
# 3. Running Remote Scripts (irm | iex)
# ==========================================================
Write-Host "`n--- 3. Running Custom Scripts from GitHub ---" -ForegroundColor Cyan
irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/Install_All.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/idm_build.ps1 | iex

# ==========================================================
# 4. Winget MS Store Installations
# ==========================================================
Write-Host "`n--- 4. Installing Winget Packages ---" -ForegroundColor Cyan
$wingetIds = @("9WZDNCRFHVN5", "9N7JSXC1SJK6", "9N0DX20HK701", "9PCFS5B6T72H", "9WZDNCRFJBH4", "9MZ95KL8MR0L", "9PM860492SZD", "9N0866FS04W8", "9MV0B5HZVK9Z", "XP9KN75RRB9NHS")
foreach ($id in $wingetIds) {
    winget install --id $id --source msstore --accept-package-agreements --accept-source-agreements
}

# ==========================================================
# 5. Local App Installation (Auto & Manual)
# ==========================================================
Write-Host "`n--- 5. Preparing Local Apps ---" -ForegroundColor Cyan
Start-Process "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/allapp.zip"
Read-Host "Press ENTER after download and extracted to '$env:USERPROFILE\Downloads\allapp'"
Set-Location "$env:USERPROFILE\Downloads\allapp"

# --- Auto Install (Silent - รันพร้อมกันหลายหน้าต่าง) ---
$silentApps = @(
    @{ Path = ".\iot_v215.exe"; Args = "/VERYSILENT", "/ALLUSERS", "/SUPPRESSMSGBOXES", "/NORESTART" },
    @{ Path = ".\BraveBrowserSetup-BRV011.exe"; Args = "/silent", "/install" },
    @{ Path = ".\DiscordCanarySetup.exe"; Args = "--silent" },
    @{ Path = ".\DiscordPTBSetup-win64.exe"; Args = "--silent" },
    @{ Path = ".\DiscordSetup.exe"; Args = "--silent" },
    @{ Path = ".\OfficeSetup.exe"; Args = "/configure", "configuration.xml" },
    @{ Path = ".\parsec-windows.exe"; Args = "/S", "/shared", "/accept_eula" },
    @{ Path = ".\SteamSetup.exe"; Args = "/S" },
    @{ Path = ".\st-setup-1.8.30.exe"; Args = "/S", "/silent", "/verysilent" },
    @{ Path = ".\SuperF4-1.4.exe"; Args = "/S" },
    @{ Path = ".\VoiceChanger64(1.98).exe"; Args = "/S" },
    @{ Path = ".\winrar-x64-720_2.exe"; Args = "/S" }
)

foreach ($app in $silentApps) {
    if (Test-Path $app.Path) {
        Write-Host "Launching Auto-Install: $($app.Path)" -ForegroundColor Gray
        Start-Process -FilePath $app.Path -ArgumentList $app.Args -Verb RunAs
    }
}

# --- Manual Install (รันทีละตัว และรอให้กด Enter) ---
$manualApps = @(
    "BlueStacksInstaller_5.22.167.1006_native_c8aef63c82a49115bddb561ec719c800_MzsxNQ==.exe",
    "Fishstrap.exe",
    "Install iCUE.exe",
    "Install VALORANT.exe",
    "NGENUITY_Beta_Installer.exe",
    "Rockstar-Games-Launcher.exe",
    "amd-software-adrenalin-edition-26.3.1-minimalsetup-260317_web.exe"
)

foreach ($mApp in $manualApps) {
    if (Test-Path $mApp) {
        Write-Host "`n[Action Required] Installing: $mApp" -ForegroundColor Yellow
        Start-Process -FilePath $mApp -Wait
        Read-Host "Press ENTER to continue to the next manual installer..."
    }
}

# ==========================================================
# 6. Desktop Specific Installations
# ==========================================================
Write-Host "`n--- 6. Desktop Apps ---" -ForegroundColor Cyan
$deskPath = if (Test-Path "$env:USERPROFILE\OneDrive\Desktop") { "$env:USERPROFILE\OneDrive\Desktop" } else { "$env:USERPROFILE\Desktop" }
Set-Location $deskPath

$desktopApps = @("AnyDesk.exe", "VencordInstaller.exe")
foreach ($dApp in $desktopApps) {
    if (Test-Path $dApp) {
        Start-Process -FilePath $dApp -Wait
        Read-Host "Press ENTER after $dApp installation is finished"
    }
}

# ==========================================================
# 7. Final Optimization Scripts
# ==========================================================
Write-Host "`n--- 7. Final System Optimization ---" -ForegroundColor Cyan
irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/clean_ram.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/lossless_scaling.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/revo_uninstaller_pro.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/avast_premium_security.ps1 | iex
irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/X-Mouse_Button_Control.ps1 | iex
irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/spotify_premium.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/Install_powerplan.ps1 | iex
irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/lock_mic.ps1 | iex

Write-Host "`n[DONE] All tasks completed successfully!" -ForegroundColor Green
