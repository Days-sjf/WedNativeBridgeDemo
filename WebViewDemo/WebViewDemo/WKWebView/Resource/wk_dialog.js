//
//  wk_dialog.js
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

function dialogWeb(title, text) {
    window.webkit.messageHandlers.dialog.postMessage({'title': title || '',
                                                     'text': text || ''});
}
