//
//  AccountSafeViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/8.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "AccountSafeViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
@import WebKit;

@interface AccountSafeViewController ()<WKNavigationDelegate>

@end

@implementation AccountSafeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/ca/usernamemodify?camainid=%@&code=%@&modifycamainid=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE, self.caMainId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove();" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    NSString *url = [[navigationAction.request.URL absoluteString] lowercaseString];
    if ([url rangeOfString:@"accountlist"].location != NSNotFound) {
        [self.view.window makeToast:@"修改成功"];
        [self.navigationController popViewControllerAnimated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

@end
