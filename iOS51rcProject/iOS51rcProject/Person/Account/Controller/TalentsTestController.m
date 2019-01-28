//
//  TalentsTestController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/6.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "TalentsTestController.h"
#import "MyTalentsTestViewController.h"
#import <WebKit/WebKit.h>
#import "BarButtonItem.h"

@interface TalentsTestController ()<WKNavigationDelegate, WKScriptMessageHandler>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation TalentsTestController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[BarButtonItem alloc]initWithTitle:@"我的测评" style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnClick)];
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

- (void)rightBtnClick{

    MyTalentsTestViewController *mtvc = [MyTalentsTestViewController new];
    mtvc.urlString = @"http://m.qlrc.com/personal/assess/mytest";
    mtvc.webView = self.webView;
    [self.navigationController pushViewController:mtvc animated:NO];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"popView"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [self.webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@%@", [USER_DEFAULT valueForKey:@"subsite"],self.urlString]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}
@end
