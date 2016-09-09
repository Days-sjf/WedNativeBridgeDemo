//
//  ui_dialog.js
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

function dialogWeb(title, text) {
  var url = 'alert://ui_webView?' + 'title=' + title +'&'+'text='+text;
//  invokeObjc(url);
  locationCommand(url);
}

// js
function invokeObjc(url) {
  var iframe;
  iframe = document.createElement("iframe");
  iframe.setAttribute("src", url);
  iframe.setAttribute("style", "display:none;");
  document.body.appendChild(iframe);
  iframe.parentNode.removeChild(iframe);
}

function locationCommand(url) {
  document.location = url;
}