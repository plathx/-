// ==UserScript==
// @name         VirusTotal Keyword Scanner V3.7 (Bug Fix)
// @namespace    http://tampermonkey.net/
// @version      3.7
// @description  แก้ไข Bug การตรวจจับค้าง และปรับปรุงความแม่นยำในการสแกน
// @author       Gemini & User
// @match        https://www.virustotal.com/*
// @grant        none
// ==/UserScript==

(function() {
    'use strict';

    const malwareDb = {
        'PYTHON': 'Scripting Language: มักถูกใช้รันโค้ดอันตรายผ่าน Packer เช่น PyInstaller เพื่อหลบเลี่ยงการสแกนแบบ Static',
        'EXPIRO': 'File Infector: ไวรัสอันตรายที่แพร่กระจายโดยการเกาะไฟล์ .EXE และขโมยข้อมูลผู้ใช้ส่งกลับไปยัง C2',
        'REDLINE': 'Stealer: ขโมยรหัสผ่าน, คุกกี้เบราว์เซอร์, ข้อมูลบัตรเครดิต และกระเป๋าเงินคริปโต',
        'AGENTTESLA': 'Spyware: เน้นบันทึกการพิมพ์ (Keylogger) และขโมยข้อมูลจากอีเมล, FTP, และ Web Browser',
        'LUMMA': 'Stealer: มัลแวร์สมัยใหม่ที่ออกแบบมาเพื่อขโมย Browser Extension และรหัส 2FA โดยเฉพาะ',
        'RACCOON': 'Stealer: มัลแวร์ยอดนิยมที่ขโมยข้อมูลแบบครอบคลุม มักแพร่กระจายผ่านโฆษณาปลอม (Malvertising)',
        'VIDAR': 'Stealer/Spyware: ดึงข้อมูลประวัติการใช้งาน (History) และเอกสารสำคัญในเครื่องเหยื่อ',
        'ASYNCRAT': 'Remote Access Trojan: ควบคุมเครื่องระยะไกล สั่งรันคำสั่ง และเปิดกล้อง/ไมโครโฟนได้',
        'REMCOS': 'RAT: เครื่องมือควบคุมระยะไกลเกรดพาณิชย์ที่มักถูกใช้สอดแนมและขโมยข้อมูลสำคัญ',
        'QUASAR': 'RAT: มัลแวร์โอเพนซอร์สที่ถูกดัดแปลงมาเพื่อใช้เจาะระบบเครือข่ายภายในองค์กร',
        'XWORM': 'RAT/Botnet: สามารถแพร่กระจายผ่าน USB, สั่งยิง DDoS และดาวน์โหลดมัลแวร์ตัวอื่นมาลงเพิ่ม',
        'VENOMRAT': 'RAT: พัฒนาจาก Quasar โดยเพิ่มฟีเจอร์การขโมยข้อมูลและการขุดเหรียญคริปโต',
        'WARZONE': 'RAT: มีความสามารถสูงในการ Bypass UAC (สิทธิ์แอดมิน) และขโมยรหัสผ่านเบราว์เซอร์',
        'DARKCOMET': 'Legacy RAT: มัลแวร์ควบคุมเครื่องรุ่นเก่าที่ยังคงถูกใช้อยู่ในการโจมตีแบบไม่ซับซ้อน',
        'LOCKBIT': 'Ransomware: ไวรัสเรียกค่าไถ่ที่มีความเร็วในการเข้ารหัสไฟล์สูงและทำลายระบบ Backup',
        'STOP': 'Ransomware: มักติดมากับไฟล์ Crack เกม/ซอฟต์แวร์ จะเข้ารหัสไฟล์เป็นนามสกุล .djvu',
        'WANNACRY': 'Ransomware: แพร่กระจายผ่านช่องโหว่ SMB (EternalBlue) ในเครือข่ายอัตโนมัติ',
        'CONTI': 'Ransomware Group: กลุ่มมัลแวร์เรียกค่าไถ่ระดับองค์กรที่มีความซับซ้อนสูง',
        'PHOBOS': 'Ransomware: มักโจมตีผ่านช่องโหว่ RDP (Remote Desktop) เพื่อเข้าล็อกไฟล์ในเซิร์ฟเวอร์',
        'XMRIG': 'Miner: แอบใช้พลังประมวลผล (CPU) ขุดเหรียญคริปโต ทำให้เครื่องทำงานหนักและร้อน',
        'COBALTSTRIKE': 'Post-Exploitation: เครื่องมือจำลองการโจมตีที่แฮ็กเกอร์ใช้ค้างอยู่ในระบบ (Persistence)',
        'SLIVER': 'C2 Framework: เครื่องมือควบคุมมัลแวร์สมัยใหม่ที่เป็นคู่แข่งของ Cobalt Strike',
        'HAVOC': 'C2 Framework: แพลตฟอร์มควบคุมมัลแวร์รุ่นใหม่ที่เน้นการหลบเลี่ยง EDR/Antivirus',
        'PYINSTALLER': 'Packer: การรวมสคริปต์ Python เป็นไฟล์ .exe (นิยมใช้ซ่อนโค้ดอันตรายให้ตรวจจับยาก)',
        'EMOTET': 'Botnet/Dropper: มัลแวร์ตัวนำทางที่ใช้แพร่กระจาย Ransomware และ Trojan ตัวอื่นๆ',
        'TRICKBOT': 'Modular Trojan: เน้นขโมยข้อมูลธนาคารและช่วยแพร่กระจายมัลแวร์เรียกค่าไถ่ Ryuk',
        'QAKBOT': 'Banking Trojan: มักแฝงมากับไฟล์เอกสารในอีเมล เพื่อขโมยข้อมูลการเงินในองค์กร',
        'INJECTOR': 'Malware Component: โค้ดที่ใช้ฉีดมัลแวร์เข้าไปในโปรเซสที่ปลอดภัยเพื่อพรางตัว',
        'SHELLCODE': 'Exploit Payload: ชุดคำสั่งขนาดเล็กที่รันในหน่วยความจำเพื่อเริ่มการโจมตีระบบ',
        'DROPPER': 'Loader: มัลแวร์เริ่มต้นที่ทำหน้าที่ดาวน์โหลดและติดตั้งมัลแวร์ตัวจริงลงในเครื่อง'
    };

    const malwareList = Object.keys(malwareDb);
    const regex = new RegExp(`\\b(${malwareList.join('|')}|\\w*RAT)\\b`, 'gi');

    let foundMalwareSet = new Set();
    let count = 0;

    function findAndHighlight(root) {
        if (!root) return;
        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT, null, false);
        let node;
        while (node = walker.nextNode()) {
            const parent = node.parentElement;
            if (!parent || ['SCRIPT', 'STYLE', 'NOSCRIPT', 'TEXTAREA'].includes(parent.tagName)) continue;
            if (parent.offsetParent === null) continue; 

            const text = node.textContent;
            if (regex.test(text)) {
                const matches = text.match(regex);
                if (matches) {
                    matches.forEach(m => {
                        const upperM = m.toUpperCase();

                        foundMalwareSet.add(upperM);
                    });

                    if (!parent.classList.contains('vt-found')) {
                        parent.style.backgroundColor = '#ffeb3b';
                        parent.style.color = '#000';
                        parent.style.fontWeight = 'bold';
                        parent.style.outline = '3px solid #f44336';
                        parent.classList.add('vt-found');
                        count++;
                    }
                }
            }
            regex.lastIndex = 0;
        }

        const allElements = root.querySelectorAll?.('*') || [];
        allElements.forEach(el => {
            if (el.shadowRoot) findAndHighlight(el.shadowRoot);
        });
    }

    function startScan() {
        count = 0;
        foundMalwareSet.clear();
        intelBtn.style.display = 'none';

        document.querySelectorAll('.vt-found').forEach(el => {
            el.style.backgroundColor = '';
            el.style.outline = '';
            el.style.color = '';
            el.classList.remove('vt-found');
        });

        findAndHighlight(document.body);

        if (count > 0 && foundMalwareSet.size > 0) {
            const firstFound = document.querySelector('.vt-found');
            if (firstFound) firstFound.scrollIntoView({ behavior: 'smooth', block: 'center' });
            intelBtn.style.display = 'block';
            alert(`🚨 พบภัยคุกคาม ${count} จุด!`);
        } else {
            alert('🔍 สแกนเสร็จสิ้น: ไม่พบมัลแวร์ตามฐานข้อมูลในหน้านี้');
        }
    }

    function showIntel() {
        let message = "📋 บทสรุปข้อมูลภัยคุกคาม (Threat Intel):\n" + "─".repeat(30) + "\n\n";

        const sortedResults = Array.from(foundMalwareSet).sort();

        sortedResults.forEach(name => {
            const desc = malwareDb[name] || malwareDb[Object.keys(malwareDb).find(k => name.includes(k))];
            if (desc) {
                message += `[!] ${name}\nℹ️ ${desc}\n\n`;
            }
        });

        if (foundMalwareSet.size === 0) {
            message = "ไม่พบข้อมูลมัลแวร์จากการสแกนครั้งล่าสุด";
        }

        alert(message);
    }

    const scanBtn = document.createElement('button');
    scanBtn.innerHTML = '🛡️ Deep Scan';
    scanBtn.style.cssText = `position: fixed; bottom: 25px; right: 25px; z-index: 10000; padding: 15px 25px; background: #d32f2f; color: white; border: 2px solid #fff; border-radius: 50px; cursor: pointer; box-shadow: 0 5px 15px rgba(0,0,0,0.3); font-weight: bold;`;
    scanBtn.onclick = startScan;

    const intelBtn = document.createElement('button');
    intelBtn.innerHTML = '📋 View Intel Report';
    intelBtn.style.cssText = `position: fixed; bottom: 90px; right: 25px; z-index: 10000; padding: 12px 20px; background: #1976d2; color: white; border: 2px solid #fff; border-radius: 50px; cursor: pointer; box-shadow: 0 5px 15px rgba(0,0,0,0.3); font-weight: bold; display: none;`;
    intelBtn.onclick = showIntel;

    document.body.appendChild(scanBtn);
    document.body.appendChild(intelBtn);
})();