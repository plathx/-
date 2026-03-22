# Check for Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    $arguments = "& '" + $MyInvocation.MyCommand.Definition + "'"
    try {
        Start-Process powershell -Verb RunAs -ArgumentList $arguments
    } catch {
        Write-Host "Execution requires Administrator privileges." -ForegroundColor Red
    }
    exit
}

function Show-Menu {
    Clear-Host
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "     Microphone Volume Lock Manager V1.0      " -ForegroundColor Cyan
    Write-Host "==============================================" -ForegroundColor Cyan
    Write-Host "1. Install (Setup Lock & Persistence)" -ForegroundColor Green
    Write-Host "2. Uninstall (Remove Lock & Cleanup)" -ForegroundColor Yellow
    Write-Host "3. Exit" -ForegroundColor Red
    Write-Host "==============================================" -ForegroundColor Cyan
}

function Install-MicLock {
    $tempDir = "C:\phwyverysad"
    $zipUrl = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/lock_mic_volume.zip"
    $zipFile = Join-Path $tempDir "lock_mic_volume.zip"

    # Cleanup old temp if exists
    if (Test-Path $tempDir) { Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue }
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    Write-Host "[*] Downloading resources..." -ForegroundColor Cyan
    try {
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipFile -TimeoutSec 60
    } catch {
        Write-Host "[!] Download failed: $($_.Exception.Message)" -ForegroundColor Red
        return
    }

    Write-Host "[*] Extracting files..." -ForegroundColor Cyan
    Expand-Archive -Path $zipFile -DestinationPath $tempDir -Force
    
    # Logic: Move files from subfolder to root if necessary (Flatten structure)
    $subFolders = Get-ChildItem -Path $tempDir -Directory
    if ($subFolders.Count -eq 1) {
        Get-ChildItem -Path $subFolders.FullName | Move-Item -Destination $tempDir -Force
    }

    Write-Host "`nSelect Volume Lock Level:" -ForegroundColor Cyan
    Write-Host "1) 100%"
    Write-Host "2) 75%"
    Write-Host "3) 50%"
    Write-Host "4) 25%"
    $volChoice = Read-Host "Choice (1-4)"

    $folderName = switch ($volChoice) {
        "1" { "100%" }
        "2" { "75%" }
        "3" { "50%" }
        "4" { "25%" }
        Default { "100%" }
    }

    $targetBatch = Join-Path $tempDir "$folderName\Run_atomatically.bat"

    if (Test-Path $targetBatch) {
        Write-Host "[*] Executing configuration for $folderName..." -ForegroundColor Green
        # Run background
        Start-Process -FilePath "cmd.exe" -ArgumentList "/c `"$targetBatch`"" -WorkingDirectory (Split-Path $targetBatch) -WindowStyle Hidden -Wait
        
        Write-Host "[*] Cleaning up temporary files..." -ForegroundColor Yellow
        Start-Sleep -Seconds 2
        Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "[+] Installation Complete!" -ForegroundColor Green
    } else {
        Write-Host "[!] Error: Folder '$folderName' or Run_atomatically.bat not found in Zip." -ForegroundColor Red
    }
}

function Uninstall-MicLock {
    Write-Host "[*] Stopping active processes..." -ForegroundColor Yellow
    Stop-Process -Name "nircmdc" -Force -ErrorAction SilentlyContinue

    $winPath = $env:WINDIR
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"

    $filesToRemove = @(
        "$winPath\lock_mic_vol.bat",
        "$winPath\hide_cmd_window2.vbs",
        "$winPath\nircmdc.exe",
        "$startupPath\start_lock_mic_vol.bat"
    )

    foreach ($file in $filesToRemove) {
        if (Test-Path $file) {
            Remove-Item $file -Force -ErrorAction SilentlyContinue
            Write-Host "[-] Removed: $file" -ForegroundColor Yellow
        }
    }

    Write-Host "[+] Uninstallation Complete!" -ForegroundColor Green
}

# Main Loop
do {
    Show-Menu
    $choice = Read-Host "Select an option"
    switch ($choice) {
        "1" { Install-MicLock }
        "2" { Uninstall-MicLock }
        "3" { break }
        Default { Write-Host "Invalid option." -ForegroundColor Red }
    }
    Write-Host "`nPress any key to continue..." -ForegroundColor Gray
    $null = [Console]::ReadKey()
} while ($choice -ne "3")