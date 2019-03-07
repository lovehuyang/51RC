//
//  MyTalentsTestViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/25.
//  Copyright © 2018年 Jerry. All rights reserved.
//  废了

#import "MyTalentsTestViewController.h"
#import <WebKit/WebKit.h>

@interface MyTalentsTestViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@end

@implementation MyTalentsTestViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的测评";
    self.webView.frame =CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV);
    NSURL *url = [NSURL URLWithString:self.urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('a:first').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
    
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
