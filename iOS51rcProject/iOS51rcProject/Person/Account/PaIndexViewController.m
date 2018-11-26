//
//  PaIndexViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/1.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  我的页面

#import "PaIndexViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "WKLabel.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "UIImageView+WebCache.h"
#import "AccountManagerViewController.h"
#import "RecruitmentViewController.h"
#import "SalaryViewController.h"
#import "EmploymentNewsController.h"
#import "TalentsTestController.h"
#import "FeedbackViewController.h"
#import "RoleViewController.h"
#import "AboutUsViewController.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "UIImage+Size.h"
#import "OptionView.h"
#import "AFNManager.h"

@interface PaIndexViewController ()<UIScrollViewDelegate, NetWebServiceRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MLImageCropDelegate, WKPopViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *viewInfo;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIButton *btnCareerStatus;
@property (nonatomic, strong) UIButton *btnLogout;
@property float heightForScroll;
@end

@implementation PaIndexViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIView *viewStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT)];
    [viewStatusBar setBackgroundColor:NAVBARCOLOR];
    [self.view addSubview:viewStatusBar];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT)];
    [self.scrollView setBounces:YES];
    
    [self.view addSubview:self.scrollView];
    
    UIView *viewBounceTop = [[UIView alloc] initWithFrame:CGRectMake(0, -500, SCREEN_WIDTH, 500)];
    [viewBounceTop setBackgroundColor:NAVBARCOLOR];
    [self.scrollView addSubview:viewBounceTop];
    // 头像、手机号等信息的容器
    self.viewInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 135)];
    [self.viewInfo setBackgroundColor:NAVBARCOLOR];
    [self.scrollView addSubview:self.viewInfo];
    
    // 波浪图片
    UIImageView *imgBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewInfo), SCREEN_WIDTH, SCREEN_WIDTH * 0.096)];
    [imgBackground setImage:[UIImage imageNamed:@"pa_indexbg.png"]];
    [self.scrollView addSubview:imgBackground];
    
    // 账户管理的lab
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(30, VIEW_BY(imgBackground), 300, 20) content:@"账户管理" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    // 修改密码、修改用户名、修改手机号、设置你的菜的容器
    UIView *viewSeparate1 = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbTitle) + 10, SCREEN_WIDTH - 20, 1)];
    [viewSeparate1 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate1];
    self.heightForScroll = VIEW_BY(viewSeparate1);
    [self accountButton:0];// 修改密码
    [self accountButton:1];// 修改用户名
    [self accountButton:2];// 修改手机号
    [self accountButton:3];// 设置你的菜儿
    
    // 分割线
    UIView *viewSeparate2 = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(lbTitle) + 65, SCREEN_WIDTH - 20, 1)];
    [viewSeparate2 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate2];
    // 分割线
    UIView *viewSeparate3 = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2, VIEW_Y(viewSeparate1), 1, 100)];
    [viewSeparate3 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate3];
    // 分割线
    UIView *viewSeparate4 = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 10)];
    [viewSeparate4 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate4];
    
    self.heightForScroll = VIEW_BY(viewSeparate4);
    
    // 企业秀、招聘会、查工资、就业资讯、人才测评
    OptionView *optionView = [[OptionView alloc]initWithFrame:CGRectMake(0, self.heightForScroll , SCREEN_WIDTH, 60)];
    [self.scrollView addSubview:optionView];
    __weak typeof(self)weakself = self;
    optionView.optionViewClick = ^(NSString *optionTitle) {
        DLog(@"%@",optionTitle);
        [weakself optionClick:optionTitle];
    };
    
    // 分割线
    UIView *optionSeparate4 = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(optionView), SCREEN_WIDTH, 10)];
    [optionSeparate4 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:optionSeparate4];
    
    self.heightForScroll = VIEW_BY(optionView);
    
