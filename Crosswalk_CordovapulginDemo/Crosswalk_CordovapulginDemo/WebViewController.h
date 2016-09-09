//
//  WebViewController.h
//  Crosswalk_CordovapulginDemo
//
//  Created by YinCheng on 16/9/9.
//  Copyright © 2016年 YinCheng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import <XWalkView/XWalkView.h>
#import <Cordova/Cordova.h>

@interface WebViewController : CDVViewController

@property(nonatomic, assign) BOOL showProgress;

- (instancetype)initWithURL:(NSURL *)URL;
@end
