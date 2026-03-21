[console]::InputEncoding = [console]::OutputEncoding = New-Object System.Text.UTF8Encoding

$menuItems = @{
    1  = @{ Name = "ล็อกไมค์ (Lock Mic)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/lock_mic.ps1 | iex" }
    2  = @{ Name = "เสกเกมสตรีม (Steam)"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/add_games_steam.ps1 | iex" }
    3  = @{ Name = "PowerPlan (KernelOS)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/Install_powerplan.ps1 | iex" }
    4  = @{ Name = "Spotify Premium"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/spotify_premium.ps1 | iex" }
    5  = @{ Name = "โหลด OS ทับ (Atlas/ReviOS)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/playbook_downloader.ps1 | iex" }
    6  = @{ Name = "แปลงไฟล์ .py เป็น .exe"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/py_to_exe.ps1 | iex" }
    7  = @{ Name = "Minecraft for Windows"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/minecraft_for_windows.ps1 | iex" }
    8  = @{ Name = "Discord 3 ตัว"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/rwm_discord.ps1 | iex" }
    9  = @{ Name = "Clean Ram"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/clean_ram.ps1 | iex" }
    10 = @{ Name = "ปรับแต่ง Windows (WinUtil)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/winutil.ps1 | iex" }
    11 = @{ Name = "ฝากไฟล์ & แชร์ไฟล์"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/Upload_Share_Files.ps1 | iex" }
    12 = @{ Name = "สร้างจุดย้อนระบบ (Restore)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/system_restore.ps1 | iex" }
    13 = @{ Name = "เมนูทางลัด Power/BIOS"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/menu_options.ps1 | iex" }
    14 = @{ Name = "Lossless Scaling"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/lossless_scaling.ps1 | iex" }
    15 = @{ Name = "Revo Uninstaller Pro"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/revo_uninstaller_pro.ps1 | iex" }
    16 = @{ Name = "จัดการไดรเวอร์ (IObit Driver Pro)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/IObit_Driver_Booster_Pro.ps1 | iex" }
    17 = @{ Name = "ติดตั้งส่วนเสริม Windows"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/dev_tools.ps1 | iex" }
    18 = @{ Name = "ย่อลิ้งก์ให้สั้น (Short Link)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/cut_link.ps1 | iex" }
    19 = @{ Name = "IDM (โหลดไว)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/idm_build.ps1 | iex" }
    20 = @{ Name = "ดาวน์โหลด/เปิดใช้งาน Microsoft 365"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/activate_365.ps1 | iex" }
    21 = @{ Name = "เปิดใช้งาน Windows (แท้)"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/activate_windowsall.ps1 | iex" }
    22 = @{ Name = "เปลี่ยนรุ่น Windows"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/change_windows_edition.ps1 | iex" }
    23 = @{ Name = "เช็คสถานะ Activate"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/check_status_windows.ps1 | iex" }
    24 = @{ Name = "Avast Premium"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/avast_premium_security.ps1 | iex" }
    25 = @{ Name = "Malwarebytes Premium"; Cmd = "irm http://raw.githubusercontent.com/plathx/-/refs/heads/main/malwarebytes_premium.ps1 | iex" }
    26 = @{ Name = "Browser"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/browser.ps1 | iex" }
    27 = @{ Name = "X-Mouse Button Control"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/X-Mouse_Button _Control.ps1 | iex" }
    28 = @{ Name = "MiniTool Partition Wizard Pro"; Cmd = "irm https://raw.githubusercontent.com/plathx/-/refs/heads/main/MiniTool_Partition_Wizard_Pro.ps1 | iex" }
}  

function Show-Menu {
    Clear-Host
    Write-Host "  __________________________________________________________________________________________________________________" -ForegroundColor DarkGray
    Write-Host " /                                                                                                                  \" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "    █████╗ ██╗     ██╗      ██╗███╗   ██╗     ██████╗ ███╗   ██╗███████╗                                   " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "   ██╔══██╗██║     ██║      ██║████╗  ██║    ██╔═══██╗████╗  ██║██╔════╝                                   " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "   ███████║██║     ██║      ██║██╔██╗ ██║    ██║   ██║██╔██╗ ██║█████╗                                     " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "   ██╔══██║██║     ██║      ██║██║╚██╗██║    ██║   ██║██║╚██╗██║██╔══╝                                     " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "   ██║  ██║███████╗███████╗ ██║██║ ╚████║    ╚██████╔╝██║ ╚████║███████╗                                   " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " |" -NoNewline -ForegroundColor DarkGray; Write-Host "   ╚═╝  ╚═╝╚══════╝╚══════╝ ╚═╝╚═╝  ╚═══╝     ╚═════╝ ╚═╝  ╚═══╝╚══════╝                                   " -ForegroundColor Cyan -NoNewline; Write-Host " |" -ForegroundColor DarkGray
    Write-Host " \__________________________________________________________________________________________________________________/" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "   [ VERSION 2.0 ] - POWERED BY PLATHX" -ForegroundColor DarkYellow
    Write-Host "   ------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray

    for ($i = 1; $i -le 12; $i++) {
        $cols = @()
        for ($j = 0; $j -lt 3; $j++) {
            $index = $i + ($j * 12)
            if ($menuItems.ContainsKey($index)) {
                $num = "[" + $index.ToString().PadLeft(2) + "]"
                $name = $menuItems[$index].Name
                $itemStr = "   " + "$num " + "$name"
                $cleanLen = ($itemStr -replace '\p{M}', '').Length
                $padding = " " * ([Math]::Max(0, 40 - $cleanLen))
                $cols += "$itemStr$padding"
            }
        }
        Write-Host ($cols -join "") -ForegroundColor Gray
    }

    Write-Host ""
    Write-Host "   ------------------------------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "   [0] EXIT PROGRAM" -ForegroundColor Red
}

while ($true) {
    Show-Menu
    Write-Host ""
    Write-Host "   [#] SELECT OPTION: " -NoNewline -ForegroundColor Yellow
    $choice = Read-Host
    
    if ($choice -eq '0') {
        Write-Host "`n   [!] TERMINATING SESSIONS..." -ForegroundColor Red
        Start-Sleep -Seconds 1
        Stop-Process -Name "WindowsTerminal" -Force -ErrorAction SilentlyContinue
        Stop-Process -Id $PID -Force
        exit
    }

    $selected = $choice -as [int]
    
    if ($selected -and $menuItems.ContainsKey($selected)) {
        $selectedItem = $menuItems[$selected]
        Write-Host "`n   [>] INITIALIZING: " -NoNewline -ForegroundColor Cyan
        Write-Host "$($selectedItem.Name)" -ForegroundColor Green
        Write-Host "   ------------------------------------------------------------------------------------------" -ForegroundColor DarkGray
        
        try {
            Invoke-Expression $selectedItem.Cmd
            Write-Host "`n   [+] OPERATION COMPLETED SUCCESSFULLY!" -ForegroundColor Green
        } catch {
            Write-Host "`n   [-] ERROR DETECTED IN COMMAND EXECUTION" -ForegroundColor Red
        }

        Write-Host "`n   PRESS ANY KEY TO RETURN TO MAIN MENU..." -ForegroundColor DarkYellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    } else {
        Write-Host "`n   [!] INVALID SELECTION - PLEASE TRY AGAIN" -ForegroundColor Red
        Start-Sleep -Seconds 2
    }
}
