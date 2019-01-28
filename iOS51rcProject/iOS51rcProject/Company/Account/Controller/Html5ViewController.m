//
//  Html5ViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/2.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "Html5ViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface Html5ViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) NSURL *url;
@end

@implementation Html5ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"shareClick"];
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [webView setNavigationDelegate:self];
    
    UIButton *btnShare = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnShare.widthAnchor constraintEqualToConstant:25].active = YES;
    [btnShare.heightAnchor constraintEqualToConstant:25].active = YES;
    [btnShare setImage:[UIImage imageNamed:@"img_share.png"] forState:UIControlStateNormal];
    [btnShare.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnShare addTarget:self action:@selector(shareClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnShare];
    
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/personal/cpjob%@.html", [[USER_DEFAULT valueForKey:@"subsite"] stringByReplacingOccurrencesOfString:@"m." withString:@"www."], self.secondId]];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        
    }];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    if ([message.name isEqualToString:@"shareClick"]) {
        [self shareClick];
    }
}

- (void)shareClick {
    NSString *title = [NSString stringWithFormat:@"快看！“%@”炫酷招聘页面-%@", [self.companyData objectForKey:@"Name"], [USER_DEFAULT objectForKey:@"subsitename"]];
    [Common share:title content:@"我们正在招募小伙伴，一流的团队需要一流的你！" url:self.url.absoluteString imageUrl:[self.companyData objectForKey:@"LogoFile"]];
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
