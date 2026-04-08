# =====================================================================
# ALL-IN-ONE CONTEXT MENU SETUP TOOL
# =====================================================================

# 1. เช็คและขอสิทธิ์ Administrator อัตโนมัติ
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "Requesting Administrator privileges..." -ForegroundColor Yellow
    try {
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    } catch {
        Write-Host "Failed to elevate privileges. Please run as Administrator." -ForegroundColor Red
        Pause
    }
    Exit
}

# 2. ตัวแปรตั้งต้น
$ScriptDir = "C:\scripts"

# 3. ฟังก์ชันตัวช่วย
function Pause-Script {
    Write-Host "`nPress any key to return to the menu..." -ForegroundColor DarkGray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Ensure-ScriptDir {
    if (-not (Test-Path $ScriptDir)) {
        New-Item -Path $ScriptDir -ItemType Directory -Force | Out-Null
        Write-Host "[OK] Created directory: $ScriptDir" -ForegroundColor Green
    }
}

function Refresh-Icons {
    Start-Process -FilePath "ie4uinit.exe" -ArgumentList "-show" -NoNewWindow -Wait
}

# =====================================================================
# INSTALL FUNCTIONS
# =====================================================================

function Install-PythonToExe {
    Write-Host "`n--- Installing Python to EXE ---" -ForegroundColor Cyan
    Ensure-ScriptDir
    
    $psFile = "$ScriptDir\compile_python.ps1"
    $iconFile = "$ScriptDir\python.ico"

    # Download Icon
    Write-Host "[..] Downloading Python icon..." -ForegroundColor Yellow
    if (-not (Test-Path $iconFile)) {
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/python/cpython/main/PC/icons/python.ico" -OutFile $iconFile -ErrorAction Stop
            Write-Host "[OK] Icon downloaded." -ForegroundColor Green
        } catch {
            Write-Host "[!] Failed to download icon. Using default." -ForegroundColor Red
        }
    }

    # Create PS Script (ใช้ @''@ แบบ Single Quote เพื่อไม่ให้ตัวแปรในสตริงทำงานตอนสร้างไฟล์)
    Write-Host "[..] Creating script file..." -ForegroundColor Yellow
    $pyScriptContent = @'
$filePath = $args[0]
if (-not $filePath) { exit }
$fileDir = [System.IO.Path]::GetDirectoryName($filePath)
$fileName = [System.IO.Path]::GetFileNameWithoutExtension($filePath)
Set-Location -Path $fileDir
Write-Host "Compiling $fileName.py to EXE..." -ForegroundColor Cyan
Write-Host "Command: py -m PyInstaller --onefile --noconfirm --clean `"$filePath`"" -ForegroundColor DarkGray
Write-Host "--------------------------------------------------"
py -m PyInstaller --onefile --noconfirm --clean $filePath
$exePath = Join-Path -Path $fileDir -ChildPath "dist\$fileName.exe"
if (Test-Path $exePath) {
    Write-Host "--------------------------------------------------"
    Write-Host "BUILD COMPLETE!" -ForegroundColor Green
    Write-Host "Opening folder and highlighting the EXE file..." -ForegroundColor Cyan
    Start-Process explorer.exe -ArgumentList "/select,`"$exePath`""
    Start-Sleep -Seconds 3
} else {
    Write-Host "--------------------------------------------------"
    Write-Host "Build failed! EXE file not found." -ForegroundColor Red
    pause
}
'@
    Set-Content -Path $psFile -Value $pyScriptContent -Force

    # Registry
    Write-Host "[..] Setting up Registry..." -ForegroundColor Yellow
    $regPath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force }
    
    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(default)" -Value "py to exe"
    if (Test-Path $iconFile) {
        Set-ItemProperty -Path $regPath -Name "Icon" -Value "`"$iconFile`""
    } else {
        Set-ItemProperty -Path $regPath -Name "Icon" -Value "cmd.exe"
    }

    New-Item -Path "$regPath\command" -Force | Out-Null
    Set-ItemProperty -Path "$regPath\command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -NoProfile -File `"$psFile`" `"%1`""

    Refresh-Icons
    Write-Host "[OK] Python to EXE Installed Successfully!" -ForegroundColor Green
}

