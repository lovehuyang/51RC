//
//  CpIndexViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/1.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CpIndexViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "FeedbackViewController.h"
#import "RoleViewController.h"
#import "AboutUsViewController.h"
#import "UIImageView+WebCache.h"
#import "UIView+Toast.h"
#import "InvitationManagerViewController.h"
#import "OrderViewController.h"
#import "SysViewController.h"
#import "ContactUsViewController.h"
#import "Html5ViewController.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "WKPopView.h"
#import "AccountInfoViewController.h"
#import "CpMobileVerifyViewController.h"
#import "CpModifyViewController.h"

@interface CpIndexViewController ()<UIScrollViewDelegate, NetWebServiceRequestDelegate, UINavigationControllerDelegate, UITextFieldDelegate, WKPopViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *viewInfo;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSDictionary *accountData;
@property (nonatomic, strong) NSDictionary *vipData;
@property (nonatomic, strong) UITextField *txtLinkman;
@property (nonatomic, strong) UITextField *txtMobile;
@property (nonatomic, strong) WKPopView *callPop;
@property (nonatomic, strong) NSArray *arrayTitle;
@property float heightForScroll;
@end

@implementation CpIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.arrayTitle = @[@"人才邀约", @"会员服务", @"系统管理", @"联系我们", @"炫酷页面", @"切换角色", @"意见反馈", @"关于我们"];
    [self.view setBackgroundColor:SEPARATECOLOR];
    UIView *viewStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT)];
    [viewStatusBar setBackgroundColor:CPNAVBARCOLOR];
    [self.view addSubview:viewStatusBar];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.runningRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    [self.scrollView removeFromSuperview];
    self.scrollView = nil;
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT)];
    [self.scrollView setBounces:YES];
    
    [self.view addSubview:self.scrollView];
    
    UIView *viewBounceTop = [[UIView alloc] initWithFrame:CGRectMake(0, -500, SCREEN_WIDTH, 500)];
    [viewBounceTop setBackgroundColor:CPNAVBARCOLOR];
    [self.scrollView addSubview:viewBounceTop];
    
    self.viewInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 135)];
    [self.viewInfo setBackgroundColor:CPNAVBARCOLOR];
    [self.scrollView addSubview:self.viewInfo];
    [self getCpInfo];
    //[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(noviewShow) userInfo:nil repeats:YES];
}

