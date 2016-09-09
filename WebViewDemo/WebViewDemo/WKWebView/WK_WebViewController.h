//
//  WK_WebViewController.h
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WK_WebViewDef.h"

@class WK_WebViewController;
@protocol WK_WebViewControllerDelegate <NSObject>
@optional

// return YES: is processed
- (BOOL)webViewController:(WK_WebViewController *)controller didReceiveScriptMessage:(WKScriptMessage *)message;

@end

NS_CLASS_AVAILABLE_IOS(8_0) @interface WK_WebViewController : UIViewController

@property(nonatomic, weak) id<WK_WebViewControllerDelegate> delegate;
@property(nonatomic, assign) BOOL showProgress; // default is YES

- (instancetype)initWithURL:(NSURL *)URL;

/*
 * JS called native, usage:
 window.webkit.messageHandlers.$name.postMessage(message);
 */
- (void)injectScriptMessageHandlerWithName:(NSString *)name;
- (void)injectScriptMessageHandlerWithNames:(NSArray<NSString *> *)names;

- (void)injectScriptWithSource:(NSString *)source injectionTime:(WKUserScriptInjectionTime)injectionTime;

@end
