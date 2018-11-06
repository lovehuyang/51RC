//
//  PaLoginViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/5.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  账号密码登录

#import "PaLoginViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "ForgetPasswordViewController.h"
#import "WKNavigationController.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "JPUSHService.h"
#import "AgreementViewController.h"
#import "NavBar.h"
#import "CountdownBtn.h"
#import <WebKit/WebKit.h>

@interface PaLoginViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate>
{
    BOOL isPasswordLogin;// 默认是密码登录
}
@property (nonatomic , strong) NetWebServiceRequest *runningRequest;
@property (nonatomic , strong)UILabel *loginTypeLab;// 显示登录方式的Lab
@property (nonatomic , strong)CountdownBtn *countdownBtn;//倒计时按钮
@end

@implementation PaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isPasswordLogin = YES;
    [self setupUI];// 初始化控件
}

#pragma mark - 初始化页面

- (void)setupUI{
    // 假导航栏
    NavBar *navView = [[NavBar alloc]initWithTitle:@"" leftItem:@"nav_return"];
    [self.view addSubview:navView];
    // 顶部logo图标
    UIImageView *logoImgView = [UIImageView new];
    [self.view addSubview:logoImgView];
    logoImgView.sd_layout
    .centerXEqualToView(self.view)
    .topSpaceToView(navView, -40)
    .widthIs(100)
    .heightEqualToWidth();
    logoImgView.image = [UIImage imageNamed:@"pa_loginphoto.png"];
    // 登录方式显示的lab
    UILabel *loginTypeLab = [UILabel new];
    [self.view addSubview:loginTypeLab];
    loginTypeLab.sd_layout
    .topSpaceToView(logoImgView, 5)
    .centerXEqualToView(logoImgView)
    .widthIs(100)
    .heightIs(20);
    loginTypeLab.text = @"密码登录";
    loginTypeLab.textAlignment = NSTextAlignmentCenter;
    loginTypeLab.font = SMALLERFONT;
    self.loginTypeLab = loginTypeLab;
    
    navView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, -100)
    .bottomSpaceToView(self.view, SCREEN_HEIGHT - HEIGHT_STATUS_NAV);
    __weak typeof(self)weakSelf = self;
    navView.leftItemEvent = ^{
        [weakSelf.navigationController popViewControllerAnimated:YES];;
    };
    
    [Common changeFontSize:self.view];
    [self.navigationController.navigationBar setHidden:YES];
    [self.btnOneMinute setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnOneMinute.layer setBorderWidth:1];
    [self.btnOneMinute.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnOneMinute.layer setCornerRadius:VIEW_H(self.btnOneMinute) / 5];
    
    [self.btnRegister setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnRegister.layer setBorderWidth:1];
    [self.btnRegister.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnRegister.layer setCornerRadius:VIEW_H(self.btnOneMinute) / 5];
    [self.constraintOneMinuteWidth setConstant:SCREEN_WIDTH * 0.55];
    
    // 获取验证码的事件
    [self.getSecurityBtn addTarget:self action:@selector(getVerifyCodeEvent) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - 懒加载
- (CountdownBtn *)countdownBtn{
    if (!_countdownBtn) {
        _countdownBtn = [[CountdownBtn alloc]init];
        _countdownBtn.backgroundColor = [UIColor blueColor];
    }
    return _countdownBtn;
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.runningRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

#pragma mark - 登录事件

- (IBAction)loginClick:(id)sender {
    [self.view endEditing:YES];
    
    if (self.txtUsername.text.length == 0) {
        [RCToast showMessage:self.txtUsername.placeholder];
        return;
    }
    
    if (self.txtPassword.text.length == 0) {
        
        [RCToast showMessage:self.txtPassword.placeholder];
        return;
    }
    if (self.btnAgree.tag == 0) {
        [RCToast showMessage:@"请勾选用户协议"];
        return;
    }
    
    // 密码登录模式
    if (isPasswordLogin) {
        NSDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"userName", self.txtPassword.text, @"passWord", [USER_DEFAULT objectForKey:@"provinceId"], @"provinceID", @"ismobile:IOS", @"browser", @"0", @"autoLogin", [JPUSHService registrationID], @"jpushId", nil];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:URL_LOGIN Params:param viewController:self];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    
    }else{// 验证码登录
        [SVProgressHUD show];
        
        NSDictionary *param = [NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"userName", self.txtPassword.text, @"mobileCerCode", [USER_DEFAULT objectForKey:@"provinceId"], @"provinceID", @"ismobile:IOS", @"browser", @"0", @"autoLogin", [JPUSHService registrationID], @"jpushId", nil];
        
        [AFNManager requestWithMethod:POST ParamDict:param url:URL_LOGINMOBILE tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
            [self loginResult:(NSString *)dataDict];
            [SVProgressHUD dismiss];
        } failureBlock:^(NSInteger errCode, NSString *msg) {
            [SVProgressHUD dismiss];
            [RCToast showMessage:msg];
        }];
    }
}

- (IBAction)forgetPasswordClick:(id)sender {
    ForgetPasswordViewController *forgetPasswordCtrl = [[ForgetPasswordViewController alloc] init];
    WKNavigationController *forgetPasswordNav = [[WKNavigationController alloc] initWithRootViewController:forgetPasswordCtrl];
    forgetPasswordNav.wantClose = YES;
    [self presentViewController:forgetPasswordNav animated:YES completion:nil];
}

