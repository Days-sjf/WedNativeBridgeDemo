//
//  DialogPlugin.m
//  Crosswalk_CordovapulginDemo
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
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self.viewController presentViewController:controller animated:YES completion:nil];
  });
  
  CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:nil];
  [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

@end
