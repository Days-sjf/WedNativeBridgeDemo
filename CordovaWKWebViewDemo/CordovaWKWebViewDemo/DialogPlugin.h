//
//  DialogPlugin.h
//  CordovaWKWebViewDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <Cordova/CDV.h>

@interface DialogPlugin : CDVPlugin

- (void)showMessage:(CDVInvokedUrlCommand *)command;

@end

