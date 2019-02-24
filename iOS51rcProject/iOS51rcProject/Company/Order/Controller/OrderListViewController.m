//
//  OrderListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/24.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "OrderListViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
#import "OrderDetailViewController.h"

@interface OrderListViewController ()<WKNavigationDelegate>

@end

@implementation OrderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT)];
    [self.webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/order/orderlist?caMainId=%@&code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.webView reload];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove(); $('.TopNav').remove(); $('.AccountTop').css('margin-top', '0')" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    NSString *url = [[navigationAction.request.URL absoluteString] lowercaseString];
    if ([url rangeOfString:@"orderdetail"].location != NSNotFound) {
        NSString *orderId = [url substringFromIndex:[url rangeOfString:@"?id="].location + 4];
        OrderDetailViewController *orderDetailCtrl = [[OrderDetailViewController alloc] init];
        orderDetailCtrl.orderId = orderId;
        [self.navigationController pushViewController:orderDetailCtrl animated:YES];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