//    [self otherButton:0];// 招聘会
//    [self otherButton:1];// 查工资
    [self otherButton:2];// 意见反馈
    [self otherButton:3];// 切换角色
    [self otherButton:4];// 关于我们
    
    // 分割线
    UIView *viewSeparate5 = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 10)];
    [viewSeparate5 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate5];
    
    self.heightForScroll = VIEW_BY(viewSeparate5);
    
    // 底部灰色
    UIView *viewBounceBottom = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 500)];
    [viewBounceBottom setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewBounceBottom];
    
    self.btnLogout = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 40)];
    [self.btnLogout setTitle:@"退出登录" forState:UIControlStateNormal];
    [self.btnLogout setBackgroundColor:[UIColor whiteColor]];
    [self.btnLogout addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btnLogout setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnLogout.titleLabel setFont:DEFAULTFONT];
    [self.scrollView addSubview:self.btnLogout];
    
    self.heightForScroll = VIEW_BY(self.btnLogout);
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForScroll + 10)];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    [self.runningRequest cancel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [self getPaInfo];
}

- (void)getPaInfo {
    [self.btnLogout setHidden:NO];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaMain" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
//    NSDictionary *param = @{@"paMainID":PAMAINID,
//                            @"code":[USER_DEFAULT valueForKey:@"paMainCode"],
//                            };
//    NSURLSessionDataTask *task = [AFNManager requestWithMethod:POST ParamDict:param url:@"GetPaMain" tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
//        DLog(@"");
//    } failureBlock:^(NSInteger errCode, NSString *msg) {
//        DLog(@"");
//    }];
////    [task cancel];
}

