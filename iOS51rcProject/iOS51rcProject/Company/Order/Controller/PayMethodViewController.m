//
//  PayMethodViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/24.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "PayMethodViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface PayMethodViewController ()<WKNavigationDelegate>

@end

@implementation PayMethodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT)];
    [webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/order/paymethod?caMainId=%@&code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove(); $('.TopNav').remove(); $('.AccountTop').css('margin-top', '0')" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
