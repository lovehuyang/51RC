//
//  CpRegisterViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/9/20.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  企业注册页面

#import "CpRegisterViewController.h"
#import "AgreementViewController.h"
#import "WKNavigationController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "WKPopView.h"
#import "UIView+Toast.h"

@interface CpRegisterViewController ()<NetWebServiceRequestDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, WKPopViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *provinceId;
@property (nonatomic, strong) NSString *subSiteName;
@property (nonatomic, strong) NSTimer *timer;
@property NSInteger sendSecond;
@end

@implementation CpRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业注册";
    self.sendSecond = 180;
    self.searcher = [[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    self.locService = [[BMKLocationService alloc] init];
    self.locService.delegate = self;
    [self.locService startUserLocationService];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.searcher.delegate = nil;
    self.locService.delegate = nil;
}

- (IBAction)registerClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtCompanyName.text.length == 0) {
        [self.view makeToast:@"请输入企业名称"];
        return;
    }
    if (self.txtCompanyName.text.length > 50) {
        [self.view makeToast:@"企业名称不能超过50个字"];
        return;
    }
    if (self.txtLinkman.text.length == 0) {
        [self.view makeToast:@"请输入联系人"];
        return;
    }
    if (self.txtLinkman.text.length > 6) {
        [self.view makeToast:@"联系人不能超过6个字"];
        return;
    }
    if (![Common isPureChinese:self.txtLinkman.text]) {
        [self.view makeToast:@"联系人只能输入汉字"];
        return;
    }
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
    if (self.txtZip.text.length > 4) {
        [self.view makeToast:@"固定电话区号不能超过4位数"];
        return;
    }
    if (self.txtPhone.text.length > 8) {
        [self.view makeToast:@"固定电话号码不能超过8位数"];
        return;
    }
    if (self.txtExt.text.length > 5) {
        [self.view makeToast:@"固定电话分机号不能超过5位数"];
        return;
    }
    NSString *telephone = [NSString stringWithFormat:@"%@-%@转%@", self.txtZip.text, self.txtPhone.text, self.txtExt.text];
    if ([telephone isEqualToString:@"-转"]) {
        telephone = @"";
    }
    else if ([telephone rangeOfString:@"-转" options:NSLiteralSearch].location != NSNotFound) {
        [self.view makeToast:@"请输入正确的固定电话"];
        return;
    }
    else if ([[telephone substringToIndex:1] isEqualToString:@"-"]) {
        [self.view makeToast:@"请输入正确的固定电话"];
        return;
    }
    else if ([[telephone substringFromIndex:(telephone.length - 1)] isEqualToString:@"转"]) {
        telephone = [telephone substringToIndex:(telephone.length - 1)];
    }
    if (self.txtEmail.text.length == 0) {
        [self.view makeToast:@"请输入电子邮箱"];
        return;
    }
    if (self.txtEmail.text.length > 50) {
        [self.view makeToast:@"电子邮箱不能超过50字"];
        return;
    }
    if (![Common checkEmail:self.txtEmail.text]) {
        [self.view makeToast:@"请输入正确的电子邮箱"];
        return;
    }
    if (self.txtUsername.text.length == 0) {
        [self.view makeToast:@"请输入用户名"];
        return;
    }
    if (self.txtUsername.text.length > 20) {
        [self.view makeToast:@"用户名不能超过20字"];
        return;
    }
    if (![Common checkPassword:self.txtUsername.text]) {
        [self.view makeToast:@"用户名只能使用字母、数字、横线、下划线、点"];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self.view makeToast:@"请输入密码"];
        return;
    }
    if (self.txtPassword.text.length > 20) {
        [self.view makeToast:@"密码不能超过20字"];
        return;
    }
    if (![Common checkCpPassword:self.txtPassword.text]) {
        [self.view makeToast:@"密码长度8-20位，必须包含数字和字母"];
        return;
    }
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"Register" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtCompanyName.text, @"companyName", self.txtLinkman.text, @"linkMan", self.txtEmail.text, @"email", self.txtMobile.text, @"mobile", self.txtCode.text, @"cerCode", telephone, @"telephone", self.txtUsername.text, @"userName", self.txtPassword.text, @"passWord", self.provinceId, @"provinceId", @"ismobile:IOS", @"browser", [JPUSHService registrationID], @"jpushId", @"1", @"clientType", nil] viewController:self];
    [request setTag:3];
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
        [sender setBackgroundImage:[UIImage imageNamed:@"img_cpcheck1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
    else {
        [sender setBackgroundImage:[UIImage imageNamed:@"img_cpcheck2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
}

- (IBAction)agreementClick:(UIButton *)sender {
    AgreementViewController *agreementCtrl = [[AgreementViewController alloc] init];
    WKNavigationController *agreementNav = [[WKNavigationController alloc] initWithRootViewController:agreementCtrl];
    agreementNav.wantClose = YES;
    agreementCtrl.title = [NSString stringWithFormat:@"%@企业会员协议", [USER_DEFAULT valueForKey:@"subsitename"]];
    [self presentViewController:agreementNav animated:YES completion:nil];
}

- (IBAction)codeClick:(UIButton *)sender {
    [self.view endEditing:YES];
    if (sender.tag == 1) {
        return;
    }
    if (self.provinceId.length == 0) {
        [self.view makeToast:@"请选择公司所在地区"];
        return;
    }
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请输入正确的手机号"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"CertifCpMobile" Params:[NSDictionary dictionaryWithObjectsAndKeys:[Common enMobile:self.txtMobile.text], @"mobile", self.subSiteName, @"subsiteName", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag) {
        [self.locService stopUserLocationService];
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetSubSiteByAddress" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:result.address, @"address", nil] viewController:nil];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetSubSiteByAddress" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"value"], @"address", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arraySubsite = [Common getArrayFromXml:requestData tableName:@"Table"];
        if ([arraySubsite count] > 0) {
            NSDictionary *dataSubsite = [arraySubsite objectAtIndex:0];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"ProvinceID"] forKey:@"provinceId"];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"SubSIteCity"] forKey:@"province"];
            [USER_DEFAULT setValue:[[dataSubsite objectForKey:@"SubSiteUrl"] stringByReplacingOccurrencesOfString:@"www." withString:@"m."] forKey:@"subsite"];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"SubSiteName"] forKey:@"subsitename"];
            [self.btnProvince setTitle:[dataSubsite objectForKey:@"SubSIteCity"] forState:UIControlStateNormal];
            self.provinceId = [dataSubsite objectForKey:@"ProvinceID"];
            self.subSiteName = [dataSubsite objectForKey:@"SubSiteName"];
        }
    }
    else if (request.tag == 2) {
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
            [self.view makeToast:@"您输入的手机号已经存在"];
            return;
        }
        else if ([result rangeOfString:@"s"].location != NSNotFound) {
            [self.btnCode setTag:1];
            self.sendSecond = [[result stringByReplacingOccurrencesOfString:@"s" withString:@""] integerValue];
            self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(sendInterval) userInfo:nil repeats:YES];
        }
    }
    else if (request.tag == 3) {
        self.sendSecond = 0;
        NSDictionary *dataResult = [[Common getArrayFromXml:requestData tableName:@"TableResult"] objectAtIndex:0];
        if ([[dataResult objectForKey:@"Result"] isEqualToString:@"1"]) {
            NSDictionary *dataCp = [[Common getArrayFromXml:requestData tableName:@"TableCp"] objectAtIndex:0];
            NSDictionary *dataCa = [[Common getArrayFromXml:requestData tableName:@"TableCa"] objectAtIndex:0];
            NSString *caMainId = [dataCa objectForKey:@"ID"];
            NSString *regDate = [Common stringFromDateString:[dataCa objectForKey:@"RegDate"] formatType:@"yyyy-MM-dd HH:mm"];
            NSString *realCode = [NSString stringWithFormat:@"%@%@%@%@%@",[regDate substringWithRange:NSMakeRange(11,2)],
                                  [regDate substringWithRange:NSMakeRange(0,4)],[regDate substringWithRange:NSMakeRange(14,2)],
                                  [regDate substringWithRange:NSMakeRange(8,2)],[regDate substringWithRange:NSMakeRange(5,2)]];
            
            NSString *code = [Common MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [[dataCp objectForKey:@"ID"] longLongValue])]];
            [USER_DEFAULT setValue:caMainId forKey:@"caMainId"];
            [USER_DEFAULT setValue:code forKey:@"caMainCode"];
            [USER_DEFAULT setObject:[dataCp objectForKey:@"ID"] forKey:@"cpMainId"];
            [USER_DEFAULT setObject:@"1" forKey:@"AccountType"];
            
            NSDictionary *dataProvince = [[Common getArrayFromXml:requestData tableName:@"TableProvince"] objectAtIndex:0];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"ID"] forKey:@"provinceId"];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"ProvinceName"] forKey:@"province"];
            [USER_DEFAULT setValue:[NSString stringWithFormat:@"m.%@", [dataProvince objectForKey:@"ProvinceDomain"]] forKey:@"subsite"];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"WebsiteName"] forKey:@"subsitename"];
            
            UITabBarController *companyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"companyView"];
            [companyCtrl setSelectedIndex:4];
            [self presentViewController:companyCtrl animated:YES completion:nil];
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-1"]) {
            [self.view makeToast:@"您输入的企业名称已经存在，不再接受注册"];
            return;
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-2"]) {
            [self.view makeToast:@"您的企业名称已被我们列入黑名单，不再接受注册。如果您有任何疑问，请拨打全国统一客服电话400-626-5151寻求帮助"];
            return;
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-3"]) {
            [self.view makeToast:@"您的电子邮箱已被我们列入黑名单，不再接受注册。如果您有任何疑问，请拨打全国统一客服电话400-626-5151寻求帮助"];
            return;
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-4"]) {
            [self.view makeToast:@"当前的电子邮箱已经注册过一个企业，不再接受注册"];
            return;
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-5"]) {
            [self.view makeToast:@"当前的用户名已经注册过一个企业，不再接受注册"];
            return;
        }
        else if ([[dataResult objectForKey:@"Result"] isEqualToString:@"-11"]) {
            [self.view makeToast:@"手机号或验证码错误，请重新输入"];
            return;
        }
        else {
            [self.view makeToast:@"数据库异常，请重新进行注册"];
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

- (IBAction)provinceClick:(UIButton *)sender {
    [self.view setTag:1];
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeProvince value:@""];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
    return YES;
}

@end
