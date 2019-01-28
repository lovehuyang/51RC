//
//  MultiSelectViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/11.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "MultiSelectViewController.h"
#import "CommonMacro.h"
#import "WKLoadingView.h"
@import WebKit;

@interface MultiSelectViewController ()<WKNavigationDelegate, WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@end

@implementation MultiSelectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.accountType == 0) {
        self.accountType = MultiSelectAccountTypePersonal;
    }
    if (self.selId == nil) {
        self.selId = @"";
    }
    if (self.selValue == nil) {
        self.selValue = @"";
    }
    if (self.title == nil) {
        if (self.selectType == MultiSelectTypeRegion) {
            self.title = @"期望工作地点";
        }
        else if (self.selectType == MultiSelectTypeJobType) {
            self.title = @"期望职位类别";
        }
        else if (self.selectType == MultiSelectTypeIndustry) {
            self.title = @"期望从事行业";
        }
    }
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveMulti)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"saveMulti"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) configuration:config];
    [self.webView setNavigationDelegate:self];
    [self.webView.scrollView setBounces:NO];
    NSString *urlString = [NSString stringWithFormat:@"http://%@/personal/cv/multiselectapp?id=%@&value=%@&type=%u&account=%u", [USER_DEFAULT valueForKey:@"subsite"], self.selId, self.selValue, self.selectType, self.accountType];

    urlString = [urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.view addSubview:self.webView];
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSArray *arraySelect = [message.body componentsSeparatedByString:@"|"];
    [self.delegate getMultiSelect:self.selectType arraySelect:arraySelect];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveMulti {
    [self.webView evaluateJavaScript:@"saveMulti()" completionHandler:nil];
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