- (IBAction)passwordClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [self.txtPassword setSecureTextEntry:NO];
        [sender setBackgroundImage:[UIImage imageNamed:@"img_password1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [self.txtPassword setSecureTextEntry:YES];
        [sender setBackgroundImage:[UIImage imageNamed:@"img_password2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismissKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self loginResult:result];
    }
}

- (IBAction)agreeClick:(UIButton *)sender {
    if (sender.tag == 0) {
        [sender setBackgroundImage:[UIImage imageNamed:@"img_checksmall1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [sender setBackgroundImage:[UIImage imageNamed:@"img_checksmall2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)agreementClick:(UIButton *)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    WKNavigationController *agreementNav = [[WKNavigationController alloc] initWithRootViewController:agreementCtrl];
    agreementNav.wantClose = YES;
    agreementCtrl.title = [NSString stringWithFormat:@"%@个人会员协议", [USER_DEFAULT valueForKey:@"subsitename"]];
    [self presentViewController:agreementNav animated:YES completion:nil];
}

#pragma mark - 切换登录方式

- (IBAction)changeLoginType:(id)sender {
    UIButton *btn = (UIButton *)sender;
    if ([btn.titleLabel.text isEqualToString:@"验证码登录"]) {
        [btn setTitle:@"密码登录" forState:UIControlStateNormal];
        isPasswordLogin = NO;
    }else{
        [btn setTitle:@"验证码登录" forState:UIControlStateNormal];
        isPasswordLogin = YES;
    }
    [self changeUIStatus];
}

#pragma mark - 改变控件的状态

- (void)changeUIStatus{
    if (isPasswordLogin) {
        self.loginTypeLab.text = @"密码登录";
        self.txtUsername.placeholder = @"请输入邮箱或手机号";
        self.txtPassword.placeholder = @"请输入密码";
        self.passwordBtn.hidden = NO;
        self.getSecurityBtn.hidden = YES;
        self.txtPassword.placeholder = @"请输入短信验证码";
        self.txtPassword.text = @"";
        self.txtPassword.secureTextEntry = YES;
        [self.passwordBtn setBackgroundImage:[UIImage imageNamed:@"img_password2.png"] forState:UIControlStateNormal];
    }else{
        self.loginTypeLab.text = @"验证码登录";
        self.txtUsername.placeholder = @"请输入已认证手机号";
        self.txtPassword.placeholder = @"请输入短信验证码";
        self.txtPassword.text = @"";
        self.txtPassword.secureTextEntry = NO;
        self.passwordBtn.hidden = YES;
        self.getSecurityBtn.hidden = NO;
    }
}

#pragma mark - 获取验证码

- (void)getVerifyCodeEvent{
    if (!self.txtUsername.text.length) {
        [RCToast showMessage:self.txtUsername.placeholder];
        return;
    }
    NSDictionary *paramDict = @{@"mobile":self.txtUsername.text,@"subsitename":[USER_DEFAULT objectForKey:@"subsitename"]};
    [SVProgressHUD show];
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETPAMOBILEVERIFYCODELOGIN tableName:nil successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        
        NSInteger result = [(NSString *)dataDict integerValue];
        if (result == 1) {
            [self openCountdown];// 开启倒计时
        }
        [SVProgressHUD dismiss];
        [RCToast showMessage:[Common verifyCodeGetResult:result]];
    
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [RCToast showMessage:msg];
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - 处理登录成功的返回值信息
- (void)loginResult:(NSString *)result{
    
    if ([result rangeOfString:@"|"].location != NSNotFound) {
        NSArray *arrayResult = [result componentsSeparatedByString:@"|"];
        NSString *paMainId = [arrayResult objectAtIndex:0];
        NSString *regDate = [arrayResult objectAtIndex:1];
        NSString *realCode = [NSString stringWithFormat:@"%@%@%@%@%@",[regDate substringWithRange:NSMakeRange(11,2)],
                              [regDate substringWithRange:NSMakeRange(0,4)],[regDate substringWithRange:NSMakeRange(14,2)],
                              [regDate substringWithRange:NSMakeRange(8,2)],[regDate substringWithRange:NSMakeRange(5,2)]];
        
        NSString *code = [Common MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [paMainId longLongValue])]];
        [USER_DEFAULT setValue:paMainId forKey:@"paMainId"];
        [USER_DEFAULT setValue:code forKey:@"paMainCode"];
        [USER_DEFAULT setValue:[arrayResult objectAtIndex:2] forKey:@"provinceId"];
        [USER_DEFAULT setValue:[arrayResult objectAtIndex:3] forKey:@"province"];
        [USER_DEFAULT setValue:[[arrayResult objectAtIndex:4] stringByReplacingOccurrencesOfString:@"www." withString:@"m."] forKey:@"subsite"];
        [USER_DEFAULT setValue:[arrayResult objectAtIndex:5] forKey:@"subsitename"];
        
        UITabBarController *personCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"personView"];
        [personCtrl setSelectedIndex:4];
        [self presentViewController:personCtrl animated:YES completion:^{
            [USER_DEFAULT setObject:@"1" forKey:@"positioned"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"paLoginSuccess" object:self];
        }];
        
    }else if (isPasswordLogin){
        NSInteger resultCode = [result integerValue];
        [RCToast showMessage:[Common loginResult:resultCode]];
        
    }else{
        NSInteger resultCode = [result integerValue];
        [RCToast showMessage:[Common verifyCodeLoginResult:resultCode]];
    }
}

#pragma mark -  发送验证码的倒计时操作
- (void)openCountdown{
    
    __block NSInteger time = 180; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.getSecurityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                
                self.getSecurityBtn.enabled = YES;
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.getSecurityBtn setTitle:[NSString stringWithFormat:@"%lds", (long)time] forState:UIControlStateNormal];
                
                self.getSecurityBtn.enabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}
@end