- (void)getCpInfo {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillCpInfo {
    float widthForLabel = SCREEN_WIDTH - 135;
    WKLabel *lbCompanyName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(120, 20, widthForLabel, 1) content:[self.companyData valueForKey:@"Name"] size:BIGGERFONTSIZE color:[UIColor whiteColor] spacing:5];
    [self.viewInfo addSubview:lbCompanyName];
    
    WKLabel *lbCompanyId = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompanyName), VIEW_BY(lbCompanyName) + 10, widthForLabel, 1) content:[NSString stringWithFormat:@"会员编号：%@", [self.companyData valueForKey:@"ID"]] size:DEFAULTFONTSIZE color:[UIColor whiteColor] spacing:5];
    [self.viewInfo addSubview:lbCompanyId];
    
    NSInteger memberType = [[self.companyData valueForKey:@"MemberType"] integerValue];
    NSString *memberInfo, *memberTitle;
    if (memberType == 0) {
        memberInfo = @"您的企业信息不完整，请在电脑端填写企业基本信息";
        memberTitle = @"信息不完整";
    }
    else if (memberType == 1) {
        memberInfo = @"成为普通认证会员可同时发布5个职位，可以查看开放简历的联系方式。请到电脑端完成企业认证";
        memberTitle = @"未认证会员";
    }
    else if (memberType == 2) {
        memberInfo = [NSString stringWithFormat:@"想获得更多权限，建议您立即申请VIP会员；职位刷新数：%@个", [self.vipData objectForKey:@"remainJobRefreshQuota"]];
        if ([[self.companyData valueForKey:@"RealName"] isEqualToString:@"1"]) {
            memberTitle = @"实名认证";
        }
        else {
            memberTitle = @"普通会员";
        }
    }
    else if (memberType == 3) {
        NSTimeInterval interval = [[Common dateFromString:[self.vipData objectForKey:@"VipDate"]] timeIntervalSinceDate:[NSDate date]];
        float remainDay = (interval / (24 * 3600));
        memberInfo = [NSString stringWithFormat:@"有效期至：%@，剩余服务期：%0.0f天，剩余简历下载数：%@个%@；职位刷新数：%@个", [Common stringFromDateString:[self.vipData objectForKey:@"VipDate"] formatType:@"yyyy-MM-dd"], remainDay, [self.vipData valueForKey:@"RemainQuota"], (remainDay < 8 ? @"\n您的VIP会员即将到期，为了不影响您的招聘，请提前续费" : @""), [self.vipData objectForKey:@"remainJobRefreshQuota"]];
        memberTitle = @"VIP会员";
    }
    
    WKLabel *lbMemberInfo = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompanyId), VIEW_BY(lbCompanyId) + 10, widthForLabel, 1) content:memberInfo size:DEFAULTFONTSIZE color:[UIColor whiteColor] spacing:5];
    [self.viewInfo addSubview:lbMemberInfo];
    
    CGRect frameInfo = self.viewInfo.frame;
    frameInfo.size.height = VIEW_BY(lbMemberInfo) + 20;
    [self.viewInfo setFrame:frameInfo];
    
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(20, VIEW_H(self.viewInfo) / 2 - 45, 80, 80)];
    if ([[[self.companyData objectForKey:@"LogoFile"] lowercaseString] rangeOfString:@"default"].location == NSNotFound) {
        [imgLogo sd_setImageWithURL:[NSURL URLWithString:[self.companyData objectForKey:@"LogoFile"]] placeholderImage:[UIImage imageNamed:@"cp_defaultlogo.png"]];
    }
    else {
        [imgLogo setImage:[UIImage imageNamed:@"cp_defaultlogo.png"]];
    }
    [imgLogo.layer setMasksToBounds:YES];
    [imgLogo.layer setCornerRadius:40];
    [self.viewInfo addSubview:imgLogo];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(logoClick)];
    imgLogo.userInteractionEnabled = YES;
    [imgLogo addGestureRecognizer:tap];
    
    WKLabel *lbMemberTitle = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(imgLogo), VIEW_BY(imgLogo) - 10, VIEW_W(imgLogo), 20) content:memberTitle size:DEFAULTFONTSIZE color:UIColorWithRGBA(119, 56, 3, 1)];
    [lbMemberTitle setBackgroundColor:UIColorWithRGBA(255, 216, 1, 1)];
    [lbMemberTitle setTextAlignment:NSTextAlignmentCenter];
    [self.viewInfo addSubview:lbMemberTitle];
    
    UIButton *btnPreview = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewInfo), SCREEN_WIDTH / 2, 50)];
    [btnPreview setBackgroundColor:UIColorWithRGBA(130, 43, 206, 1)];
    [btnPreview setTitle:@"预览招聘页面" forState:UIControlStateNormal];
    [btnPreview setImage:[UIImage imageNamed:@"cp_preview.png"] forState:UIControlStateNormal];
    [btnPreview.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnPreview setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnPreview setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [btnPreview.titleLabel setFont:DEFAULTFONT];
    [btnPreview addTarget:self action:@selector(previewClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewInfo addSubview:btnPreview];
    
    UIButton *btnCall = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnPreview), VIEW_Y(btnPreview), VIEW_W(btnPreview), VIEW_H(btnPreview))];
    [btnCall setBackgroundColor:UIColorWithRGBA(130, 43, 206, 1)];
    if ([[self.companyData objectForKey:@"ConsultantID"] length] > 0) {
        [btnCall setTitle:@"优先为您回电" forState:UIControlStateNormal];
        [btnCall addTarget:self action:@selector(callClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [btnCall setTitle:@"联系我们" forState:UIControlStateNormal];
        [btnCall addTarget:self action:@selector(contactusClick) forControlEvents:UIControlEventTouchUpInside];
    }
    [btnCall setImage:[UIImage imageNamed:@"cp_dial.png"] forState:UIControlStateNormal];
    [btnCall.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnCall setImageEdgeInsets:UIEdgeInsetsMake(10, 0, 10, 0)];
    [btnCall setTitleEdgeInsets:UIEdgeInsetsMake(0, -15, 0, 0)];
    [btnCall.titleLabel setFont:DEFAULTFONT];
    [self.viewInfo addSubview:btnCall];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnPreview), VIEW_Y(btnPreview) + 10, 1, VIEW_H(btnPreview) - 20)];
    
    [viewSeparate setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.2]];
    [self.viewInfo addSubview:viewSeparate];
    
    frameInfo = self.viewInfo.frame;
    frameInfo.size.height = VIEW_BY(btnCall);
    [self.viewInfo setFrame:frameInfo];
    
    [self fillMenu];
}

