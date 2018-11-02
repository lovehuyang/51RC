//
//  PaRegisterViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/6.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "PaRegisterViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "JPUSHService.h"
#import "AgreementViewController.h"
#import "WKNavigationController.h"
#import "RoleViewController.h"

@interface PaRegisterViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSTimer *timer;
@property int sendSecond;
@end

@implementation PaRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Common changeFontSize:self.view];
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(0, 0, 26, 44);
    [closeBtn setImage:[UIImage imageNamed:@"p_registerClose"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:closeBtn];
    self.navigationItem.leftBarButtonItem = item;
    [self.btnOneMinute setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnOneMinute.layer setBorderWidth:1];
    [self.btnOneMinute.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnOneMinute.layer setCornerRadius:VIEW_H(self.btnOneMinute) / 5];
    self.sendSecond = 180;
    self.title = @"注册";
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self.navigationController.navigationBar setHidden:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self.runningRequest cancel];
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

- (IBAction)certificateClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if (sender.tag == 1) {
        return;
    }
    if (![Common checkMobile:self.txtUsername.text]) {
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaMobileVerifyCode" Params:[NSDictionary dictionaryWithObjectsAndKeys:[Common enMobile:self.txtUsername.text], @"mobile", [USER_DEFAULT valueForKey:@"subsitename"], @"subsitename", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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

- (IBAction)registerClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtUsername.text.length == 0) {
        [self.view makeToast:@"请输入手机号"];
        return;
    }
    if (![Common checkMobile:self.txtUsername.text]) {
        [self.view makeToast:@"请输入正确的手机号"];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self.view makeToast:@"请输入密码"];
        return;
    }
    if(self.txtPassword.text.length < 6 || self.txtPassword.text.length > 20) {
        [self.view makeToast:@"密码长度为6-20个字符"];
        return;
    }
    if (![Common checkPassword:self.txtPassword.text]) {
        [self.view makeToast:@"密码只能使用字母、数字、横线、下划线、点"];
        return;
    }
    if ([Common checkMobile:self.txtUsername.text]) {
        if (self.txtMobileCer.text.length == 0) {
            [self.view makeToast:@"请输入短信验证码"];
            return;
        }
        if (![Common isPureInt:self.txtMobileCer.text]) {
            [self.view makeToast:@"请输入正确的短信验证码"];
            return;
        }
    }
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Register" Params:[NSDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"username", self.txtMobileCer.text, @"verifycode", self.txtPassword.text, @"password", [USER_DEFAULT valueForKey:@"provinceId"], @"provinceid", @"6", @"registermod", [JPUSHService registrationID], @"jpushId", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) { //获取短信验证码
        switch ([result intValue]) {
            case 1:
                [self.btnMobileCer setTag:1];
                self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInterval) userInfo:nil repeats:YES];
                break;
            case 0:
                [self.view makeToast:@"该手机号发送短信验证码次数过多"];
                break;
            case -1:
                [self.view makeToast:@"该ip今天发送短信验证码次数过多"];
                break;
            case -2:
                [self.view makeToast:@"您输入手机号已经存在，请重新输入"];
                break;
            case -3:
                [self.view makeToast:@"短信发送失败，请稍后重试"];
                break;
            case -4:
                [self.view makeToast:@"您输入的手机号已经存在"];
                break;
            case -5:
                [self.view makeToast:@"您在180s内获取过验证码，请稍后重试"];
                break;
            default:
                break;
        }
    }
    else if (request.tag == 2) { //注册
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
            
            UITabBarController *personCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"personView"];
            [personCtrl setSelectedIndex:4];
            [self presentViewController:personCtrl animated:YES completion:^{
                [USER_DEFAULT setObject:@"1" forKey:@"positioned"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"paLoginSuccess" object:self];
            }];
        }
        else if ([result isEqualToString:@"-3"]) {
            [self.view makeToast:@"用户注册失败"];
        }
        else if ([result isEqualToString:@"-6"]) {
            [self.view makeToast:@"短信验证码错误"];
        }
    }
}

- (void)sendInterval {
    self.sendSecond--;
    if (self.sendSecond == 0) {
        [self.btnMobileCer setTag:0];
        [self.btnMobileCer setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.sendSecond = 180;
        self.timer = nil;
    }
    else {
        [self.btnMobileCer setTitle:[NSString stringWithFormat:@"%ds", self.sendSecond] forState:UIControlStateNormal];
    }
}

#pragma mark - 关闭事件
- (void)closeBtnClick{
    RoleViewController *roleCtrl = [[RoleViewController alloc] init];
    [self presentViewController:roleCtrl animated:YES completion:nil];
}


@end
