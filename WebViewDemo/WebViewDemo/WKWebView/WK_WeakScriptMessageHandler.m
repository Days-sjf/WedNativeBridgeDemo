//
//  WK_WeakScriptMessageHandler.m
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "WK_WeakScriptMessageHandler.h"

@implementation WK_WeakScriptMessageHandler

- (void)dealloc {
  NSLog(@"%@ dealloced", NSStringFromClass([self class]));
  _scriptDelegate = nil;
}

- (instancetype)initWithDelegate:(id<WKScriptMessageHandler>)scriptDelegate {
  if (self = [super init]) {
    _scriptDelegate = scriptDelegate;
  }
  return self;
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  if ([_scriptDelegate respondsToSelector:@selector(userContentController:didReceiveScriptMessage:)]) {
    [_scriptDelegate userContentController:userContentController didReceiveScriptMessage:message];
  }
}

@end


