//
//  FeedbackViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/9.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "FeedbackViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface FeedbackViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@end

@implementation FeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"意见反馈";
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"popView"];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [webView setNavigationDelegate:self];
    NSURL *url;
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/personal/sys/feedback?caMainId=%@&code=%@&app=1", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
    }
    else {
        url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/personal/sys/feedback?paMainId=%@&code=%@&app=1", [USER_DEFAULT valueForKey:@"subsite"], PAMAINID, [USER_DEFAULT valueForKey:@"paMainCode"]]];
    }
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
    if ([[[webView.URL absoluteString] lowercaseString] rangeOfString:@"success"].location != NSNotFound) {
        [webView evaluateJavaScript:@"$('.ConfirmButton').attr('onclick', '').click(function(){window.webkit.messageHandlers.popView.postMessage('')})" completionHandler:nil];
    }
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [[navigationAction.request.URL absoluteString] lowercaseString];
    if ([url rangeOfString:@"index"].location != NSNotFound) {
        [self.navigationController popViewControllerAnimated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
