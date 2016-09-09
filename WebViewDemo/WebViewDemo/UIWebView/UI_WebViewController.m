//
//  UI_WebViewController.m
//  WebViewDemo
//
//  Created by Yincheng on 16/9/8.
//  Copyright © 2016年 Yincheng. All rights reserved.
//

#import "UI_WebViewController.h"

@interface UI_WebViewController () <UIWebViewDelegate>

@property(nonatomic, strong) UIWebView *webView;
@property(nonatomic, strong) NSURL *URL;

@end

@implementation UI_WebViewController

#pragma mark - Init & Memory
- (void)dealloc {
  _webView.delegate = nil;
}

- (instancetype)init {
  if (self = [super init]) {
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
- (BOOL)injectScript:(NSString *)script {
  NSString *retValue = [self.webView stringByEvaluatingJavaScriptFromString:script];
  return retValue != nil;
}

- (void)rightBarAction:(id)sender {
  NSString *script = [NSString stringWithFormat:@"dialogWeb('%@', '%@')", @"提示", @"测试弹出框"];
  [self injectScript:script];
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
  NSString *scheme = request.URL.scheme;
  NSString *query = request.URL.query ;
  
  NSArray *array = [query componentsSeparatedByString:@"&"];

  if ([scheme isEqualToString:@"alert"]) {
    NSString *title = nil;
    NSString *text = nil;

    for (NSString *str in array) {
      NSArray *kv = [str componentsSeparatedByString:@"="];
      if (kv.count >= 2) {
        NSString *transString = [NSString stringWithString:[kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

        if ([kv[0] isEqualToString:@"title"]) {
          title = transString;
        } else if ([kv[0] isEqualToString:@"text"]) {
          text = transString;
        }
      }
    }
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];

    return NO;
  } else if ([scheme isEqualToString:@"push"]) {
    NSString *urlString = nil;

    for (NSString *str in array) {
      NSArray *kv = [str componentsSeparatedByString:@"="];
      if (kv.count >= 2) {
        if ([kv[0] isEqualToString:@"url"]) {
          NSString *transString = [NSString stringWithString:[kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
          urlString = transString;
        }
      }
    }
    if (urlString.length > 0) {
      UI_WebViewController *controller = [[UI_WebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
      [self.navigationController pushViewController:controller animated:YES];
      return NO;
    }
  } else if ([scheme isEqualToString:@"close"]) {
    [self.navigationController popViewControllerAnimated:YES];
    return NO;
  }
  return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
  // Inject ui_dialog.js
  [self injectScript:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ui_dialog" ofType:@"js"]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
  self.title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
  // Inject ui_dialog.js
  [self injectScript:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ui_dialog" ofType:@"js"]
                                               encoding:NSUTF8StringEncoding
                                                  error:nil]];
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
