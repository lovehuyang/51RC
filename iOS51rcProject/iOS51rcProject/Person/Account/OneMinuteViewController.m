//
//  OneMinuteViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "OneMinuteViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKPopView.h"
#import "MajorViewController.h"
#import "MultiSelectViewController.h"
#import "AgreementViewController.h"
#import "WKNavigationController.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"

@interface OneMinuteViewController ()<UITextFieldDelegate, MajorViewDelete, WKPopViewDelegate, MultiSelectDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) NSTimer *timer;
@property int sendSecond;
@end

@implementation OneMinuteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Common changeFontSize:self.view];
    [self.navigationController.navigationBar setHidden:NO];
    [self.constraintScrollWidth setConstant:(SCREEN_WIDTH - 40)];
    [self.btnLogin setBackgroundColor:[UIColor whiteColor]];
    [self.btnLogin setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnLogin.layer setBorderWidth:1];
    [self.btnLogin.layer setBorderColor:[NAVBARCOLOR CGColor]];
    
    [self.btnVerifyCode setBackgroundColor:[UIColor whiteColor]];
    [self.btnVerifyCode.titleLabel setFont:DEFAULTFONT];
    [self.btnVerifyCode setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [self.btnVerifyCode.layer setBorderColor:[NAVBARCOLOR CGColor]];
    [self.btnVerifyCode.layer setBorderWidth:1];
    
    self.sendSecond = 180;
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"strPwd", @"", @"strVerifyCode", [USER_DEFAULT objectForKey:@"provinceId"], @"provinceid", [JPUSHService registrationID], @"jpushId", @"6", @"registermod", @"", @"Name", @"", @"Gender", @"", @"Birthday", @"", @"JobPlace", @"", @"Mobile", @"", @"Salary", @"", @"JobType", @"", @"Negotiable", @"", @"Education", @"", @"College", @"", @"MajorID", @"", @"MajorName", nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (IBAction)verifyCodeClick:(id)sender {
    [self.view endEditing:YES];
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请输入正确的手机号"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMobileVerifyCode" Params:[NSDictionary dictionaryWithObjectsAndKeys:self.txtMobile.text, @"mobile", [USER_DEFAULT valueForKey:@"subsitename"], @"subsitename", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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

- (IBAction)agreementClick:(id)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    WKNavigationController *agreementNav = [[WKNavigationController alloc] initWithRootViewController:agreementCtrl];
    agreementNav.wantClose = YES;
    agreementCtrl.title = [NSString stringWithFormat:@"%@个人会员协议", [USER_DEFAULT valueForKey:@"subsitename"]];
    [self presentViewController:agreementNav animated:YES completion:nil];
}

- (IBAction)saveClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtName.text.length == 0) {
        [self.view makeToast:@"请填写姓名"];
        return;
    }
    if (self.txtName.text.length == 1) {
        [self.view makeToast:@"姓名不能少于1个字"];
        return;
    }
    if (self.txtName.text.length > 6) {
        [self.view makeToast:@"姓名不能超过6个字"];
        return;
    }
    if (![Common isPureChinese:self.txtName.text]) {
        [self.view makeToast:@"请填写中文姓名"];
        return;
    }
    if ([[self.dataParam valueForKey:@"Gender"] length] == 0) {
        [self.view makeToast:@"请选择性别"];
        return;
    }
    if ([[self.dataParam valueForKey:@"Birthday"] length] == 0) {
        [self.view makeToast:@"请选择出生年月"];
        return;
    }
    if (self.txtCollege.text.length == 0) {
        [self.view makeToast:@"毕业学校不能为空"];
        return;
    }
    if ([[self.dataParam valueForKey:@"Education"] length] == 0) {
        [self.view makeToast:@"请选择学历"];
        return;
    }
    if (self.txtMajorName.text.length == 0) {
        [self.view makeToast:@"专业名称不能为空"];
        return;
    }
    if ([[self.dataParam valueForKey:@"MajorID"] length] == 0) {
        [self.view makeToast:@"请选择专业类别"];
        return;
    }
    if ([[self.dataParam valueForKey:@"JobPlace"] length] == 0) {
        [self.view makeToast:@"请选择期望工作地点"];
        return;
    }
    if ([[self.dataParam valueForKey:@"Salary"] length] == 0) {
        [self.view makeToast:@"请选择期望月薪"];
        return;
    }
    if ([[self.dataParam valueForKey:@"JobType"] length] == 0) {
        [self.view makeToast:@"请选择期望职位类别"];
        return;
    }
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请填写正确的手机号"];
        return;
    }
    if (self.txtVerifyCode.text.length == 0) {
        [self.view makeToast:@"请输入短信验证码"];
        return;
    }
    if (![Common isPureInt:self.txtVerifyCode.text]) {
        [self.view makeToast:@"请输入正确的短信验证码"];
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
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    [self.dataParam setValue:self.txtName.text forKey:@"Name"];
    [self.dataParam setValue:self.txtMobile.text forKey:@"Mobile"];
    [self.dataParam setValue:self.txtCollege.text forKey:@"College"];
    [self.dataParam setValue:self.txtMajorName.text forKey:@"MajorName"];
    [self.dataParam setValue:self.txtVerifyCode.text forKey:@"strVerifyCode"];
    [self.dataParam setValue:self.txtPassword.text forKey:@"strPwd"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"SaveOneMinute" Params:self.dataParam viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)loginClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textField convertRect:textField.bounds toView:window];
    float fltBY = rect.origin.y + rect.size.height;
    if (SCREEN_HEIGHT - fltBY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = self.view.frame;
            frameView.origin.y = SCREEN_HEIGHT - fltBY - KEYBOARD_HEIGHT;
            [self.view setFrame:frameView];
        }];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 1: //性别
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeGender value:[self.dataParam objectForKey:@"Gender"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 2: //出生年月
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeBirth value:[self.dataParam objectForKey:@"Birthday"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 4: //学历
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeDegree value:[self.dataParam objectForKey:@"Education"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 5: //专业名称
        {
            [self.view endEditing:YES];
            MajorViewController *majorCtrl = [[MajorViewController alloc] init];
            [majorCtrl setDelegate:self];
            [self.navigationController pushViewController:majorCtrl animated:YES];
        }
            return NO;
            break;
        case 6: //专业类别
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeMajor value:[self.dataParam objectForKey:@"MajorID"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 7: //期望工作地点
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL3 value:[self.dataParam objectForKey:@"JobPlace"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 8: //期望月薪
        {
            WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSalary value:[self.dataParam objectForKey:@"Salary"]];
            [popView setTag:textField.tag];
            [popView setDelegate:self];
            [popView showPopView:self];
        }
            return NO;
            break;
        case 9: //期望职位类别
        {
            [self.view endEditing:YES];
            MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
            [multiSelectCtrl setDelegate:self];
            multiSelectCtrl.selId = [self.dataParam objectForKey:@"JobType"];
            multiSelectCtrl.selValue = self.txtJobType.text;
            multiSelectCtrl.selectType = MultiSelectTypeJobType;
            [self.navigationController pushViewController:multiSelectCtrl animated:YES];
        }
            return NO;
            break;
        default:
            break;
    }
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    switch (popView.tag) {
        case 1: //性别
        {
            NSDictionary *dataGender = [arraySelect objectAtIndex:0];
            [self.dataParam setValue:[dataGender objectForKey:@"id"] forKey:@"Gender"];
            [self.txtGender setText:[dataGender objectForKey:@"value"]];
        }
            break;
        case 2: //出生年月
        {
            NSDictionary *dataYear = [arraySelect objectAtIndex:0];
            NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
            [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"Birthday"];
            [self.txtBirth setText:[NSString stringWithFormat:@"%@%@", [dataYear objectForKey:@"value"], [dataMonth objectForKey:@"value"]]];
        }
            break;
        case 4: //学历
        {
            NSDictionary *data = [arraySelect objectAtIndex:0];
            [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Education"];
            [self.txtDegree setText:[data objectForKey:@"value"]];
            
            if ([[data objectForKey:@"id"] isEqualToString:@"1"] || [[data objectForKey:@"id"] isEqualToString:@"2"]) {
                
                [self.dataParam setValue:@"1106" forKey:@"MajorID"];
                [self.txtMajor setText:@"未划分专业"];
                
                [self.dataParam setValue:@"无" forKey:@"MajorName"];
                [self.txtMajorName setText:@"无"];
            }
        }
            break;
        case 6: //专业类别
        {
            NSDictionary *data = [arraySelect objectAtIndex:1];
            [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"MajorID"];
            [self.txtMajor setText:[data objectForKey:@"value"]];
        }
            break;
        case 7: //期望工作地点
        {
            NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"JobPlace"];
            [self.txtJobPlace setText:[dataRegion objectForKey:@"value"]];
        }
            break;
        case 8: //期望月薪
        {
            NSDictionary *data = [arraySelect objectAtIndex:0];
            [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Salary"];
            NSDictionary *dataNegotiable = [arraySelect objectAtIndex:1];
            [self.dataParam setValue:[dataNegotiable objectForKey:@"id"] forKey:@"Negotiable"];
            [self.txtSalary setText:[NSString stringWithFormat:@"%@ %@", [data objectForKey:@"value"], ([[dataNegotiable objectForKey:@"id"] isEqualToString:@"0"] ? @"不可面议" : @"可面议")]];
        }
            break;
        default:
            break;
    }
}

- (void)majorViewClick:(NSDictionary *)major {
    [self.dataParam setValue:[major objectForKey:@"MajorName"] forKey:@"MajorName"];
    [self.txtMajorName setText:[major objectForKey:@"MajorName"]];
    if ([[major objectForKey:@"dcMajorId"] length] > 0) {
        [self.dataParam setValue:[major objectForKey:@"dcMajorId"] forKey:@"MajorID"];
        [self.txtMajor setText:[major objectForKey:@"Major"]];
    }
}

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect {
    if (selectType == MultiSelectTypeJobType) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"JobType"];
        [self.txtJobType setText:[arraySelect objectAtIndex:1]];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        switch ([result intValue]) {
            case 1:
                [self.btnVerifyCode setTag:1];
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
    else if (request.tag == 2) {
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
            [self dismissViewControllerAnimated:YES completion:^{
                [USER_DEFAULT setObject:@"1" forKey:@"positioned"];
                [[NSNotificationCenter defaultCenter] postNotificationName:@"paLoginSuccess" object:self];
            }];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view makeToast:@"注册失败，您的邮箱已被我们列入黑名单，不再接受注册"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view makeToast:@"您输入的邮箱重复"];
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
        [self.btnVerifyCode setTag:0];
        [self.btnVerifyCode setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.timer invalidate];
        self.timer = nil;
    }
    else {
        [self.btnVerifyCode setTitle:[NSString stringWithFormat:@"%ds", self.sendSecond] forState:UIControlStateNormal];
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
