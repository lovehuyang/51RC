//
//  AccountInfoViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/3.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  用户信息页面

#import "AccountInfoViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
@import WebKit;

@interface AccountInfoViewController ()<WKNavigationDelegate>

@end

@implementation AccountInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户信息";
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/ca/userinfomodify?camainid=%@&code=%@&modifycamainid=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE, self.caMainId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.forceModify) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setHidesBackButton:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove(); $('.bodyMain').css('padding-top', '0')" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
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
