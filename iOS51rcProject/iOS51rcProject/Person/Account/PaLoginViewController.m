//
//  PaLoginViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/5.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "PaLoginViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "ForgetPasswordViewController.h"
#import "WKNavigationController.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "JPUSHService.h"
#import "AgreementViewController.h"

@interface PaLoginViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation PaLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
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

- (IBAction)loginClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtUsername.text.length == 0) {
        [self.view makeToast:self.txtUsername.placeholder];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self.view makeToast:self.txtPassword.placeholder];
        return;
    }
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Login" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"userName", self.txtPassword.text, @"passWord", [USER_DEFAULT objectForKey:@"provinceId"], @"provinceID", @"ismobile:IOS", @"browser", @"0", @"autoLogin", [JPUSHService registrationID], @"jpushId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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

- (IBAction)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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
        }
        else if ([result isEqual:@"-1"]) {
            [self.view makeToast:@"您今天的登录次数已超过20次的限制，请明天再来"];
        }
        else if ([result isEqual:@"-2"]) {
            [self.view makeToast:@"请提交意见反馈向我们反映，谢谢配合"];
        }
        else if ([result isEqual:@"-3"]) {
            [self.view makeToast:@"提交错误，请检查您的网络链接，并稍后重试"];
        }
        else if ([result isEqual:@"0"]) {
            [self.view makeToast:@"用户名或密码错误，请重新输入"];
        }
        else {
            [self.view makeToast:@"您今天的登录次数已超过20次的限制，请明天再来"];
        }
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
