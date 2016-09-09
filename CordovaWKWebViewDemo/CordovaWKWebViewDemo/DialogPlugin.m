//
//  DialogPlugin.m
//  CordovaWKWebViewDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "DialogPlugin.h"

@implementation DialogPlugin

- (void)showMessage:(CDVInvokedUrlCommand *)command {
  NSDictionary *info = [command argumentAtIndex:0 withDefault:nil];
  
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *title = info[@"title"];
    NSString *text = info[@"text"];
  
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
  });
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:nil];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
