// ==UserScript==
// @name         Remove Adblock Youtube
// @namespace    http://tampermonkey.net/
// @version      2025-09-21
// @description  Remove Adblock Youtube
// @author       phwyverysad
// @match        *://*.youtube.com/*
// @exclude      *://accounts.youtube.com/*
// @exclude      *:
// @exclude      *:
// @icon         https://www.google.com/s2/favicons?sz=64&domain=YouTube.com
// @grant        none
// @license      MIT
// @downloadURL  https://update.greasyfork.org/scripts/550443/Youtube-Adblock%20v4.user.js
// @updateURL    https://update.greasyfork.org/scripts/550443/Youtube-Adblock%20v4.meta.js
// ==/UserScript==

var cssArrObject = [
    `#masthead-ad`,
    `ytd-rich-item-renderer.style-scope.ytd-rich-grid-row #content:has(.ytd-display-ad-renderer)`,
    `.video-ads.ytp-ad-module`,
    `tp-yt-paper-dialog:has(yt-mealbar-promo-renderer)`,
    `ytd-engagement-panel-section-list-renderer[target-id="engagement-panel-ads"]`,
    `#related #player-ads`,
    `#related ytd-ad-slot-renderer`,
    `ytd-ad-slot-renderer`,
    `yt-mealbar-promo-renderer`,
    `ytd-popup-container:has(a[href="/premium"])`,
    `ad-slot-renderer`,
    `ytm-companion-ad-renderer`,
    `#related #-ad-`,
];

(function() {
    'use strict';
    window.dev = false;

    function removeNonVideoAds(arry) {
        arry.forEach((selector, index) => {
            arry[index] = `${selector}{display:none!important}`;
        });

        const premiumContainers = [...document.querySelectorAll(`ytd-popup-container`)];
        const matchingContainers = premiumContainers.filter(container =>
            container.querySelector(`a[href="/premium"]`)
        );

        if (matchingContainers.length > 0) {
            matchingContainers.forEach(container => container.remove());
        }

        const backdrops = document.querySelectorAll(`tp-yt-iron-overlay-backdrop`);
        const targetBackdrop = Array.from(backdrops).find(
            (backdrop) => backdrop.style.zIndex === `2201`
        );

        if (targetBackdrop) {
            targetBackdrop.className = ``;
            targetBackdrop.removeAttribute(`opened`);
        }
        
        let style = document.createElement(`style`);
        (document.head || document.body).appendChild(style);
        style.appendChild(document.createTextNode(arry.join(` `)));
    }

    function skipAd(video) {
        const adIndicator = document.querySelector(
            '.ytp-ad-skip-button, .ytp-skip-ad-button, .ytp-ad-skip-button-modern, ' +
            '.video-ads.ytp-ad-module .ytp-ad-player-overlay, .ytp-ad-button-icon'
        );

        if (adIndicator && !window.location.href.includes('https://m.youtube.com/')) {
            video.muted = true;
            video.currentTime = video.duration - 0.1;
        }
    }

    function removeAdblockWarning() {
        var warningInterval = setInterval(function() {
            var popupExists = document.getElementsByClassName("style-scope ytd-popup-container").length > 0;
            var dismissButton = document.getElementById("dismiss-button");
            var divider = document.getElementById("divider");
            
            if (popupExists && dismissButton && divider) {
                setTimeout(function() {
                    dismissButton.click();
                    document.getElementsByClassName("ytp-play-button ytp-button")[0].click();
                    console.log("banner closed");
                    clearInterval(warningInterval);
                }, Math.random() * 3);
            }
        }, Math.random() * 0.5);
    }
    
    setInterval(() => {
        if (document.readyState !== 'loading') {
            window.addEventListener('beforeunload', () => {
                window.localStorage.setItem('lastUrl', window.location.href);
            }, { once: true });
            
            removeNonVideoAds(cssArrObject);
            removeAdblockWarning();

            var adsVideo = document.querySelector('.ad-showing video');
            var mainVideo = document.querySelector('video');
            
            if(mainVideo) {
                var playerStatus = {
                    currentTime: mainVideo.currentTime,
                    isPaused: mainVideo.paused,
                    speed: mainVideo.playbackRate
                };
                
                if(playerStatus.currentTime <= 5 && playerStatus.isPaused == true){
                    mainVideo.play().catch(error => {
                        console.error('Failed to play video:', error);
                    });
                }
            }
            
            skipAd(adsVideo);
        }
    }, 500);

})();