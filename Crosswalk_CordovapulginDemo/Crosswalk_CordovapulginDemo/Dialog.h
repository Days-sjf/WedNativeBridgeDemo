//
//  Dialog.h
//  Crosswalk_CordovapulginDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <XWalkView/XWalkView.h>

@interface Dialog : XWalkExtension

- (void)jsfunc_showMsg:(UInt32)cid message:(NSString *)message callback:(UInt32)callback;

@end
