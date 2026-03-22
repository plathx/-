param(
    [string]$DownloadLink 
)

$Host.UI.RawUI.WindowTitle = "add_games_steam"
$name = "luatools" 
$link = "https://github.com/madoiscool/ltsteamplugin/releases/latest/download/ltsteamplugin.zip"

if ( $DownloadLink ) {
    $link = $DownloadLink
}

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
chcp 65001 > $null
Add-Type -AssemblyName System.IO.Compression.FileSystem

$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'Stop'

# ฟังก์ชันสำหรับจัดการ Error
function Show-Error([string]$Context) {
    Write-Host "error: $Context" -ForegroundColor Red
    exit
}

try {
    # 1. หาโฟลเดอร์ Steam และปิด Steam
    $steam = (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -ErrorAction SilentlyContinue).InstallPath
    if (-not $steam -or -not (Test-Path $steam)) { Show-Error "Steam installation not found" }
    Get-Process steam -ErrorAction SilentlyContinue | Stop-Process -Force

    # 2. ตรวจสอบและติดตั้ง Steamtools
    $path = Join-Path $steam "dwmapi.dll"
    if (-not (Test-Path $path)) {
        try {
            $script = Invoke-RestMethod "https://steam.run"
            $keptLines = @()
            foreach ($line in $script -split "`n") {
                $conditions = @( 
                    ($line -imatch "Start-Process" -and $line -imatch "steam"),
                    ($line -imatch "steam\.exe"),
                    ($line -imatch "Start-Sleep" -or $line -imatch "Write-Host"),
                    ($line -imatch "cls" -or $line -imatch "exit"),
                    ($line -imatch "Stop-Process" -and -not ($line -imatch "Get-Process"))
                )
                if (-not($conditions -contains $true)) { $keptLines += $line }
            }
            $SteamtoolsScript = $keptLines -join "`n"
            
            Invoke-Expression $SteamtoolsScript *> $null
            if (-not (Test-Path $path)) { Show-Error "Steamtools installation failed" }
        } catch {
            Show-Error "Failed during Steamtools installation process"
        }
    }

    # 3. ตรวจสอบและติดตั้ง Millennium
    $millenniumMissing = $false
    foreach ($file in @("millennium.dll", "python311.dll")) {
        if (-not (Test-Path (Join-Path $steam $file))) { 
            $millenniumMissing = $true
            break 
        }
    }

    if ($millenniumMissing) {
        try {
            Invoke-Expression "& { $(Invoke-RestMethod 'https://clemdotla.github.io/millennium-installer-ps1/millennium.ps1') } -NoLog -DontStart -SteamPath '$steam'" *> $null
        } catch {
            Show-Error "Failed during Millennium installation process"
        }
    }

    # 4. จัดการโฟลเดอร์ Plugins
    if (-not (Test-Path (Join-Path $steam "plugins"))) {
        New-Item -Path (Join-Path $steam "plugins") -ItemType Directory *> $null
    }

    $Path = Join-Path $steam "plugins\$name" 
    foreach ($plugin in Get-ChildItem -Path (Join-Path $steam "plugins") -Directory) {
        $testpath = Join-Path $plugin.FullName "plugin.json"
        if (Test-Path $testpath) {
            $json = Get-Content $testpath -Raw | ConvertFrom-Json
            if ($json.name -eq $name) {
                $Path = $plugin.FullName 
                break
            }
        }
    }

    # 5. โหลดและแตกไฟล์ Plugin
    $subPath = Join-Path $env:TEMP "$name.zip"
    try {
        Invoke-WebRequest -Uri $link -OutFile $subPath *> $null
        if (-not (Test-Path $subPath)) { Show-Error "Failed to download $name plugin" }
    } catch {
        Show-Error "Failed to download $name plugin"
    }

    try {      
        $zip = [System.IO.Compression.ZipFile]::OpenRead($subPath)
        foreach ($entry in $zip.Entries) {
            $destinationPath = Join-Path $Path $entry.FullName
            if (-not $entry.FullName.EndsWith('/') -and -not $entry.FullName.EndsWith('\')) {
                $parentDir = Split-Path -Path $destinationPath -Parent
                if ($parentDir -and $parentDir.Trim() -ne '') {
                    $pathParts = $parentDir -replace [regex]::Escape($steam), '' -split '[\\/]' | Where-Object { $_ }
                    $currentPath = $Path
                    
                    foreach ($part in $pathParts) {
                        $currentPath = Join-Path $currentPath $part
                        if (Test-Path $currentPath) {
                            $item = Get-Item $currentPath
                            if (-not $item.PSIsContainer) { Remove-Item $currentPath -Force }
                        }
                    }
                    [System.IO.Directory]::CreateDirectory($parentDir) | Out-Null
                    [System.IO.Compression.ZipFileExtensions]::ExtractToFile($entry, $destinationPath, $true)
                }
            }
        }
        $zip.Dispose()
    } catch {
        if ($zip) { $zip.Dispose() }
        try {
            Expand-Archive -Path $subPath -DestinationPath $Path -Force
        } catch {
            Show-Error "Failed to extract $name plugin"
        }
    }

    if (Test-Path $subPath) { Remove-Item $subPath -ErrorAction SilentlyContinue }

    # 6. ล้างไฟล์ขยะและตั้งค่า Config
    $betaPath = Join-Path $steam "package\beta"
    if (Test-Path $betaPath) { Remove-Item $betaPath -Recurse -Force -ErrorAction SilentlyContinue }
    
    $cfgPath = Join-Path $steam "steam.cfg"
    if (Test-Path $cfgPath) { Remove-Item $cfgPath -Recurse -Force -ErrorAction SilentlyContinue }
    
    Remove-ItemProperty -Path "HKCU:\Software\Valve\Steam" -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Valve\Steam" -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\WOW6432Node\Valve\Steam" -Name "SteamCmdForceX86" -ErrorAction SilentlyContinue

    try {
        $configPath = Join-Path $steam "ext/config.json"
        if (-not (Test-Path $configPath)) {
            $config = @{
                plugins = @{ enabledPlugins = @($name) }
                general = @{ checkForMillenniumUpdates = $false }
            }
            New-Item -Path (Split-Path $configPath) -ItemType Directory -Force | Out-Null
            $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
        } else {
            $config = (Get-Content $configPath -Raw -Encoding UTF8) | ConvertFrom-Json

            function _EnsureProperty($Object, $PropertyName, $DefaultValue) {
                if (-not $Object.$PropertyName) {
                    $Object | Add-Member -MemberType NoteProperty -Name $PropertyName -Value $DefaultValue -Force
                }
            }

            _EnsureProperty $config "general" @{}
            _EnsureProperty $config "general.checkForMillenniumUpdates" $false
            $config.general.checkForMillenniumUpdates = $false

            _EnsureProperty $config "plugins" @{ enabledPlugins = @() }
            _EnsureProperty $config "plugins.enabledPlugins" @()
            
            $pluginsList = @($config.plugins.enabledPlugins)
            if ($pluginsList -notcontains $name) {
                $pluginsList += $name
                $config.plugins.enabledPlugins = $pluginsList
            }
            $config | ConvertTo-Json -Depth 10 | Set-Content $configPath -Encoding UTF8
        }
    } catch {
        Show-Error "Failed to configure Millennium config"
    }

    # 7. เปิด Steam
    try {
        $exe = Join-Path $steam "steam.exe"
        Start-Process $exe -ArgumentList "-clearbeta"
    } catch {
        Show-Error "Failed to start Steam"
    }

    # 8. แสดงข้อความสำเร็จ (ถ้าไม่มี Error ใดๆ หลุดมาถึงจุดนี้ได้)
    Write-Host "succeed" -ForegroundColor Green
    Write-Host "Enter an ID Plugin : c36d5f67c99f" -ForegroundColor Green

} catch {
    # ดัก Error รวมเผื่อมีโค้ดบางส่วนหลุดออกมา
    Show-Error $_.Exception.Message
}
