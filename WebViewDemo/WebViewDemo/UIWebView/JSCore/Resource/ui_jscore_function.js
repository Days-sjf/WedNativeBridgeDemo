//
//  ui_jscore_dialog.js
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

function closeWeb() {
  WebViewDemo.close();
  consoleLog('function is close');
}

function pushWeb(url) {
  WebViewDemo.push(url);
  consoleLog('function is pushWeb');
}

function alertWeb(title, text) {
  WebViewDemo.alert({'title': title||'', 'text': text||''});
  consoleLog('function is alertWeb');
}
