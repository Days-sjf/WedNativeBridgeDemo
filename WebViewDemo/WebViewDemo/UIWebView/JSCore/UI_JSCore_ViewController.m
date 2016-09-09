//
//  UI_JSCore_ViewController.m
//  WebViewDemo
//
//  Created by Yincheng on 16/9/8.
//  Copyright © 2016年 Yincheng. All rights reserved.
//

#import "UI_JSCore_ViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@protocol UI_JSCore_ObjcDelegate <JSExport>

- (void)push:(NSString *)urlString;
- (void)close;
- (void)alert:(NSDictionary *)params;
@end


@interface UI_JSCore_ViewController () <UIWebViewDelegate, UI_JSCore_ObjcDelegate>

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, strong) JSContext *myCustomContext;
@property(nonatomic, strong) JSContext *webViewContext;
@end

@implementation UI_JSCore_ViewController

#pragma mark - Init & Memory
- (void)dealloc {
  _webView.delegate = nil;
}

- (instancetype)init {
  if (self = [super init]) {
    self.myCustomContext = [[JSContext alloc] init];
    self.myCustomContext.exceptionHandler = ^(JSContext *context, JSValue *exception) {
      [JSContext currentContext].exception = exception;
      NSLog(@"exception:%@",exception);
    };
    // 定义dialog
    __weak typeof(self) weakSelf = self;
    self.myCustomContext[@"dialog"] = ^(NSString *title, NSString *text) {
      UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
      [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
      [weakSelf presentViewController:controller animated:YES completion:nil];
    };
  }
  return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
  if (self = [self init]) {
    self.URL = URL;
  }
  return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];
  self.view.backgroundColor = [UIColor whiteColor];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dialog" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarAction:)];

  [self.view addSubview:self.webView];
  
  [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
}

#pragma mark - Public
- (void)rightBarAction:(id)sender {
  NSString *script = [NSString stringWithFormat:@"dialog('%@', '%@')", @"提示", @"测试弹出框"];
  [self.myCustomContext evaluateScript:script];
}

- (void)excuteInMain:(void(^)())block {
  dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - JSObjcDelegate
- (void)push:(NSString *)urlString {
  if (urlString.length > 0) {
    [self excuteInMain:^{
      UI_JSCore_ViewController *controller = [[UI_JSCore_ViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
      [self.navigationController pushViewController:controller animated:YES];
    }];
  }
}

- (void)close {
  [self excuteInMain:^{
    [self.navigationController popViewControllerAnimated:YES];
  }];
}

- (void)alert:(NSDictionary *)params {
  NSString *title = params[@"title"];
  NSString *text = params[@"text"];

  [self excuteInMain:^{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
  }];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  self.webViewContext = nil;
}

- (void)webViewDidFinishedAndRegisterJavaScriptCore:(JSContext *)context {
  context[@"WebViewDemo"] = self;

  context[@"consoleLog"] = ^(NSString *str) {
    NSLog(@"%@", str);
  };
  context.exceptionHandler = ^(JSContext *context, JSValue *exception) {
    [JSContext currentContext].exception = exception;
    NSLog(@"webViewContext exception:%@",exception);
  };
  [context evaluateScript:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ui_jscore_function" ofType:@"js"]
                                                   encoding:NSUTF8StringEncoding
                                                      error:nil]];
  
  self.webViewContext = context;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];

  // 获取WebView中的JS运行环境
  JSContext *context = [webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
  [self webViewDidFinishedAndRegisterJavaScriptCore:context];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
  NSLog(@"request failed: %@", error);
}

#pragma mark - Accessors
- (UIWebView *)webView {
  if (!_webView) {
    _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    _webView.backgroundColor = [UIColor clearColor];
    _webView.opaque = NO;
    for (UIView *subview in [_webView.scrollView subviews]) {
      if ([subview isKindOfClass:[UIImageView class]]) {
        ((UIImageView *) subview).image = nil;
        subview.backgroundColor = [UIColor clearColor];
      }
    }
    
    _webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.delegate = self;
  }
  return _webView;
}
@end
