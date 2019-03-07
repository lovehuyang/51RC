//
//  MyTalentsTestViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/25.
//  Copyright © 2018年 Jerry. All rights reserved.
//  废了

#import "RCRootViewController.h"
#import <WebKit/WebKit.h>

@interface MyTalentsTestViewController : RCRootViewController
@property (nonatomic , strong)NSString *urlString;
@property (nonatomic, strong) WKWebView *webView;
@end
