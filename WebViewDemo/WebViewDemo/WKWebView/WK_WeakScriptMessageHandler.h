//
//  WK_WeakScriptMessageHandler.h
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <WebKit/WebKit.h>

NS_CLASS_AVAILABLE_IOS(8_0) @interface WK_WeakScriptMessageHandler : NSObject <WKScriptMessageHandler>

@property(nonatomic, weak) id<WKScriptMessageHandler> scriptDelegate;

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate;

@end