- (void)contactusClick {
    ContactUsViewController *contactUsCtrl = [[ContactUsViewController alloc] init];
    contactUsCtrl.title = @"联系我们";
    [self.navigationController pushViewController:contactUsCtrl animated:YES];
}

- (void)previewClick {
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.companyId = [self.companyData objectForKey:@"ID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)callClick {
    UIView *viewCall = [[UIView alloc] init];
    WKLabel *lbTitle = [[WKLabel alloc] initWithFrame:CGRectMake(20, 20, SCREEN_WIDTH - 40, 20) content:@"要求顾问给您回电" size:DEFAULTFONTSIZE color:nil];
    [viewCall addSubview:lbTitle];
    
    WKLabel *lbLinkman = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(lbTitle), VIEW_BY(lbTitle) + 10, 70, 60) content:@"联系人" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [viewCall addSubview:lbLinkman];
    
    self.txtLinkman = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbLinkman) + 15, VIEW_Y(lbLinkman), SCREEN_WIDTH - VIEW_BX(lbLinkman) - 30, VIEW_H(lbLinkman))];
    [self.txtLinkman setDelegate:self];
    [self.txtLinkman setBorderStyle:UITextBorderStyleNone];
    [self.txtLinkman setTextAlignment:NSTextAlignmentRight];
    [self.txtLinkman setText:[self.accountData objectForKey:@"Name"]];
    [self.txtLinkman setFont:DEFAULTFONT];
    [viewCall addSubview:self.txtLinkman];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(self.txtLinkman), SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [viewCall addSubview:viewSeparate];
    
    WKLabel *lbMobile = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(lbLinkman), VIEW_BY(viewSeparate) + 5, VIEW_W(lbLinkman), VIEW_H(lbLinkman)) content:@"联系电话" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [viewCall addSubview:lbMobile];
    
    NSString *telephone = [self.accountData objectForKey:@"Telephone"];
    if (telephone.length == 0) {
        telephone = [self.accountData objectForKey:@"Mobile"];
    }
    self.txtMobile = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbMobile) + 15, VIEW_Y(lbMobile), SCREEN_WIDTH - VIEW_BX(lbMobile) - 30, VIEW_H(lbMobile))];
    [self.txtMobile setDelegate:self];
    [self.txtMobile setBorderStyle:UITextBorderStyleNone];
    [self.txtMobile setTextAlignment:NSTextAlignmentRight];
    [self.txtMobile setText:telephone];
    [self.txtMobile setFont:DEFAULTFONT];
    [viewCall addSubview:self.txtMobile];
    
    UIView *viewSeparate1 = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbMobile), SCREEN_WIDTH - 30, 1)];
    [viewSeparate1 setBackgroundColor:SEPARATECOLOR];
    [viewCall addSubview:viewSeparate1];
    
    [viewCall setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate1) + 20)];
    
    [self.view setTag:1];
    self.callPop = [[WKPopView alloc] initWithCustomView:viewCall];
    [self.callPop setDelegate:self];
    [self.callPop showPopView:self];
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    [self.view endEditing:YES];
    if (self.txtLinkman.text.length == 0) {
        [self.view.window makeToast:@"请输入联系人"];
        return;
    }
    else if (self.txtLinkman.text.length > 6) {
        [self.view.window makeToast:@"联系人不能超过6个字符"];
        return;
    }
    else if (self.txtMobile.text.length == 0) {
        [self.view.window makeToast:@"请输入联系方式"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"InsertCaContact" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"intCaMainID", CAMAINCODE, @"Code", self.txtLinkman.text, @"strName", self.txtMobile.text, @"strTelephone", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [popView cancelClick];
}

- (void)fillMenu {
    self.heightForScroll = VIEW_BY(self.viewInfo) + 10;
    
    for (int i = 0; i < 8; i++) {
        [self otherButton:i];
    }
    
    UIButton *btnLogout = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll + 10, SCREEN_WIDTH, 40)];
    [btnLogout setTitle:@"退出登录" forState:UIControlStateNormal];
    [btnLogout setBackgroundColor:[UIColor whiteColor]];
    [btnLogout addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    [btnLogout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnLogout.titleLabel setFont:DEFAULTFONT];
    [self.scrollView addSubview:btnLogout];
    
    self.heightForScroll = VIEW_BY(btnLogout);
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForScroll + 10)];
}