- (void)fillPaInfo:(NSDictionary *)data {
    for (UIView *view in self.viewInfo.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewPhotoBg = [[UIView alloc] initWithFrame:CGRectMake(20, 35, 78, 78)];
    [viewPhotoBg setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.3]];
    [viewPhotoBg.layer setCornerRadius:VIEW_W(viewPhotoBg) / 2];
    [viewPhotoBg.layer setMasksToBounds:YES];
    [self.viewInfo addSubview:viewPhotoBg];
    
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(3, 3, 72, 72)];
    if ([data objectForKey:@"PhotoProcessed"] != nil) {
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[Common getPaPhotoUrl:[data objectForKey:@"PhotoProcessed"] paMainId:PAMAINID]]];
    }
    else {
        [imgPhoto setImage:[UIImage imageNamed:@"pa_defaultphoto.png"]];
    }
    [imgPhoto setTag:99];
    [imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
    [imgPhoto.layer setCornerRadius:VIEW_W(imgPhoto) / 2];
    [imgPhoto.layer setMasksToBounds:YES];
    [viewPhotoBg addSubview:imgPhoto];
    
    UIButton *btnPhoto = [[UIButton alloc] initWithFrame:imgPhoto.frame];
    [btnPhoto setBackgroundColor:[UIColor clearColor]];
    [btnPhoto addTarget:self action:@selector(photoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewInfo addSubview:btnPhoto];
    
    NSString *name = [data objectForKey:@"Name"];
    if ([name length] == 0) {
        name = @"您好";
    }
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(viewPhotoBg) + 15, 30, SCREEN_WIDTH, 20) content:name size:BIGGESTFONTSIZE color:[UIColor whiteColor]];
    [self.viewInfo addSubview:lbName];
    
    UIView *viewMobile = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbName), VIEW_BY(lbName) + 5, SCREEN_WIDTH, 20)];
    [self.viewInfo addSubview:viewMobile];
    
    NSString *mobile = [data objectForKey:@"Mobile"];
    if ([mobile length] == 0) {
        mobile = [data objectForKey:@"Email"];
    }
    WKLabel *lbMobile = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, 0, 1000, 20) content:mobile size:BIGGERFONTSIZE color:[UIColor whiteColor]];
    [viewMobile addSubview:lbMobile];
    
    if ([mobile rangeOfString:@"@"].location == NSNotFound) {
        Boolean blnCertificate = [[data objectForKey:@"MobileVerifyDate"] length] > 0;
        if (blnCertificate) {
            UIButton *btnMobile = [self.scrollView viewWithTag:2];
            [btnMobile setTitle:@"修改手机号" forState:UIControlStateNormal];
        }
        
        UIImageView *imgCer = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbMobile) + 5, 2, 16, 16)];
        [imgCer setImage:[UIImage imageNamed:(blnCertificate ? @"pa_mobilecer1.png" : @"pa_mobilecer2.png")]];
        [imgCer setContentMode:UIViewContentModeScaleAspectFit];
        [viewMobile addSubview:imgCer];
        
        WKLabel *lbCer = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgCer) + 5, 0, 1000, 20) content:(blnCertificate ? @"已认证" : @"未认证") size:BIGGERFONTSIZE color:UIColorWithRGBA(253, 220, 51, 1)];
        [viewMobile addSubview:lbCer];
        
        CGRect frameMobile = viewMobile.frame;
        frameMobile.size.width = VIEW_BX(lbCer);
        [viewMobile setFrame:frameMobile];
    }
    else {
        CGRect frameMobile = viewMobile.frame;
        frameMobile.size.width = VIEW_BX(lbMobile);
        [viewMobile setFrame:frameMobile];
    }
    self.btnCareerStatus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbName), VIEW_BY(viewMobile) + 10, SCREEN_WIDTH - VIEW_X(lbName), 35)];
    [self.btnCareerStatus setTitle:([[data objectForKey:@"CareerStatus"] length] == 0 ? @"求职状态未填写" : [data objectForKey:@"CareerStatus"]) forState:UIControlStateNormal];
    [self.btnCareerStatus setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnCareerStatus setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [self.btnCareerStatus addTarget:self action:@selector(careerClick) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCareerStatus.titleLabel setFont:BIGGERFONT];
    
    UIView *viewSeparateTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self.btnCareerStatus) - 20, 1)];
    [viewSeparateTop setBackgroundColor:UIColorWithRGBA(255, 180, 146, 1)];
    [self.btnCareerStatus addSubview:viewSeparateTop];
    
    UIView *viewSeparateBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.btnCareerStatus) - 1, VIEW_W(viewSeparateTop), 1)];
    [viewSeparateBottom setBackgroundColor:UIColorWithRGBA(255, 180, 146, 1)];
    [self.btnCareerStatus addSubview:viewSeparateBottom];
    
    UIImageView *imgStatus = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_W(viewSeparateTop) - 20, (VIEW_H(self.btnCareerStatus) - 9) / 2, 15, 9)];
    [imgStatus setImage:[UIImage imageNamed:@"img_arrowdownclear.png"]];
    [self.btnCareerStatus addSubview:imgStatus];
    
    [self.viewInfo addSubview:self.btnCareerStatus];
}

- (void)loginClick {
    UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)logoutClick {
    if (!PERSONLOGIN) {
        return;
    }
    UIAlertController *alertLogout = [UIAlertController alertControllerWithTitle:@"确定要退出登录吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertLogout addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeletePaIOSBind" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", [JPUSHService registrationID], @"uniqueID", nil] viewController:nil];
        [request setTag:4];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
        
        [USER_DEFAULT removeObjectForKey:@"paMainId"];
        [USER_DEFAULT removeObjectForKey:@"paMainCode"];
        [self loginClick];
    }]];
    [alertLogout addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertLogout animated:YES completion:nil];
}

- (void)photoClick {
    UIAlertController *alerPhoto = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alerPhoto animated:YES completion:nil];
}

