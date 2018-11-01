//
//  AccountAllotViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/29.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "OrderDetailViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
#import "UIView+Toast.h"
@import WebKit;

@interface OrderDetailViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@end

@implementation OrderDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"订单详情";
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"uploadImg"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [self.webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/order/orderdetail?id=%@&caMainId=%@&code=%@", [USER_DEFAULT valueForKey:@"subsite"], self.orderId, CAMAINID, CAMAINCODE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_back"] style:UIBarButtonItemStyleDone target:self action:@selector(webGoBack)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove(); $('.TopNav').remove(); $('.AccountTop').css('margin-top', '0')" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)webGoBack {
    [self.webView evaluateJavaScript:@"$('#divOrderFlow:hidden').length" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        if ([[NSString stringWithFormat:@"%@", response] isEqualToString:@"0"]) {
            [self.webView evaluateJavaScript:@"$('#divOrderFlow').hide();" completionHandler:nil];
        }
        else {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"uploadImg"]) {
        [self.view makeToast:@"请在电脑端上传汇款凭证或联系客服"];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
