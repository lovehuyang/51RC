//
//  CpMobileVerifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/19.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CpMobileVerifyViewController.h"
#import "WKButton.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"

@interface CpMobileVerifyViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSTimer *timer;
@property NSInteger sendSecond;
@end

@implementation CpMobileVerifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"手机号认证";
    self.sendSecond = 180;
    [Common changeFontSize:self.view];
    self.txtMobile.text = self.mobile;
    [self.btnOpen.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [USER_DEFAULT setObject:[Common stringFromDate:[NSDate date] formatType:@"yyyy-MM-dd"] forKey:@"cpMobileVerifyDate"];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tipsClick)];
    self.lbTips.userInteractionEnabled = YES;
    [self.lbTips addGestureRecognizer:tap];
}

- (IBAction)openClick:(id)sender {
    if (self.btnOpen.tag == 1) {
        [self.btnOpen setImage:[UIImage imageNamed:@"img_cpcheck2.png"] forState:UIControlStateNormal];
        [self.btnOpen setTag:0];
    }
    else {
        [self.btnOpen setImage:[UIImage imageNamed:@"img_cpcheck1.png"] forState:UIControlStateNormal];
        [self.btnOpen setTag:1];
    }
}

- (IBAction)codeClick:(id)sender {
    [self.view endEditing:YES];
    if (self.btnCode.tag == 1) {
        return;
    }
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请输入正确的手机号"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMobileVerifyCode" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", self.txtMobile.text, @"strMobile", [USER_DEFAULT objectForKey:@"subsitename"], @"subsiteName", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)confirmClick:(id)sender {
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请输入正确的手机号"];
        return;
    }
    if (self.txtCode.text.length == 0) {
        [self.view makeToast:@"请输入验证码"];
        return;
    }
    if (![Common isPureInt:self.txtCode.text]) {
        [self.view makeToast:@"验证码格式不正确"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UpdateCpMobileByVerify" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", self.txtMobile.text, @"strMobile", self.txtCode.text, @"strVerifyCode", (self.btnOpen.tag == 1 ? @"0" : @"1"), @"intMobileHidden", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if ([result isEqualToString:@"1"]) {
            [self.btnCode setTag:1];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInterval) userInfo:nil repeats:YES];
        }
        else if ([result isEqualToString:@"0"]) {
            [self.view makeToast:@"该手机号发送验证码次数过多"];
            return;
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view makeToast:@"该IP今天注册的次数过多"];
            return;
        }
        else if ([result isEqualToString:@"-2"] || [result isEqualToString:@"-4"]) {
            [self.view makeToast:@"您输入手机号已经认证过，无法重复认证"];
            return;
        }
        else if ([result rangeOfString:@"s"].location != NSNotFound) {
            [self.btnCode setTag:1];
            self.sendSecond = [[result stringByReplacingOccurrencesOfString:@"s" withString:@""] integerValue];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInterval) userInfo:nil repeats:YES];
        }
    }
    else if (request.tag == 2) {
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"手机号认证成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view makeToast:@"短信验证码错误"];
            return;
        }
        else {
            [self.view makeToast:@"系统错误，请稍后再试"];
            return;
        }
    }
}

- (void)sendInterval {
    self.sendSecond--;
    if (self.sendSecond <= 0) {
        [self.btnCode setTag:0];
        [self.btnCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.sendSecond = 180;
        self.timer = nil;
    }
    else {
        [self.btnCode setTitle:[NSString stringWithFormat:@"%lds", self.sendSecond] forState:UIControlStateNormal];
    }
}

- (void)tipsClick {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.mohrss.gov.cn/SYrlzyhshbzb/dongtaixinwen/buneiyaowen/201708/t20170818_275898.html"]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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