- (void)accountButton:(NSInteger)tag {
    NSString *title, *image;
    CGRect rectButton;
    switch (tag) {
        case 0:
            title = @"修改密码";
            image = @"pa_account1.png";
            rectButton = CGRectMake(0, self.heightForScroll, SCREEN_WIDTH / 2, 50);
            break;
        case 1:
            title = @"修改用户名";
            image = @"pa_account2.png";
            rectButton = CGRectMake(SCREEN_WIDTH / 2, self.heightForScroll, SCREEN_WIDTH / 2, 50);
            self.heightForScroll += 50;
            break;
        case 2:
            title = @"认证手机号";
            image = @"pa_account3.png";
            rectButton = CGRectMake(0, self.heightForScroll, SCREEN_WIDTH / 2, 50);
            break;
        case 3:
            title = @"设置你的菜儿";
            image = @"pa_account4.png";
            rectButton = CGRectMake(SCREEN_WIDTH / 2, self.heightForScroll, SCREEN_WIDTH / 2, 50);
            self.heightForScroll += 50;
            break;
        default:
            rectButton = CGRectNull;
            break;
    }
    UIButton *btnAccount = [[UIButton alloc] initWithFrame:rectButton];
    [btnAccount setTag:tag];
    [btnAccount setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btnAccount setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnAccount setTitle:title forState:UIControlStateNormal];
    [btnAccount.titleLabel setFont:DEFAULTFONT];
    [btnAccount setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [btnAccount.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnAccount setImageEdgeInsets:UIEdgeInsetsMake(14, 7, 13, 0)];
    [btnAccount setTitleEdgeInsets:UIEdgeInsetsMake(0, -7, 0, 0)];
    [btnAccount addTarget:self action:@selector(accountClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnAccount];
}

- (void)otherButton:(NSInteger)tag {
    NSString *title;
    switch (tag) {
        case 0:
            title = @"招聘会";
            break;
        case 1:
            title = @"查工资";
            break;
        case 2:
            title = @"意见反馈";
            break;
        case 3:
            title = @"切换角色";
            break;
        case 4:
            title = @"关于我们";
            break;
        default:
            break;
    }
    UIButton *btnOther = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 50)];
    [btnOther setTag:tag];
    [btnOther addTarget:self action:@selector(otherClick:) forControlEvents:UIControlEventTouchUpInside];
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(30, 15, 500, 20) content:title size:DEFAULTFONTSIZE color:nil];
    [btnOther addSubview:lbTitle];
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 36, 20, 6, 10)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowright.png"]];
    [btnOther addSubview:imgArrow];
    
    if (tag == 3) {
        WKLabel *lbRole = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(imgArrow) - 60, VIEW_Y(lbTitle), 60, 20) content:@"个人求职" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [btnOther addSubview:lbRole];
    }
    if (tag != 4) {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(20, VIEW_H(btnOther) - 1, SCREEN_WIDTH - 40, 1)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [btnOther addSubview:viewSeparate];
    }
    [self.scrollView addSubview:btnOther];
    self.heightForScroll = VIEW_BY(btnOther);
}

- (void)accountClick:(UIButton *)button {
    if (!PERSONLOGIN) {
        [self loginClick];
        return;
    }
    NSString *url = @"", *title = @"";
    if (button.tag == 0) {
        url = @"/personal/sys/password";
        title = @"修改密码";
    }
    else if (button.tag == 1) {
        url = @"/personal/sys/username";
        title = @"修改用户名";
    }
    else if (button.tag == 2) {
        url = @"/personal/sys/mobilecer";
        title = @"修改手机号";
    }
    else if (button.tag == 3) {
        url = @"/personal/sys/yourfood";
        title = @"设置你的菜儿";
    }
    AccountManagerViewController *accountCtrl = [[AccountManagerViewController alloc] init];
    accountCtrl.url = url;
    accountCtrl.title = title;
    [self.navigationController pushViewController:accountCtrl animated:YES];
}

#pragma mark - cell的点击事件