- (void)loginClick {
    UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)logoutClick {
    if (!COMPANYLOGIN) {
        return;
    }
    UIAlertController *alertLogout = [UIAlertController alertControllerWithTitle:@"确定要退出登录吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertLogout addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteCpIOSBind" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [JPUSHService registrationID], @"uniqueID", nil] viewController:nil];
        [request setTag:3];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
        
        [USER_DEFAULT removeObjectForKey:@"caMainId"];
        [USER_DEFAULT removeObjectForKey:@"caMainCode"];
        [USER_DEFAULT removeObjectForKey:@"cpMainId"];
    }]];
    [alertLogout addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertLogout animated:YES completion:nil];
}

- (void)otherButton:(NSInteger)tag {
    UIButton *btnOther = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 50)];
    [btnOther setBackgroundColor:[UIColor whiteColor]];
    [btnOther setTag:tag];
    [btnOther addTarget:self action:@selector(otherClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(20, 10, 30, 30)];
    [imgTitle setImage:[UIImage imageNamed:[NSString stringWithFormat:@"cp_account%ld.png", (long)(tag + 1)]]];
    [btnOther addSubview:imgTitle];
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 10, 15, 500, 20) content:[self.arrayTitle objectAtIndex:tag] size:DEFAULTFONTSIZE color:nil];
    [btnOther addSubview:lbTitle];
    
    if ([[self.tabBarController.tabBar.items objectAtIndex:self.tabBarController.selectedIndex].badgeValue integerValue] > 0 && tag == 0) {
        UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(lbTitle) + 5, VIEW_Y(lbTitle) + 7, 6, 6)];
        [viewTips setBackgroundColor:[UIColor redColor]];
        [viewTips.layer setCornerRadius:3];
        [btnOther addSubview:viewTips];
    }
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 36, 20, 6, 10)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowright.png"]];
    [btnOther addSubview:imgArrow];
    
    if (tag == 0 || tag == 3 || tag == 4) {
        self.heightForScroll = VIEW_BY(btnOther) + 10;
    }
    else {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(20, VIEW_H(btnOther) - 1, SCREEN_WIDTH - 40, 1)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [btnOther addSubview:viewSeparate];
        self.heightForScroll = VIEW_BY(btnOther);
    }
    [self.scrollView addSubview:btnOther];
}

