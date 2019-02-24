//
//  AccountAllotViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/19.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  配额管理页面

#import "AccountQuotaViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
#import "OrderApplyViewController.h"
@import WebKit;

@interface AccountQuotaViewController ()<WKNavigationDelegate>

@end

@implementation AccountQuotaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 44)];
    [webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/ca/quotamanage?caMainId=%@&code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
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

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [[navigationAction.request.URL absoluteString] lowercaseString];
    if ([url rangeOfString:@"applysuborder"].location != NSNotFound) {
        OrderApplyViewController *orderApplyCtrl = [[OrderApplyViewController alloc] init];
        orderApplyCtrl.urlString = url;
        [self.navigationController pushViewController:orderApplyCtrl animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