function Install-Gofile {
    Write-Host "`n--- Installing Get Gofile Link ---" -ForegroundColor Cyan
    Ensure-ScriptDir
    
    $psFile = "$ScriptDir\share_file.ps1"

    Write-Host "[..] Creating script file..." -ForegroundColor Yellow
    $goScriptContent = @'
$filePath = $args[0]
if (-not $filePath) { exit }
$fileName = [System.IO.Path]::GetFileName($filePath)
try {
    Write-Host "Connecting to Gofile..." -ForegroundColor Cyan
    $serverInfo = Invoke-RestMethod -Uri "https://api.gofile.io/servers"
    $server = $serverInfo.data.servers[0].name
    Write-Host "Uploading: $fileName" -ForegroundColor Yellow
    Write-Host "Server: $server" -ForegroundColor DarkGray
    Write-Host "--------------------------------------------------"
    $tempResult = [System.IO.Path]::GetTempFileName()
    curl.exe -# -F "file=@$filePath" "https://$server.gofile.io/contents/uploadfile" -o $tempResult
    $responseRaw = Get-Content $tempResult -Raw
    $response = $responseRaw | ConvertFrom-Json
    Remove-Item $tempResult
    if ($response.status -eq "ok") {
        $link = $response.data.downloadPage
        $link | Set-Clipboard
        Write-Host "--------------------------------------------------"
        Write-Host "UPLOAD COMPLETE!" -ForegroundColor Green
        Write-Host "Link: $link" -ForegroundColor Cyan
        Write-Host "Link has been copied to your clipboard."
        Add-Type -AssemblyName System.Windows.Forms
        [System.Windows.Forms.MessageBox]::Show("Upload Finished!`n`nLink: $link", "Success")
    } else {
        Write-Host "Upload failed!" -ForegroundColor Red
        pause
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
    pause
}
'@
    Set-Content -Path $psFile -Value $goScriptContent -Force

    Write-Host "[..] Setting up Registry..." -ForegroundColor Yellow
    $regPath = "Registry::HKEY_CLASSES_ROOT\*\shell\CreateGofileLink"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force }
    # ลบของเก่าชื่อ CreateLink (จากสคริปต์เก่า) เผื่อมีค้าง
    if (Test-Path "Registry::HKEY_CLASSES_ROOT\*\shell\CreateLink") { Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\CreateLink" -Recurse -Force }

    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(default)" -Value "Get Gofile Link"
    Set-ItemProperty -Path $regPath -Name "Icon" -Value "imageres.dll,-1024"

    New-Item -Path "$regPath\command" -Force | Out-Null
    Set-ItemProperty -Path "$regPath\command" -Name "(default)" -Value "powershell.exe -ExecutionPolicy Bypass -File `"$psFile`" `"%1`""

    Write-Host "[OK] Get Gofile Link Installed Successfully!" -ForegroundColor Green
}

function Install-Smart7z {
    Write-Host "`n--- Installing Smart 7-Zip Extract ---" -ForegroundColor Cyan
    Ensure-ScriptDir
    
    $sevenZPath = "C:\Program Files\7-Zip\7z.exe"
    $sevenZFM = "C:\Program Files\7-Zip\7zFM.exe"

    if (Test-Path $sevenZPath) {
        Write-Host "[OK] 7-Zip is already installed." -ForegroundColor Green
    } else {
        Write-Host "[..] 7-Zip not found. Downloading and installing silently..." -ForegroundColor Yellow
        $tempSetup = "$env:TEMP\7z_setup.exe"
        try {
            Invoke-WebRequest -Uri "https://www.7-zip.org/a/7z2409-x64.exe" -OutFile $tempSetup -ErrorAction Stop
            Start-Process -FilePath $tempSetup -ArgumentList "/S" -Wait -NoNewWindow
            Remove-Item $tempSetup -Force
            Write-Host "[OK] 7-Zip installed successfully." -ForegroundColor Green
        } catch {
            Write-Host "[!] Failed to download or install 7-Zip." -ForegroundColor Red
            return
        }
    }

    $batFile = "$ScriptDir\smart_extract.bat"
    Write-Host "[..] Creating extraction script..." -ForegroundColor Yellow
    
    $batContent = @'
@echo off
chcp 65001 >nul
set "SEVENZ=C:\Program Files\7-Zip\7z.exe"
if not exist "%SEVENZ%" exit /b
set "FILE=%~1"
set "FOLDER=%~dpn1"

:: Extract to folder named after the file
"%SEVENZ%" x "%FILE%" -o"%FOLDER%" -y
'@
    Set-Content -Path $batFile -Value $batContent -Force -Encoding UTF8

    Write-Host "[..] Setting up Registry..." -ForegroundColor Yellow
    $regPath = "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtract"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force }
    if (Test-Path "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtractDel") { Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtractDel" -Recurse -Force }

    New-Item -Path $regPath -Force | Out-Null
    Set-ItemProperty -Path $regPath -Name "(default)" -Value "Extract to Folder"
    Set-ItemProperty -Path $regPath -Name "Icon" -Value "`"$sevenZFM`",0"

    New-Item -Path "$regPath\command" -Force | Out-Null
    Set-ItemProperty -Path "$regPath\command" -Name "(default)" -Value "`"$batFile`" `"%1`""

    Refresh-Icons
    Write-Host "[OK] Smart 7-Zip Extract Installed Successfully!" -ForegroundColor Green
}


# =====================================================================
# UNINSTALL FUNCTIONS
# =====================================================================

function Uninstall-PythonToExe {
    Write-Host "`n--- Uninstalling Python to EXE ---" -ForegroundColor Cyan
    $regPath = "Registry::HKEY_CLASSES_ROOT\SystemFileAssociations\.py\shell\CompilePy"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force; Write-Host "[OK] Registry removed." -ForegroundColor Green }
    
    if (Test-Path "$ScriptDir\compile_python.ps1") { Remove-Item "$ScriptDir\compile_python.ps1" -Force; Write-Host "[OK] Script removed." -ForegroundColor Green }
    if (Test-Path "$ScriptDir\python.ico") { Remove-Item "$ScriptDir\python.ico" -Force }
    Refresh-Icons
}

