//
//  CpLoginViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/29.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CpLoginViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "JPUSHService.h"
#import "AgreementViewController.h"
#import "WKNavigationController.h"
#import "RoleViewController.h"
#import "CpForgetPasswordViewController.h"
#import "WKLabel.h"

@interface CpLoginViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIView *viewRealNameContent;
@end

@implementation CpLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业登录";
    [Common changeFontSize:self.view];
    [self.btnRegister setBackgroundColor:[UIColor whiteColor]];
    [self.btnRegister setTitleColor:UIColorWithRGBA(0, 188, 18, 1) forState:UIControlStateNormal];
    [self.btnRegister.layer setBorderWidth:1];
    [self.btnRegister.layer setBorderColor:[UIColorWithRGBA(0, 188, 18, 1) CGColor]];
    
    UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_close.png"] style:UIBarButtonItemStyleDone target:self action:@selector(cancelClick)];
    self.navigationItem.leftBarButtonItem = leftBarItem;
}

- (void)cancelClick {
    RoleViewController *roleCtrl = [[RoleViewController alloc] init];
    roleCtrl.isCompany = YES;
    [self presentViewController:roleCtrl animated:YES completion:nil];
}

- (IBAction)loginClick:(id)sender {
    [self.view endEditing:YES];
    if (self.txtUsername.text.length == 0) {
        [self.view makeToast:@"请输入用户名"];
        return;
    }
    if (self.txtPassword.text.length == 0) {
        [self.view makeToast:@"请输入密码"];
        return;
    }
    if (self.btnAgree.tag == 0) {
        [self.view makeToast:@"请勾选用户协议"];
        return;
    }
    [MobClick endEvent:@"cpLogin"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"Login" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.txtUsername.text, @"userName", self.txtPassword.text, @"passWord", @"0", @"provinceId", @"ismobile:IOS", @"browser", [JPUSHService registrationID], @"jpushId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)forgetPasswordClick:(id)sender {
    CpForgetPasswordViewController *forgetPasswordCtrl = [[CpForgetPasswordViewController alloc] init];
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

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSDictionary *dataResult = [[Common getArrayFromXml:requestData tableName:@"TableResult"] objectAtIndex:0];
    if ([[dataResult objectForKey:@"Result"] integerValue] > 0) {
        NSDictionary *dataCp = [[Common getArrayFromXml:requestData tableName:@"TableCp"] objectAtIndex:0];
        NSDictionary *dataCa = [[Common getArrayFromXml:requestData tableName:@"TableCa"] objectAtIndex:0];
        if ([[dataCp objectForKey:@"RealName"] integerValue] > 1) {
            NSDictionary *dataPay = [[Common getArrayFromXml:requestData tableName:@"TablePay"] objectAtIndex:0];
            self.viewRealNameContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            [self.viewRealNameContent setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
            [self.view addSubview:self.viewRealNameContent];
            
            UIView *viewRealName = [[UIView alloc] init];
            [viewRealName setBackgroundColor:[UIColor whiteColor]];
            [self.viewRealNameContent addSubview:viewRealName];
            
            UIScrollView *scrollRealName = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 100)];
            [viewRealName addSubview:scrollRealName];
            
            NSString *cpMainId = [dataCp objectForKey:@"ID"];
            NSString *money = [cpMainId substringFromIndex:cpMainId.length - 2];
            if ([money isEqualToString:@"00"]) {
                money = [cpMainId substringToIndex:2];
            }
            NSString *limitHtml = [NSString stringWithFormat:@"\
               <style>p {font-size:14px;} span {font-size:16px}</style>\
               <p>贵企业已被系统限制登录，原因如下：</p>\
               <p>%@</p>\
               <p>请务必使用与<span style='color:red'>“%@”</span>一致的对公账号汇款。汇款成功后，我们将在1个工作日内完成认证，认证后网站会通过短信或微信通知。</p>\
               <p>认证金额：0.%@元<span style='color:red'>请务必汇入以上指定金额！</span></p>\
               <p>收款账号：%@</p>\
               <p>收款公司名：%@</p>\
               <p>开户银行：%@</p>\
               <p>联行号：%@</p>\
               <p>备注信息：会员编号%@<span style='color:red'>请务必填写！</span></p>\
               <p>如有疑问可在工作时间[周一至周五8:30至17:30]拨打400-626-5151转0与客服取得联系，谢谢合作！您的会员编号是：%@</p>", [dataCp objectForKey:@"RealNameLimit"], [dataCp objectForKey:@"Name"], money, [dataPay objectForKey:@"Account"], [dataPay objectForKey:@"Receiver"], [dataPay objectForKey:@"BankName"], [dataPay objectForKey:@"JointNo"], cpMainId, cpMainId];
            
            UILabel *lbDescription = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, VIEW_W(scrollRealName) - 20, 100)];
            NSDictionary *options = @{
                NSDocumentTypeDocumentAttribute : NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute : @(NSUTF8StringEncoding)
            };
            NSData *data = [limitHtml dataUsingEncoding:NSUTF8StringEncoding];
            [lbDescription setAttributedText:[[NSAttributedString alloc] initWithData:data options:options documentAttributes:nil error:nil]];
            [lbDescription setNumberOfLines:0];
            [lbDescription setLineBreakMode:NSLineBreakByCharWrapping];
            [lbDescription sizeToFit];
            [scrollRealName addSubview:lbDescription];
            if (VIEW_BY(lbDescription) + 10 > VIEW_H(scrollRealName)) {
                [scrollRealName setContentSize:CGSizeMake(VIEW_W(scrollRealName), VIEW_BY(lbDescription))];
            }
            else {
                [scrollRealName setFrame:CGRectMake(VIEW_X(lbDescription), VIEW_Y(lbDescription), VIEW_W(lbDescription), VIEW_BY(lbDescription))];
            }
            UIButton *btnOk = [[UIButton alloc] initWithFrame:CGRectMake(25, VIEW_BY(scrollRealName), VIEW_W(scrollRealName) - 50, 50)];
            [btnOk addTarget:self action:@selector(okClick) forControlEvents:UIControlEventTouchUpInside];
            [btnOk setBackgroundColor:CPNAVBARCOLOR];
            [btnOk setTitle:@"我知道了" forState:UIControlStateNormal];
            [viewRealName addSubview:btnOk];
            
            [viewRealName setFrame:CGRectMake(0, 0, VIEW_W(scrollRealName), VIEW_BY(btnOk) + 10)];
            [viewRealName setCenter:CGPointMake(self.view.center.x, self.view.center.y)];
        }
        else {
            NSString *caMainId = [dataCa objectForKey:@"ID"];
            NSString *regDate = [Common stringFromDateString:[dataCp objectForKey:@"RegDate"] formatType:@"yyyy-MM-dd HH:mm"];
            NSString *realCode = [NSString stringWithFormat:@"%@%@%@%@%@",[regDate substringWithRange:NSMakeRange(11,2)],
                                  [regDate substringWithRange:NSMakeRange(0,4)],[regDate substringWithRange:NSMakeRange(14,2)],
                                  [regDate substringWithRange:NSMakeRange(8,2)],[regDate substringWithRange:NSMakeRange(5,2)]];
            
            NSString *code = [Common MD5:[NSString stringWithFormat:@"%lld", ([realCode longLongValue] + [[dataCp objectForKey:@"ID"] longLongValue])]];
            [USER_DEFAULT setValue:caMainId forKey:@"caMainId"];
            [USER_DEFAULT setValue:code forKey:@"caMainCode"];
            [USER_DEFAULT setObject:[dataCp objectForKey:@"ID"] forKey:@"cpMainId"];
            [USER_DEFAULT setObject:[dataCa objectForKey:@"AccountType"] forKey:@"AccountType"];
            
            NSDictionary *dataProvince = [[Common getArrayFromXml:requestData tableName:@"TableProvince"] objectAtIndex:0];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"ID"] forKey:@"provinceId"];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"ProvinceName"] forKey:@"province"];
            [USER_DEFAULT setValue:[NSString stringWithFormat:@"m.%@", [dataProvince objectForKey:@"ProvinceDomain"]] forKey:@"subsite"];
            [USER_DEFAULT setValue:[dataProvince objectForKey:@"WebsiteName"] forKey:@"subsitename"];
            
            UITabBarController *companyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"companyView"];
            [companyCtrl setSelectedIndex:4];
            [self presentViewController:companyCtrl animated:YES completion:nil];
        }
    }
    else if ([[dataResult objectForKey:@"Result"] integerValue] == -1) {
        [self.view.window makeToast:@"用户名或密码错误"];
    }
    else if ([[dataResult objectForKey:@"Result"] integerValue] == -2) {
        [self.view.window makeToast:@"您今天的登录次数已超过15次的限制，请明天再来"];
    }
    else if ([[dataResult objectForKey:@"Result"] integerValue] == -3) {
        [self.view.window makeToast:@"您今天的登录次数已超过30次的限制，请明天再来"];
    }
    else if ([[dataResult objectForKey:@"Result"] integerValue] == -4) {
        [self.view.window makeToast:@"您的用户已经被管理员暂停"];
    }
    else if ([[dataResult objectForKey:@"Result"] integerValue] == -9) {
        [self.view.window makeToast:[NSString stringWithFormat:@"贵企业已被系统限制登录，原因如下%@", [dataResult objectForKey:@"LimitReason"]]];
    }
}

- (void)okClick {
    
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
