//
//  CompanyRenzhengViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/4/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CompanyRenzhengViewController.h"
#import "WXApi.h"
#import "PayWayModel.h"
#import "Common.h"

@import WebKit;
@interface CompanyRenzhengViewController ()<WKNavigationDelegate, WKScriptMessageHandler,WKUIDelegate>
@property (nonatomic, strong) WKWebView *webView;

@end

@implementation CompanyRenzhengViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *statusView = [UIView new];
    [self.view addSubview:statusView];
    statusView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .heightIs(HEIGHT_STATUS);
    statusView.backgroundColor = UIColorFromHex(0x6600C5);
    
    //配置控制器
    WKWebViewConfiguration *configuration =
    [[WKWebViewConfiguration alloc] init];
    configuration.userContentController = [WKUserContentController new];
    // 配置js调用统一参数
    [configuration.userContentController addScriptMessageHandler:self name:@"WeiXinPay"];
    
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, HEIGHT_STATUS, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS) configuration:configuration];
    [webView setUIDelegate:self];
    [webView setNavigationDelegate:self];
    
    NSURL *url;
    url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/company/cer/status?caMainID=%@&Code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [webView loadRequest:request];
    [self.view addSubview:webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    self.webView = webView;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation{
    [SVProgressHUD show];
    NSString *requestString = [[self.webView.URL absoluteString] lowercaseString];
    if([requestString containsString:@"//m.qlrc.com/company/sys/sysset"]){
        [SVProgressHUD dismiss];
        [self.navigationController popViewControllerAnimated:YES];
        [webView stopLoading];
    }else if ([requestString containsString:@"/company/sys/login"]){
        NSURL *url;
        url = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/company/cer/status?caMainID=%@&Code=%@", [USER_DEFAULT valueForKey:@"subsite"], CAMAINID, CAMAINCODE]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
}

//收到服务器重定向请求后调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation{
    NSString *requestString = [[self.webView.URL absoluteString] lowercaseString];
    
    if([requestString containsString:@"normalcerperson"] && (![requestString containsString:@"IosApp"] && ![requestString containsString:@"iosapp"])){
        [webView stopLoading];

        NSString *newUrl = [NSString stringWithFormat:@"%@?%@",requestString,@"IosApp=1"];
        NSURL *url = [NSURL URLWithString:newUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [webView loadRequest:request];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    self.title = webView.title;
    self.view.backgroundColor = UIColorFromHex(0x6600C5);
    [SVProgressHUD dismiss];
}

#pragma mark - WKUIDelegate
// 拦截系统弹出的confirm
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    if ([message.name isEqualToString:@"WeiXinPay"]) {
        DLog(@"调用支付");
        [self getAppPayOrder];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayFailed) name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder) name:NOTIFICATION_WXPAYSUCCESS object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYSUCCESS object:nil];
}
#pragma mark - 统一下单接口
- (void)getAppPayOrder{
    [SVProgressHUD show];
    // ip地址
    NSString *ipStr = [Common getIPaddress];
    
    NSDictionary *paramDict = @{@"caMainID":CAMAINID,
                                @"code":CAMAINCODE,
                                @"cpmainID":CPMAINID,
                                @"mobileIP":ipStr,
                                @"payFrom":@"4"
                                };
    //  URL_GETAPPPAYORDER
    [AFNManager requestCpWithMethod:POST ParamDict:paramDict url:@"GetCompanyCerAppPaystring" tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        [self wxpayParamData:(NSString *)dataDict];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 调用微信支付SDK
- (void)wxpayParamData:(NSString *)dataStr{
    NSDictionary *dataDict = [CommonTools translateJsonStrToDictionary:dataStr];
    
    //需要创建这个支付对象
    PayReq *req   = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = [dataDict objectForKey:@"appid"];
    
    // 商家id，在注册的时候给的
    req.partnerId =  [dataDict objectForKey:@"partnerid"];
    
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId  =  [dataDict objectForKey:@"prepayid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:dataDict[@"outTradeNo"] forKey:KEY_PAYORDERNUM];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package   =  [dataDict objectForKey:@"package"];
    
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr  =  [dataDict objectForKey:@"noncestr"];
    
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp =  [dataDict objectForKey:@"timestamp"];
    req.timeStamp = stamp.intValue;
    
    // 这个签名也是后台做的
    req.sign =  [dataDict objectForKey:@"sign"];
    
    //发送请求到微信，等待微信返回onResp
    [WXApi sendReq:req];
}


#pragma mark - 支付宝/微信查询支付结果
- (void)InquireWeiXinOrder{
    
    NSDictionary *paramDict = @{
                                @"caMainId":CAMAINID,
                                @"code":CAMAINCODE,
                                @"cpMainId":CPMAINID
                                };
    [AFNManager requestCpWithMethod:POST ParamDict:paramDict url:@"InquireWeiXinOrder" tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        NSString *result = (NSString *)dataDict;
        if (result != nil && [result isEqualToString:@"1"]) {// 支付成功
            
            [self wxpaySuccess];
        }else{// 支付失败
            [self wxpayFailed];
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

- (void)wxpayFailed{
    [RCToast showMessage:@"微信支付失败"];
    
    // GCD延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString *newUrl = [NSString stringWithFormat:@"%@?%@",@"https://m.qlrc.com/company/cer/WeiXinCer",@"IosApp=1"];
        NSURL *url = [NSURL URLWithString:newUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    });
    
    
}
- (void)wxpaySuccess{
    [RCToast showMessage:@"微信支付成功"];
    
    // GCD延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
        NSString *newUrl = [NSString stringWithFormat:@"%@?%@",@"https://m.qlrc.com/company/cer/WeiXinCer",@"IosApp=1"];
        NSURL *url = [NSURL URLWithString:newUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    });
}
@end
