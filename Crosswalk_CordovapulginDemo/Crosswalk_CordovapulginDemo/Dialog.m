//
//  Dialog.m
//  Crosswalk_CordovapulginDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "Dialog.h"

@implementation Dialog

- (void)jsfunc_showMsg:(UInt32)cid message:(NSString *)message callback:(UInt32)callback {
  dispatch_async(dispatch_get_main_queue(), ^{
    NSString *text = message ?: @"";
  
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alertView show];
  });
}
@end
