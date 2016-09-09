//
//  WebViewController.m
//  CordovaWKWebViewDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "WebViewController.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()

@property(nonatomic, strong) NSURL *URL;
@property(nonatomic, strong) UIProgressView *progressView;
@end

@implementation WebViewController

#pragma mark - Init & Memory
- (void)dealloc {
  NSLog(@"%@ dealloced", NSStringFromClass([self class]));

  if ([self.webView isKindOfClass:[WKWebView class]]) {
    WKWebView *wk_webView = (WKWebView *)self.webView;
    @try {
      [wk_webView removeObserver:self forKeyPath:@"estimatedProgress"];
      [wk_webView removeObserver:self forKeyPath:@"title"];
    } @catch (NSException *exception) {
    }
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

  if ([self.webView isKindOfClass:[WKWebView class]]) {
    WKWebView *wk_webView = (WKWebView *)self.webView;
    [wk_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [wk_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:nil];
  }

  [self.webViewEngine loadRequest:[NSURLRequest requestWithURL:self.URL]];
}


#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString*, id> *)change context:(void *)context {
  if (object == self.webView && [self.webView isKindOfClass:[WKWebView class]]) {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
      double progress = [[change objectForKey:@"new"] doubleValue];

      NSLog(@"--progress is %f--", progress);
      [self.progressView setProgress:progress animated:YES];
    } else if ([keyPath isEqualToString:@"title"]) {
      NSString *title = [change objectForKey:@"new"];
      
      self.title = title;
    }
  }
}

#pragma mark - Private
- (void)checkNeedShowProgressView {
  self.progressView.frame = CGRectMake(0, 64, self.view.bounds.size.width, 4);
  self.progressView.progress = 0.0;
  [self.view addSubview:self.progressView];
}

- (void)removeProgressView {
  if (!_progressView.superview) {
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
- (UIProgressView *)progressView {
  if (!_progressView) {
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 4)];
    _progressView.progressTintColor = [UIColor redColor];
    _progressView.trackTintColor = [UIColor whiteColor];
  }
  return _progressView;
}
@end