function Uninstall-Gofile {
    Write-Host "`n--- Uninstalling Get Gofile Link ---" -ForegroundColor Cyan
    $regPath = "Registry::HKEY_CLASSES_ROOT\*\shell\CreateGofileLink"
    $regPathOld = "Registry::HKEY_CLASSES_ROOT\*\shell\CreateLink"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force; Write-Host "[OK] Registry removed." -ForegroundColor Green }
    if (Test-Path $regPathOld) { Remove-Item -Path $regPathOld -Recurse -Force }
    
    if (Test-Path "$ScriptDir\share_file.ps1") { Remove-Item "$ScriptDir\share_file.ps1" -Force; Write-Host "[OK] Script removed." -ForegroundColor Green }
}

function Uninstall-Smart7z {
    Write-Host "`n--- Uninstalling Smart 7-Zip Extract ---" -ForegroundColor Cyan
    $regPath = "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtract"
    if (Test-Path $regPath) { Remove-Item -Path $regPath -Recurse -Force; Write-Host "[OK] Registry removed." -ForegroundColor Green }
    if (Test-Path "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtractDel") { Remove-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\SmartExtractDel" -Recurse -Force }
    
    if (Test-Path "$ScriptDir\smart_extract.bat") { Remove-Item "$ScriptDir\smart_extract.bat" -Force; Write-Host "[OK] Script removed." -ForegroundColor Green }
    Refresh-Icons
}

function Cleanup-ScriptDir {
    # ลบโฟลเดอร์ C:\scripts ถ้าไม่มีไฟล์ข้างในแล้ว
    if (Test-Path $ScriptDir) {
        $files = Get-ChildItem -Path $ScriptDir
        if ($files.Count -eq 0) {
            Remove-Item $ScriptDir -Force
            Write-Host "[OK] Empty script directory removed." -ForegroundColor Green
        }
    }
}

# =====================================================================
# MAIN MENU UI
# =====================================================================

while ($true) {
    Clear-Host
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host "             WINDOWS CONTEXT MENU SETUP TOOL            " -ForegroundColor Black -BackgroundColor Cyan
    Write-Host "========================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  [ INSTALL ]" -ForegroundColor Green
    Write-Host "   1. Install: Python to EXE"
    Write-Host "   2. Install: Get Gofile Link"
    Write-Host "   3. Install: Smart 7-Zip Extract"
    Write-Host "   4. Install: ALL OF THE ABOVE"
    Write-Host ""
    Write-Host "  [ UNINSTALL ]" -ForegroundColor Red
    Write-Host "   5. Uninstall: Python to EXE"
    Write-Host "   6. Uninstall: Get Gofile Link"
    Write-Host "   7. Uninstall: Smart 7-Zip Extract"
    Write-Host "   8. Uninstall: ALL OF THE ABOVE"
    Write-Host ""
    Write-Host "   0. Exit"
    Write-Host ""
    Write-Host "========================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Select an option (0-8)"

    switch ($choice) {
        "1" { Install-PythonToExe; Pause-Script }
        "2" { Install-Gofile; Pause-Script }
        "3" { Install-Smart7z; Pause-Script }
        "4" { Install-PythonToExe; Install-Gofile; Install-Smart7z; Pause-Script }
        "5" { Uninstall-PythonToExe; Cleanup-ScriptDir; Pause-Script }
        "6" { Uninstall-Gofile; Cleanup-ScriptDir; Pause-Script }
        "7" { Uninstall-Smart7z; Cleanup-ScriptDir; Pause-Script }
        "8" { Uninstall-PythonToExe; Uninstall-Gofile; Uninstall-Smart7z; Cleanup-ScriptDir; Pause-Script }
        "0" { Exit }
        default { Write-Host "Invalid choice. Please try again." -ForegroundColor Red; Start-Sleep -Seconds 1 }
    }
}
