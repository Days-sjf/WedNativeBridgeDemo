//
//  UI_WebViewController.h
//  WebViewDemo
//
//  Created by Yincheng on 16/9/8.
//  Copyright © 2016年 Yincheng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UI_WebViewController : UIViewController

- (instancetype)initWithURL:(NSURL *)URL;

- (BOOL)injectScript:(NSString *)script;


@end
