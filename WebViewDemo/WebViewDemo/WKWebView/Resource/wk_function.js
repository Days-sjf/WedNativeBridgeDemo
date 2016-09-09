//
//  wk_function.js
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

function pushWeb(url) {
    window.webkit.messageHandlers.pushWebView.postMessage(url);
}

function closeWeb() {
    window.webkit.messageHandlers.closeWebView.postMessage(null);
}
