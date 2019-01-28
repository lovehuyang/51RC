//
//  AgreementViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/9.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "AgreementViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface AgreementViewController ()<WKNavigationDelegate>

@end

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"用户协议";
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/personal/sys/agreement", [USER_DEFAULT valueForKey:@"subsite"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

@end
