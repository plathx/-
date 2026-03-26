[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

Clear-Host
Write-Host "1. Install"
Write-Host "2. Remove"
$choice1 = Read-Host "เลือกตัวเลือก (1 หรือ 2)"

Clear-Host
Write-Host "1. BlueStacks App Player"
Write-Host "2. MSI App Player x BlueStacks"
$choice2 = Read-Host "เลือกโปรแกรม (1 หรือ 2)"

$path = if ($choice2 -eq "1") { "C:\Program Files\BlueStacks_nxt" } else { "C:\Program Files\BlueStacks_msi5" }
$dllPath = Join-Path $path "opengl32.dll"
$exePath = Join-Path $path "HD-Player.exe"
$downloadUrl = "https://github.com/phwyverysad/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/opengl32.dll"

function Stop-BS {
    $proc = Get-Process -Name "HD-Player" -ErrorAction SilentlyContinue
    if ($proc) {
        $proc | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
}

if ($choice1 -eq "1") {
    Read-Host "กดปุ่ม Enter เพื่อปิดโปรแกรมและเริ่มการดาวน์โหลด..."
    Stop-BS
    
    try {
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0")
        $wc.DownloadFile($downloadUrl, $dllPath)
        Write-Host "ติดตั้งไฟล์สำเร็จ!" -ForegroundColor Green
    } catch {
        Write-Host "เกิดข้อผิดพลาดในการดาวน์โหลด: $_" -ForegroundColor Red
        Read-Host "กดปุ่มอะไรก็ได้เพื่อออก"
        exit
    }

    if (Test-Path $exePath) {
        Write-Host "สถานะ: ติดตั้งเสร็จสิ้น" -ForegroundColor Green
        Read-Host "กดปุ่ม Enter เพื่อเปิดโปรแกรม (หรือรีสตาร์ท)"
        Start-Process $exePath
        Write-Host "กดปุ่ม INS เพื่อเปิดเมนูมอง" -ForegroundColor Cyan
    }
}
elseif ($choice1 -eq "2") {
    Read-Host "กดปุ่ม Enter เพื่อปิดโปรแกรมและเริ่มการลบ..."
    Stop-BS
    if (Test-Path $dllPath) {
        Remove-Item $dllPath -Force
        Write-Host "ลบไฟล์สำเร็จแล้ว" -ForegroundColor Green
    } else {
        Write-Host "ไม่พบไฟล์ opengl32.dll" -ForegroundColor Yellow
    }
    Read-Host "กดปุ่มอะไรก็ได้เพื่อปิดหน้าต่างนี้"
}
else {
    Write-Host "เลือกตัวเลือกไม่ถูกต้อง" -ForegroundColor Red
    Read-Host "กดปุ่มอะไรก็ได้เพื่อออก"
}

Read-Host "กดปุ่มอะไรก็ได้เพื่อปิด..."