- (void)otherClick:(UIButton *)button {
    if (button.tag == 0) {
        // 招聘会
    }
    else if (button.tag == 1) {
        // 查工资
    }
    else if (button.tag == 2) {
        FeedbackViewController *feedbackCtrl = [[FeedbackViewController alloc] init];
        feedbackCtrl.title = @"意见反馈";
        [self.navigationController pushViewController:feedbackCtrl animated:YES];
    }
    else if (button.tag == 3) {
        RoleViewController *roleCtrl = [[RoleViewController alloc] init];
        [self presentViewController:roleCtrl animated:YES completion:nil];
    }
    else if (button.tag == 4) {
        AboutUsViewController *aboutUsCtrl = [[AboutUsViewController alloc] init];
        aboutUsCtrl.title = @"关于我们";
        [self.navigationController pushViewController:aboutUsCtrl animated:YES];
    }
}
#pragma mark - optionView的点击事件
- (void)optionClick:(NSString *)optionTitle{
    if([optionTitle isEqualToString:@"招聘会"]){
        RecruitmentViewController *recruitmentCtrl = [[RecruitmentViewController alloc] init];
        recruitmentCtrl.title = @"招聘会";
        [self.navigationController pushViewController:recruitmentCtrl animated:YES];
    }else if([optionTitle isEqualToString:@"查工资"]){
        SalaryViewController *salaryCtrl = [[SalaryViewController alloc] init];
        salaryCtrl.title = @"查工资";
        [self.navigationController pushViewController:salaryCtrl animated:YES];
    }else if([optionTitle isEqualToString:@"就业资讯"]){
        EmploymentNewsController *evc = [EmploymentNewsController new];
        evc.title = @"就业资讯";
        evc.urlString = @"/personal/news/newslist";
        [self.navigationController pushViewController:evc animated:YES];
        
    }else if([optionTitle isEqualToString:@"人才测评"]){
        TalentsTestController *tvc = [TalentsTestController new];
        tvc.title = @"人才测评";
        tvc.urlString = [NSString stringWithFormat:@"/personal/assess/index?PaMainID=%@&Code=%@",PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
        [self.navigationController pushViewController:tvc animated:YES];
    }
}

- (void)careerClick {
    [self.view setTag:1];
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCareerStatus value:@""];
    [popView setDelegate:self];
    [popView showPopView:self];
}

#pragma mark - NetWebServiceRequestDelegate

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayPaMain = [Common getArrayFromXml:requestData tableName:@"Table"];
        if ([arrayPaMain count] == 0) {
            [USER_DEFAULT removeObjectForKey:@"paMainId"];
            [USER_DEFAULT removeObjectForKey:@"paMainCode"];
            [self loginClick];
            return;
        }
        [self fillPaInfo:[arrayPaMain objectAtIndex:0]];
    }
    else if (request.tag == 2) {
    }
    else if (request.tag == 3) {
        [self.view.window makeToast:@"求职状态更新成功"];
    }
}

- (void)getPhoto:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count] > 0) {
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *pickerPhoto = [[UIImagePickerController alloc] init];
        pickerPhoto.mediaTypes = mediatypes;
        pickerPhoto.delegate = self;
        pickerPhoto.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [pickerPhoto setMediaTypes:arrmediatypes];
        [self presentViewController:pickerPhoto animated:YES completion:nil];
    }
    else {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备不支持拍摄功能" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage]) {
        UIImage *imgSelect = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = imgSelect;
        imgCrop.ratioOfWidthAndHeight = 4.0f/5.0f;
        [imgCrop showWithAnimation:true];
    }
    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie]) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统只支持图片格式" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropImage:(UIImage *)cropImage forOriginalImage:(UIImage *)originalImage {
    UIImageView *imgPhoto = (UIImageView *)[self.viewInfo viewWithTag:99];
    [imgPhoto setImage:cropImage];
    cropImage = [cropImage transformtoSize:CGSizeMake(80, 100)];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 1.0);
    [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadPhoto:(NSString *)dataPhoto {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UploadPhoto" Params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)WKPickerViewConfirm:(WKPopView *)view arraySelect:(NSArray *)arraySelect {
    NSDictionary *dataSelect = [arraySelect objectAtIndex:0];
    [self.btnCareerStatus setTitle:[dataSelect objectForKey:@"value"] forState:UIControlStateNormal];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateCareerStatus" Params:[NSDictionary dictionaryWithObjectsAndKeys:[dataSelect objectForKey:@"id"], @"careerStatus", PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:nil];
    [request setTag:3];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    // CheckIsPaMobileVerify
    NSDictionary *paramDict = @{@"mobile":@"15665889905"};
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"CheckIsPaMobileVerify" tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}

@end
