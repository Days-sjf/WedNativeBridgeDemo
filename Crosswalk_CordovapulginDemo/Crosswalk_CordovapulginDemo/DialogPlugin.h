//
//  DialogPlugin.h
//  Crosswalk_CordovapulginDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <Cordova/Cordova.h>

@interface DialogPlugin : CDVPlugin

- (void)showMessage:(CDVInvokedUrlCommand *)command;

@end
