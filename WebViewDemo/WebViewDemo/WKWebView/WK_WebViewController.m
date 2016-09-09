//
//  WK_WebViewController.m
//  WebViewDemo
//
//  Created by YinCheng on 16/9/6.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "WK_WebViewController.h"
#import "WK_WeakScriptMessageHandler.h"

@interface WK_WebViewController () <WKScriptMessageHandler, WKNavigationDelegate, WKUIDelegate>

@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) WKWebView *webView;
@property(nonatomic, strong) UIProgressView *progressView;

@property(nonatomic, strong) WKWebViewConfiguration *webViewConfiguration;
@property(nonatomic, strong) WK_WeakScriptMessageHandler *webViewScriptMessageHandler;

@property(nonatomic, strong) NSMutableSet<NSString *> *scriptMessageHandlerSet;

@end

@implementation WK_WebViewController

#pragma mark - Init & Memory
- (void)dealloc {
  NSLog(@"%@ dealloced", NSStringFromClass([self class]));
  
  _webView.UIDelegate = nil;
  _webView.navigationDelegate = nil;
  
  for (NSString *name in self.scriptMessageHandlerSet.allObjects) {
    [self.webViewConfiguration.userContentController removeScriptMessageHandlerForName:name];
  }
  [self.webViewConfiguration.userContentController removeAllUserScripts];
  
  @try {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
  } @catch (NSException *exception) {
  }
}

- (instancetype)init {
  if (self = [super init]) {
    _showProgress = YES;
  }
  return self;
}

- (instancetype)initWithURL:(NSURL *)URL {
  if (self = [self init]) {
    self.URL = URL;
  }
  return self;
}

#pragma mark - View lifycycle
- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Dialog" style:UIBarButtonItemStyleDone target:self action:@selector(rightBarAction:)];
  
  // Inject Dialog
  [self injectScriptMessageHandlerWithName:WK_WebViewScriptName_Dialog];
  NSString *dialogJSFilePath = [[NSBundle mainBundle] pathForResource:@"wk_dialog" ofType:@"js"];
  [self injectScriptWithSource:[NSString stringWithContentsOfFile:dialogJSFilePath
                                                         encoding:NSUTF8StringEncoding
                                                            error:nil]
                 injectionTime:WKUserScriptInjectionTimeAtDocumentStart];
  
  [self.view addSubview:self.webView];
  
  if ([self.URL isFileURL] && NSStringFromSelector(@selector(loadFileURL:allowingReadAccessToURL:))) {
    [self.webView loadFileURL:self.URL allowingReadAccessToURL:[NSBundle mainBundle].resourceURL];
  } else {
    [self.webView loadRequest:[NSURLRequest requestWithURL:self.URL]];
  }
}

- (void)rightBarAction:(id)sender {
  NSString *script = [NSString stringWithFormat:@"dialogWeb('%@', '%@')", @"提示", @"测试弹出框"];
  [self.webView evaluateJavaScript:script completionHandler:^(id ret, NSError *error) {
    if (error) {
      NSLog(@"webView evaluateJavaScript:[%@] failed with error:[%@]", script, error);
    }
  }];
}

#pragma mark - Public
- (void)injectScriptMessageHandlerWithName:(NSString *)name {
  if (![self.scriptMessageHandlerSet containsObject:name]) {
    [self.scriptMessageHandlerSet addObject:name];
    [self.webViewConfiguration.userContentController addScriptMessageHandler:self.webViewScriptMessageHandler name:name];
  }
}

- (void)injectScriptMessageHandlerWithNames:(NSArray<NSString *> *)names {
  for (NSString *name in names) {
    [self injectScriptMessageHandlerWithName:name];
  }
}

- (void)injectScriptWithSource:(NSString *)source injectionTime:(WKUserScriptInjectionTime)injectionTime {
  if (source.length <= 0) {
    return;
  }
  WKUserScript *script = [[WKUserScript alloc] initWithSource:source injectionTime:injectionTime forMainFrameOnly:YES];
  [self.webViewConfiguration.userContentController addUserScript:script];
}

#pragma mark - Accessors
- (WKWebView *)webView {
  if (!_webView) {
    _webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:self.webViewConfiguration];
    _webView.navigationDelegate = self;
    _webView.UIDelegate = self;
    [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
  }
  return _webView;
}

- (UIProgressView *)progressView {
  if (!_progressView) {
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 4)];
    _progressView.progressTintColor = [UIColor redColor];
    _progressView.trackTintColor = [UIColor whiteColor];
  }
  return _progressView;
}

- (WKWebViewConfiguration *)webViewConfiguration {
  if (!_webViewConfiguration) {
    _webViewConfiguration = [[WKWebViewConfiguration alloc] init];
  }
  return _webViewConfiguration;
}

- (NSMutableSet<NSString *> *)scriptMessageHandlerSet {
  if (!_scriptMessageHandlerSet) {
    _scriptMessageHandlerSet = [[NSMutableSet alloc] initWithCapacity:0];
  }
  return _scriptMessageHandlerSet;
}

- (WK_WeakScriptMessageHandler *)webViewScriptMessageHandler {
  if (!_webViewScriptMessageHandler) {
    _webViewScriptMessageHandler = [[WK_WeakScriptMessageHandler alloc] initWithDelegate:self];
  }
  return _webViewScriptMessageHandler;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*, id> *)change context:(void *)context {
  if (object == _webView) {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
      double progress = [[change objectForKey:@"new"] doubleValue];
      
      NSLog(@"--progress is %f--", progress);
      if (self.showProgress) {
        [self.progressView setProgress:progress animated:YES];
      }
    } else if ([keyPath isEqualToString:@"title"]) {
      NSString *title = [change objectForKey:@"new"];

      self.title = title;
    }
  }
}

#pragma mark - Private
- (void)checkNeedShowProgressView {
  if (self.showProgress) {
    self.progressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 4);
    self.progressView.progress = 0.0;
    [self.view addSubview:self.progressView];
  } else {
    [_progressView removeFromSuperview];
  }
}

- (void)removeProgressView {
  if (!_progressView.superview) {
    return;
  }
  if (!self.showProgress) {
    return;
  }
  [UIView animateWithDuration:0.1 animations:^{
    [_progressView removeFromSuperview];
  }];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
  if ([_delegate respondsToSelector:@selector(webViewController:didReceiveScriptMessage:)]) {
    if ([_delegate webViewController:self didReceiveScriptMessage:message]) {
      return;
    }
  }
  
  if ([message.name isEqualToString:WK_WebViewScriptName_Dialog]) {
    NSString *title = message.body[@"title"];
    NSString *text = message.body[@"text"];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
  }
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSURL *url = navigationAction.request.URL;
  
  if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
      if (![url.absoluteString isEqualToString:self.URL.absoluteString ]) {
        WK_WebViewController *controller = [[WK_WebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:controller animated:YES];
        
        decisionHandler(WKNavigationActionPolicyCancel);
      }
    } else if ([url.scheme isEqualToString:@"alert"]) {
      UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Alert" message:nil preferredStyle:UIAlertControllerStyleAlert];
      [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
      [self presentViewController:controller animated:YES completion:nil];
      
      decisionHandler(WKNavigationActionPolicyCancel);
    }
  }
  
  decisionHandler(WKNavigationActionPolicyAllow);
}
/*
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
  decisionHandler(WKNavigationResponsePolicyAllow);
}
*/
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  [self checkNeedShowProgressView];
}

- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  [self removeProgressView];
}

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  [self removeProgressView];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  [self removeProgressView];
}

@end
