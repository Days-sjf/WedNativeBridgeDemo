//
//  ViewController.m
//  CordovaWKWebViewDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import "ViewController.h"
#import "WebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)action:(id)sender {
  NSURL *rootURL = [[NSBundle mainBundle].resourceURL URLByAppendingPathComponent:@"www"];
  NSURL *startURL = [rootURL URLByAppendingPathComponent:@"index.html"];

  WebViewController *controller = [[WebViewController alloc] initWithURL:startURL];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
