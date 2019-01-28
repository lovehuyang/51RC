//
//  AccountAllotViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/30.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "OrderApplyViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
#import "OrderDetailViewController.h"
#import "UIView+Toast.h"
@import WebKit;

@interface OrderApplyViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
@end

@implementation OrderApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([self.urlString rangeOfString:@"vip"].location != NSNotFound) {
        self.title = @"VIP套餐";
    }
    else if ([self.urlString rangeOfString:@"ordertype=10"].location != NSNotFound) {
        self.title = @"职位并发数";
    }
    else if ([self.urlString rangeOfString:@"ordertype=9"].location != NSNotFound) {
        self.title = @"简历下载数";
    }
    else if ([self.urlString rangeOfString:@"ordertype=11"].location != NSNotFound) {
        self.title = @"用户数";
    }
    else if ([self.urlString rangeOfString:@"ordertype=14"].location != NSNotFound) {
        self.title = @"短信数";
    }
    else if ([self.urlString rangeOfString:@"adtype=22"].location != NSNotFound) {
        self.title = @"职位置顶";
    }
    else if ([self.urlString rangeOfString:@"adtype=15"].location != NSNotFound) {
        self.title = @"职位刷新";
    }
    else if ([self.urlString rangeOfString:@"adtype=21"].location != NSNotFound) {
        self.title = @"首页6/6图片展示";
    }
    else if ([self.urlString rangeOfString:@"adtype=20"].location != NSNotFound) {
        self.title = @"首页3/6图片展示";
    }
    else if ([self.urlString rangeOfString:@"adtype=23"].location != NSNotFound) {
        self.title = @"首页双倍高度2/6图片展示";
    }
    else if ([self.urlString rangeOfString:@"adtype=5"].location != NSNotFound) {
        self.title = @"首页2/6图片展示";
    }
    else if ([self.urlString rangeOfString:@"adtype=4"].location != NSNotFound) {
        self.title = @"首页1/6图片展示";
    }
    else if ([self.urlString rangeOfString:@"adtype=7"].location != NSNotFound) {
        self.title = @"首页知名企业";
    }
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [self.webView setNavigationDelegate:self];
    [self.webView setUIDelegate:self];
    
    NSURL *urlWithParams = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@caMainId=%@&code=%@", self.urlString, ([self.urlString rangeOfString:@"?"].location == NSNotFound ? @"?" : @"&"), CAMAINID, CAMAINCODE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:urlWithParams];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_back"] style:UIBarButtonItemStyleDone target:self action:@selector(webGoBack)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)webGoBack {
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust='90%'; $('header').remove(); $('.TopNav').remove(); $('.AccountTop').css('margin-top', '0')" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
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
        
        NSMutableArray *arrController = [[NSMutableArray alloc] initWithArray:self.navigationController.viewControllers];
        for (UIViewController *vc in arrController) {
            if ([vc isKindOfClass:[OrderApplyViewController class]]) {
                [arrController removeObject:vc];
                break;
            }
        }
        [self.navigationController setViewControllers:arrController];
        decisionHandler(WKNavigationActionPolicyCancel);
    }
    else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
        completionHandler();
    }])];
    [self presentViewController:alertController animated:YES completion:nil];
    
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

