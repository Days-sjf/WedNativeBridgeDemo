//
//  ViewController.m
//  WebViewDemo
//
//  Created by Yincheng on 16/9/8.
//  Copyright © 2016年 Yincheng. All rights reserved.
//

#import "ViewController.h"
#import "WK_WebViewController.h"
#import "UI_WebViewController.h"
#import "UI_JSCore_ViewController.h"

@interface ViewController () <WK_WebViewControllerDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSArray *itemArray;
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.itemArray = @[@{@"class": @"UI_WebViewController", @"source": @"ui_index.html"},
                     @{@"class": @"UI_JSCore_ViewController", @"source": @"ui_jscore_index.html"},
                     @{@"class": @"WK_WebViewController", @"source": @"wk_index.html"}];
  
  [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource & UITableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.itemArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
  if (!cell) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
  }
  NSDictionary *itemDict = self.itemArray[indexPath.row];
  cell.textLabel.text = itemDict[@"class"];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  NSDictionary *itemDict = self.itemArray[indexPath.row];
  NSString *classStr = itemDict[@"class"];
  NSString *sourceStr = itemDict[@"source"];

  Class cls = NSClassFromString(classStr);
  if (!cls) {
    return;
  }
  
  if (cls == [WK_WebViewController class]) {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:sourceStr ofType:nil]];

    WK_WebViewController *controller = [[WK_WebViewController alloc] initWithURL:url];
    controller.delegate = self;

    [controller injectScriptMessageHandlerWithNames:@[WK_WebViewScriptName_CloseWebView, WK_WebViewScriptName_PushWebView]];
    [controller injectScriptWithSource:[NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"wk_function" ofType:@"js"]
                                                                 encoding:NSUTF8StringEncoding
                                                                    error:nil]
                         injectionTime:WKUserScriptInjectionTimeAtDocumentEnd];

    [self.navigationController pushViewController:controller animated:YES];
  } else {
    NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:sourceStr ofType:nil]];

    id controller = nil;
    if ([cls instancesRespondToSelector:@selector(initWithURL:)]) {
      controller = [[cls alloc] initWithURL:url];
    } else {
      controller = [[cls alloc] init];
    }
    [self.navigationController pushViewController:controller animated:YES];
  }
}

#pragma mark - WK_WebViewControllerDelegate
- (BOOL)webViewController:(WK_WebViewController *)controller didReceiveScriptMessage:(WKScriptMessage *)message {
  if ([message.name isEqualToString:WK_WebViewScriptName_CloseWebView]) {
    if (self.navigationController.topViewController == controller) {
      [self.navigationController popViewControllerAnimated:YES];
    } else {
      NSMutableArray *viewControlelrs = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
      NSUInteger index = [viewControlelrs indexOfObject:controller];
      if (index != NSNotFound) {
        [viewControlelrs removeObjectAtIndex:index];
      }
      [self.navigationController setViewControllers:viewControlelrs];
    }
    
    return YES;
  } else if ([message.name isEqualToString:WK_WebViewScriptName_PushWebView]) {
    NSString *urlString = message.body;
    
    if (urlString.length > 0) {
      WK_WebViewController *controller = [[WK_WebViewController alloc] initWithURL:[NSURL URLWithString:urlString]];
      [self.navigationController pushViewController:controller animated:YES];
      return YES;
    }
  }
  
  return NO;
}

@end