- (void)otherClick:(UIButton *)button {
    NSString *title = [self.arrayTitle objectAtIndex:button.tag];
    if (button.tag == 0) {
        [[self.tabBarController.tabBar.items objectAtIndex:self.tabBarController.selectedIndex] setBadgeValue:nil];
        InvitationManagerViewController *invitationManagerCtrl = [[InvitationManagerViewController alloc] init];
        invitationManagerCtrl.title = title;
        [self.navigationController pushViewController:invitationManagerCtrl animated:YES];
    }
    else if (button.tag == 1) {
        OrderViewController *orderCtrl = [[OrderViewController alloc] init];
        orderCtrl.title = title;
        [self.navigationController pushViewController:orderCtrl animated:YES];
    }
    else if (button.tag == 2) {
        SysViewController *sysCtrl = [[SysViewController alloc] init];
        sysCtrl.title = title;
        [self.navigationController pushViewController:sysCtrl animated:YES];
    }
    else if (button.tag == 3) {
        ContactUsViewController *contactUsCtrl = [[ContactUsViewController alloc] init];
        contactUsCtrl.title = title;
        [self.navigationController pushViewController:contactUsCtrl animated:YES];
    }
    else if (button.tag == 4) {
        Html5ViewController *html5Ctrl = [[Html5ViewController alloc] init];
        html5Ctrl.title = title;
        html5Ctrl.companyData = self.companyData;
        html5Ctrl.secondId = [self.companyData objectForKey:@"SecondId"];
        [self.navigationController pushViewController:html5Ctrl animated:YES];
    }
    else if (button.tag == 5) {
        RoleViewController *roleCtrl = [[RoleViewController alloc] init];
        roleCtrl.isCompany = YES;
        [self presentViewController:roleCtrl animated:YES completion:nil];
    }
    else if (button.tag == 6) {
        FeedbackViewController *feedbackCtrl = [[FeedbackViewController alloc] init];
        feedbackCtrl.title = title;
        [self.navigationController pushViewController:feedbackCtrl animated:YES];
    }
    else if (button.tag == 7) {
        AboutUsViewController *aboutUsCtrl = [[AboutUsViewController alloc] init];
        aboutUsCtrl.title = title;
        [self.navigationController pushViewController:aboutUsCtrl animated:YES];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCpMain = [Common getArrayFromXml:requestData tableName:@"TableCp"];
        if ([arrayCpMain count] == 0) {
            [USER_DEFAULT removeObjectForKey:@"caMainId"];
            [USER_DEFAULT removeObjectForKey:@"caMainCode"];
            [USER_DEFAULT removeObjectForKey:@"cpMainId"];
            [self loginClick];
            return;
        }
        self.companyData = [arrayCpMain objectAtIndex:0];
        self.accountData = [[Common getArrayFromXml:requestData tableName:@"TableCa"] objectAtIndex:0];
        NSArray *arrayVipInfo = [Common getArrayFromXml:requestData tableName:@"TableVipInfo"];
        if (arrayVipInfo.count > 0) {
            self.vipData = [arrayVipInfo objectAtIndex:0];
        }
        [self fillCpInfo];
        [USER_DEFAULT setObject:[self.companyData objectForKey:@"MemberType"] forKey:@"cpMemberType"];
        //判断是否完整，如果不完整要强制填写
        if ([[self.companyData objectForKey:@"MemberType"] isEqualToString:@"0"]) {
            if ([[self.companyData objectForKey:@"dcCompanyKindID"] length] == 0) {
                CpModifyViewController *cpModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cpModifyView"];
                cpModifyCtrl.forceModify = YES;
                [self.navigationController pushViewController:cpModifyCtrl animated:YES];
            }
            else {
                AccountInfoViewController *accountInfoCtrl = [[AccountInfoViewController alloc] init];
                accountInfoCtrl.caMainId = [self.accountData objectForKey:@"ID"];
                accountInfoCtrl.title = [self.accountData objectForKey:@"Name"];
                accountInfoCtrl.forceModify = YES;
                [self.navigationController pushViewController:accountInfoCtrl animated:YES];
            }
        }
        else if ([[self.accountData objectForKey:@"MobileVerifyDate"] length] == 0) {
            NSString *today = [Common stringFromDate:[NSDate date] formatType:@"yyyy-MM-dd"];
            NSString *verifyDate = [USER_DEFAULT objectForKey:@"cpMobileVerifyDate"];
            if (![today isEqualToString:verifyDate]) {
                CpMobileVerifyViewController *cpMobileVerifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cpMobileVerifyView"];
                cpMobileVerifyCtrl.mobile = [self.accountData objectForKey:@"Mobile"];
                [self.navigationController pushViewController:cpMobileVerifyCtrl animated:YES];
            }
        }
    }
    else if (request.tag == 2) {
        if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"您电话号码格式不符合要求"];
        }
        else {
            [self.view.window makeToast:@"您的请求已经提交，请耐心等待"];
        }
    }
    else if (request.tag == 3) {
        [self loginClick];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frameView = self.callPop.frame;
        frameView.origin.y = SCREEN_HEIGHT - VIEW_H(self.callPop) - KEYBOARD_HEIGHT + 30;
        [self.callPop setFrame:frameView];
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frameView = self.callPop.frame;
        frameView.origin.y = SCREEN_HEIGHT - VIEW_H(self.callPop);
        [self.callPop setFrame:frameView];
    }];
    return YES;
}

- (void)logoClick {
    UIViewController *cpLogoCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cpLogoView"];
    [self.navigationController pushViewController:cpLogoCtrl animated:YES];
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
