//
//  ViewController.m
//  Crosswalk_CordovapulginDemo
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
  WebViewController *controller = [[WebViewController alloc] init];
  
  [self.navigationController pushViewController:controller animated:YES];
}

@end
