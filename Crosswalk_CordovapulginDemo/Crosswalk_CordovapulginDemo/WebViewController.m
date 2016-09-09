//
//  WebViewController.m
//  Crosswalk_CordovapulginDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "WebViewController.h"
#import <XWalkView/XWalkView-Swift.h>

@interface WebViewController ()

@property(nonatomic, strong) NSURL *URL;

@property(nonatomic, strong) XWalkView *webView;
@property(nonatomic, strong) UIProgressView *progressView;
@end

@implementation WebViewController

#pragma mark - Init & Memory
- (void)dealloc {
  NSLog(@"%@ dealloced", NSStringFromClass([self class]));
  
  _webView.navigationDelegate = nil;

  @try {
    [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
    [_webView removeObserver:self forKeyPath:@"title"];
  } @catch (NSException *exception) {
  }
}

- (instancetype)initWithURL:(NSURL *)URL {
  if (self = [super init]) {
    self.URL = URL;
  }
  return self;
}

#pragma mark - View lifecycle
- (void)viewDidLoad {
  [super viewDidLoad];

  [self.view addSubview:self.webView];

  NSDictionary *mainfestDict = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"manifest" ofType:@"plist"]];
  NSString *startUrlString = mainfestDict[@"start_url"];
  NSArray *xwalkExtensions = mainfestDict[@"xwalk_extensions"];

  for (NSString *name in xwalkExtensions) {
    id ext = nil;
    if ([name isEqualToString:@"xwalk.cordova"]) {
          ext = [XWalkExtensionFactory createExtension:name initializer:@selector(initWithViewController:) arguments:@[self]];
    } else {
      ext = [XWalkExtensionFactory createExtension:name];
    }
    
    if (ext) {
      [self.webView loadExtension:ext namespace:name];
    }
  }
  
  // 自定义的extension @"xwalk.demo.dialog"
  NSString *myextensionName = @"xwalk.demo.dialog";
  [XWalkExtensionFactory register:myextensionName cls:NSClassFromString(@"Dialog")];
  id ext = [XWalkExtensionFactory createExtension:myextensionName];
  if (ext) {
    [self.webView loadExtension:ext namespace:myextensionName];
  }

  NSURL *rootURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"www"];
  NSURL *startURL = [rootURL URLByAppendingPathComponent:startUrlString];

  NSError *error = nil;
  if ([startURL checkResourceIsReachableAndReturnError:&error]) {
    [self.webView loadFileURL:startURL allowingReadAccessToURL:rootURL];
  } else {
    [self.webView loadHTMLString:error.description baseURL:nil];
  }
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

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
  NSURL *url = navigationAction.request.URL;
  
  if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
    if ([url.scheme isEqualToString:@"http"] || [url.scheme isEqualToString:@"https"]) {
      if (![url.absoluteString isEqualToString:self.URL.absoluteString ]) {
        WebViewController *controller = [[WebViewController alloc] initWithURL:url];
        [self.navigationController pushViewController:controller animated:YES];
        
        return decisionHandler(WKNavigationActionPolicyCancel);
      }
    }
  }
  
  return decisionHandler(WKNavigationActionPolicyAllow);
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

#pragma mark - Accessors
- (XWalkView *)webView {
  if (!_webView) {
    _webView = [[XWalkView alloc] initWithFrame:self.view.bounds configuration:[[WKWebViewConfiguration alloc] init]];
    _webView.navigationDelegate = self;
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
@end
