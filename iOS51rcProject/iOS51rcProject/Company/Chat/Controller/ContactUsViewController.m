//
//  ContactUsViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/24.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "ContactUsViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface ContactUsViewController ()<WKNavigationDelegate>

@end

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [webView setNavigationDelegate:self];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/company/help/contactus?caMainId=%@&code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
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
    if ([url rangeOfString:@"tel"].location != NSNotFound) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", [url stringByReplacingOccurrencesOfString:@"tel:" withString:@""]]]];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
        decisionHandler(WKNavigationActionPolicyAllow);
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

