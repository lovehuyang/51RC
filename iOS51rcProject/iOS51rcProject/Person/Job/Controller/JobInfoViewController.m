//
//  JobInfoViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/26.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobInfoViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "UIImageView+WebCache.h"
#import "NetWebServiceRequest.h"
#import "MapViewController.h"
#import "UIView+Toast.h"
#import "WKApplyView.h"
#import "ChatViewController.h"
#import "ComplainViewController.h"
#import "OneMinuteCVViewController.h"
#import "ApplySucceedAlert.h"
#import "SelectCvAlert.h"
#import "ExperienceModifyViewController.h"// 工作经历页面

@interface JobInfoViewController ()<NetWebServiceRequestDelegate, WKApplyViewDelegate>
{
    BOOL cvExpStatus;// 简历中有无工作经历 默认没有no
}
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *viewContact;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *selCvMainId;
@property (nonatomic, strong) WKButton *btnApply;
@property (nonatomic, strong) NSArray *cvListApplyArr;// 可以用于申请职位的简历列表
@end

@implementation JobInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    cvExpStatus = NO;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT)];
    [self.scrollView setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:self.scrollView];
    [self fillData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData:(NSString *)jobId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", jobId, @"jobId", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)fillData {
    if (self.jobData == nil) {
        return;
    }
    UIView *viewInfo = [[UIView alloc] init];
    [viewInfo setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewInfo];
    //职位名称+月薪
    NSString *salaryString = [Common getSalary:[self.jobData objectForKey:@"dcSalaryId"] salaryMin:[self.jobData objectForKey:@"Salary"] salaryMax:[self.jobData objectForKey:@"SalaryMax"] negotiable:[self.jobData objectForKey:@"Negotiable"]];
    WKLabel *lbName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(10, 20, SCREEN_WIDTH - 20, 20) content:[NSString stringWithFormat:@"%@ %@", [self.jobData objectForKey:@"Name"], salaryString] size:BIGGESTFONTSIZE color:nil spacing:0];
    NSMutableAttributedString *attrString = [lbName.attributedText mutableCopy];
    NSRange rangeSalary = NSMakeRange(attrString.string.length - salaryString.length, salaryString.length);
    [attrString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:rangeSalary];
    [attrString addAttribute:NSFontAttributeName value:BIGGERFONT range:rangeSalary];
    [lbName setAttributedText:attrString];
    [lbName sizeToFit];
    [lbName setCenter:CGPointMake(SCREEN_WIDTH / 2, lbName.center.y)];
    [viewInfo addSubview:lbName];
    //工作地点
    UIView *viewRegion = [[UIView alloc] init];
    WKLabel *lbRegion = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, 0, SCREEN_WIDTH - 20 - 50, 20) content:[NSString stringWithFormat:@"工作地点：%@", [self.jobData objectForKey:@"JobRegion"]] size:DEFAULTFONTSIZE color:nil];
    [viewRegion addSubview:lbRegion];
    
    if ([[self.jobData objectForKey:@"lng"] length] > 0) {
        UIButton *btnRegion = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbRegion) + 3, 0, 60, 20)];
        [btnRegion setImage:[UIImage imageNamed:@"img_map.png"] forState:UIControlStateNormal];
        [btnRegion.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnRegion addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
        [viewRegion addSubview:btnRegion];
        [viewRegion setFrame:CGRectMake(0, VIEW_BY(lbName) + 10, VIEW_BX(btnRegion), 20)];
    }
    else {
        [viewRegion setFrame:CGRectMake(0, VIEW_BY(lbName) + 10, VIEW_BX(lbRegion), 20)];
    }
    [viewRegion setCenter:CGPointMake(SCREEN_WIDTH / 2, viewRegion.center.y)];
    [viewInfo addSubview:viewRegion];
    //职位详情
    UIView *viewDetail = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_BY(viewRegion) + 25, SCREEN_WIDTH - 20, 55)];
    [viewInfo addSubview:viewDetail];
    NSString *age = @"";
    if ([[self.jobData objectForKey:@"MinAge"] isEqualToString:@"99"] && [[self.jobData objectForKey:@"MaxAge"] isEqualToString:@"99"]) {
        age = @"年龄不限";
    }
    else if (![[self.jobData objectForKey:@"MinAge"] isEqualToString:@"99"] && [[self.jobData objectForKey:@"MaxAge"] isEqualToString:@"99"]) {
        age = [NSString stringWithFormat:@"%@岁以上", [self.jobData objectForKey:@"MinAge"]];
    }
    else if ([[self.jobData objectForKey:@"MinAge"] isEqualToString:@"99"] && ![[self.jobData objectForKey:@"MaxAge"] isEqualToString:@"99"]) {
        age = [NSString stringWithFormat:@"%@岁以下", [self.jobData objectForKey:@"MaxAge"]];
    }
    else {
        age = [NSString stringWithFormat:@"%@-%@岁", [self.jobData objectForKey:@"MinAge"], [self.jobData objectForKey:@"MaxAge"]];
    }
    NSString *needNumber = [self.jobData objectForKey:@"NeedNumber"];
    if ([needNumber containsString:@"不限"]) {
        needNumber = @"人数不限";
    }
    NSString *experience = [self.jobData objectForKey:@"Experience"];
    if ([experience containsString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = [self.jobData objectForKey:@"Education"];
    if ([education containsString:@"不限"]) {
        education = @"学历不限";
    }
    [self fillDetail:viewDetail index:4 description:needNumber];
    [self fillDetail:viewDetail index:1 description:education];
    [self fillDetail:viewDetail index:3 description:age];
    [self fillDetail:viewDetail index:2 description:experience];
    [self fillDetail:viewDetail index:0 description:[self.jobData objectForKey:@"EmployType"]];
    //福利待遇
    NSArray *arrWelfare = [NSArray arrayWithObjects:@"社会保险", @"商业保险", @"公积金", @"年终奖", @"奖金提成", @"全勤奖", @"节日福利", @"双休", @"8小时工作制", @"带薪年假", @"公费培训", @"公费旅游", @"健康体检", @"通讯补贴", @"提供住宿", @"餐补/工作餐", @"住房补贴", @"交通补贴", @"班车接送", nil];
    NSArray *arrWelfareId = [NSArray arrayWithObjects:@"1", @"19", @"2", @"4", @"13", @"14", @"11", @"3", @"9", @"5", @"12", @"6", @"16", @"17", @"10", @"7", @"18", @"8", @"15", nil];
    NSMutableArray *arrWelfareSelected = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < arrWelfareId.count; i++) {
        if ([[self.jobData objectForKey:[NSString stringWithFormat:@"Welfare%@", [arrWelfareId objectAtIndex:i]]] boolValue]) {
            [arrWelfareSelected addObject:[arrWelfare objectAtIndex:i]];
        }
    }
    UIView *viewWelfare = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(viewDetail), SCREEN_WIDTH - 30, 1)];
    if (arrWelfareSelected.count > 0) {
        [viewInfo addSubview:viewWelfare];
        float widthForWelfare = 0;
        float heightForWelfare = 0;
        for (NSString *welfare in arrWelfareSelected) {
            WKLabel *lbWelfare = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForWelfare, heightForWelfare, 200, 25) content:welfare size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
            [lbWelfare setBackgroundColor:UIColorWithRGBA(254, 238, 237, 1)];
            [lbWelfare setTextAlignment:NSTextAlignmentCenter];
            lbWelfare.layer.masksToBounds = YES;
            [lbWelfare.layer setCornerRadius:5];
            [lbWelfare.layer setBorderColor:[UIColorWithRGBA(254, 238, 237, 1) CGColor]];
            [lbWelfare.layer setBorderWidth:1];
            CGRect frameWelfare = lbWelfare.frame;
            frameWelfare.size.width = frameWelfare.size.width + 10;
            [lbWelfare setFrame:frameWelfare];
            if (VIEW_BX(lbWelfare) > VIEW_W(viewWelfare)) {
                frameWelfare.origin.y = VIEW_BY(lbWelfare) + 5;
                frameWelfare.origin.x = 0;
            }
            [lbWelfare setFrame:frameWelfare];
            
            widthForWelfare = VIEW_BX(lbWelfare) + 10;
            heightForWelfare = VIEW_Y(lbWelfare);
            
            [viewWelfare addSubview:lbWelfare];
        }
        [viewWelfare setFrame:CGRectMake(VIEW_X(viewWelfare), VIEW_BY(viewDetail) + 20, VIEW_W(viewWelfare), heightForWelfare + 25)];
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(viewWelfare) + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [viewInfo addSubview:viewSeparate];
    //企业信息
    UIButton *btnCompany = [[UIButton alloc] init];
    [btnCompany addTarget:self action:@selector(companyClick) forControlEvents:UIControlEventTouchUpInside];
    [viewInfo addSubview:btnCompany];
    
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[self.companyData objectForKey:@"LogoFile"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [btnCompany addSubview:imgLogo];
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30 - 25;
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo), maxWidth, 25) content:[self.companyData objectForKey:@"Name"] size:BIGGERFONTSIZE color:nil];
    UIImageView *imgCompany;
    if ([[self.companyData objectForKey:@"RealName"] isEqualToString:@"1"]) {
        imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 5, 43.2, 15)];
        [imgCompany setImage:[UIImage imageNamed:@"img_realname.png"]];
    }
    else if ([[self.companyData objectForKey:@"MemberType"] intValue] > 1) {
        imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbCompany) + 5, VIEW_Y(lbCompany) + 5, 20.3, 15)];
        [imgCompany setImage:[UIImage imageNamed:@"img_licence.png"]];
    }
    if (imgCompany != nil) {
        [imgCompany setContentMode:UIViewContentModeScaleAspectFit];
        [btnCompany addSubview:imgCompany];
        if (VIEW_BX(imgCompany) > SCREEN_WIDTH - 25) {
            CGRect frameCompany = lbCompany.frame;
            frameCompany.size.width = maxWidth - VIEW_W(imgCompany) - 5;
            [lbCompany setFrame:frameCompany];
            
            CGRect frameCompanyImg = imgCompany.frame;
            frameCompanyImg.origin.x = VIEW_BX(lbCompany) + 5;
            [imgCompany setFrame:frameCompanyImg];
        }
    }
    [btnCompany addSubview:lbCompany];
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [self.companyData objectForKey:@"Industry"], [self.companyData objectForKey:@"CompanyKind"], [self.companyData objectForKey:@"CompanySize"]] size:DEFAULTFONTSIZE color:nil spacing:0];
    [btnCompany addSubview:lbDetail];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 25, 20, 9, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowright.png"]];
    [btnCompany addSubview:imgArrow];
    
    [btnCompany setFrame:CGRectMake(0, VIEW_BY(viewSeparate), SCREEN_WIDTH, MAX(VIEW_BY(lbDetail), VIEW_BY(imgLogo)) + 15)];
    [imgLogo setCenter:CGPointMake(imgLogo.center.x, VIEW_H(btnCompany) / 2)];
    [imgArrow setCenter:CGPointMake(imgArrow.center.x, VIEW_H(btnCompany) / 2)];
    [viewInfo setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnCompany))];
    [self fillDescription:viewInfo];
    [self fillApply];
}

- (void)fillApply {
    UIView *viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TAB_BAR_HEIGHT, SCREEN_WIDTH, TAB_BAR_HEIGHT)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewBottom];
    
    float widthForBottomButton = (SCREEN_WIDTH - 30 - 10) / 2;
    self.btnApply = [[WKButton alloc] initWithFrame:CGRectMake(15, 7, widthForBottomButton, 36)];
    [viewBottom addSubview:self.btnApply];
    if ([[self.jobData objectForKey:@"hasApply"] boolValue]) {
        [self.btnApply setTitle:@"已申请" forState:UIControlStateNormal];
        [self.btnApply setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [self.btnApply setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [self.btnApply setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
        [self.btnApply setImage:[UIImage imageNamed:@"job_hasapply.png"] forState:UIControlStateNormal];
        [self.btnApply.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.btnApply setImageEdgeInsets:UIEdgeInsetsMake(11, -10, 11, 0)];
    }
    else {
        [self.btnApply setTitle:@"立即申请" forState:UIControlStateNormal];
        [self.btnApply addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    WKButton *btnChat = [[WKButton alloc] initWithFrame:CGRectMake(VIEW_BX(self.btnApply) + 10, VIEW_Y(self.btnApply), widthForBottomButton, VIEW_H(self.btnApply))];
    if ([[self.jobData objectForKey:@"IsOnline"] boolValue]) {
        [btnChat setTitle:@"与HR聊聊" forState:UIControlStateNormal];
        [btnChat setImage:[UIImage imageNamed:@"job_chat.png"] forState:UIControlStateNormal];
        [btnChat setBackgroundColor:GREENCOLOR];
    }
    else {
        [btnChat setTitle:@"给HR留言" forState:UIControlStateNormal];
        [btnChat setImage:[UIImage imageNamed:@"job_chatgreen.png"] forState:UIControlStateNormal];
        [btnChat setBackgroundColor:[UIColor whiteColor]];
        [btnChat setTitleColor:GREENCOLOR forState:UIControlStateNormal];
        btnChat.layer.borderColor = [GREENCOLOR CGColor];
        btnChat.layer.borderWidth = 1;
    }
    [btnChat setTitleEdgeInsets:UIEdgeInsetsMake(0, -20, 0, 0)];
    [btnChat.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnChat setImageEdgeInsets:UIEdgeInsetsMake(8, -5, 8, 0)];
    [btnChat addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    [viewBottom addSubview:btnChat];
}

- (void)fillDescription:(UIView *)view {
    UIView *viewDescription = [[UIView alloc] init];
    [viewDescription setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewDescription];
    
    float heightForDescription = 0;
    if ([[self.jobData objectForKey:@"JobTags"] length] > 0) {
        WKLabel *lbTagTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 15, 200, 20) content:@"职位诱惑" size:BIGGERFONTSIZE color:nil];
        [viewDescription addSubview:lbTagTitle];
        
        NSArray *arrTag = [[self.jobData objectForKey:@"JobTags"] componentsSeparatedByString:@"@"];
        float widthForTag = 15;
        float heightForTag = VIEW_BY(lbTagTitle) + 10;
        for (NSString *tag in arrTag) {
            WKLabel *lbTag = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForTag, heightForTag, 200, 25) content:tag size:DEFAULTFONTSIZE color:UIColorWithRGBA(255, 142, 90, 1)];
            [lbTag setTextAlignment:NSTextAlignmentCenter];
            lbTag.layer.masksToBounds = YES;
            lbTag.layer.borderColor = [UIColorWithRGBA(255, 142, 90, 1) CGColor];
            lbTag.layer.borderWidth = 1;
            lbTag.layer.cornerRadius = 12;
            
            CGRect frameTag = lbTag.frame;
            frameTag.size.width = frameTag.size.width + 20;
            [lbTag setFrame:frameTag];
            if (VIEW_BX(lbTag) > SCREEN_WIDTH - 15) {
                frameTag.origin.y = VIEW_BY(lbTag) + 10;
                frameTag.origin.x = 15;
            }
            [lbTag setFrame:frameTag];
            
            widthForTag = VIEW_BX(lbTag) + 10;
            heightForTag = VIEW_Y(lbTag);
            
            [viewDescription addSubview:lbTag];
        }
        heightForDescription = heightForTag + 25;
    }
    
    WKLabel *lbResponsibilityTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, heightForDescription + 15, 200, 20) content:@"岗位职责" size:BIGGERFONTSIZE color:nil];
    [viewDescription addSubview:lbResponsibilityTitle];
    
    WKLabel *lbResponsibility = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbResponsibilityTitle) + 10, SCREEN_WIDTH - 30, 20) content:[self.jobData objectForKey:@"Responsibility"] size:DEFAULTFONTSIZE color:nil spacing:7];
    [viewDescription addSubview:lbResponsibility];
    
    WKLabel *lbDemandTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, VIEW_BY(lbResponsibility) + 15, 200, 20) content:@"岗位要求" size:BIGGERFONTSIZE color:nil];
    [viewDescription addSubview:lbDemandTitle];
    
    WKLabel *lbDemand = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbDemandTitle) + 10, SCREEN_WIDTH - 30, 20) content:[self.jobData objectForKey:@"Demand"] size:DEFAULTFONTSIZE color:nil spacing:7];
    [viewDescription addSubview:lbDemand];
    
    //刷新时间
    WKLabel *lbRefreshDate = [[WKLabel alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDemand) + 10, SCREEN_WIDTH - 30, 15) content:[NSString stringWithFormat:@"刷新时间：%@", [Common stringFromRefreshDate:[self.jobData objectForKey:@"RefreshDate"]]] size:SMALLERFONTSIZE color:TEXTGRAYCOLOR];
    [lbRefreshDate setTextAlignment:NSTextAlignmentRight];
    [viewDescription addSubview:lbRefreshDate];
    
    [viewDescription setFrame:CGRectMake(0, VIEW_BY(view) + 10, SCREEN_WIDTH, VIEW_BY(lbRefreshDate) + 15)];
    
    [self fillContact:viewDescription];
}

#pragma mark - 联系信息
- (void)fillContact:(UIView *)view {
    self.viewContact = [[UIView alloc] init];
    [self.viewContact setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:self.viewContact];
    UIImageView *imgContact = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 26, 30)];
    [imgContact setTag:1];
    [imgContact setImage:[UIImage imageNamed:@"job_contact.png"]];
    [self.viewContact addSubview:imgContact];
    
    float widthForContact = SCREEN_WIDTH - VIEW_BX(imgContact) - 30;
    NSMutableString *stringContact = [[NSMutableString alloc] initWithString:[self.jobData objectForKey:@"caName"]];
    if ([[self.jobData objectForKey:@"caTitle"] length] > 0) {
        [stringContact appendFormat:@" | %@", [self.jobData objectForKey:@"caTitle"]];
    }
    if ([[self.jobData objectForKey:@"caDept"] length] > 0) {
        [stringContact appendFormat:@" | %@", [self.jobData objectForKey:@"caDept"]];
    }
    WKLabel *lbContact = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgContact) + 15, 10, widthForContact, 20) content:stringContact size:DEFAULTFONTSIZE color:nil];
    [self.viewContact addSubview:lbContact];
    
    NSString *mobile = [self.jobData objectForKey:@"caMobile"];
    NSString *telephone = [self.jobData objectForKey:@"caTel"];
    float heightForContact = [self fillLink:CGPointMake(VIEW_X(lbContact), VIEW_BY(lbContact)) mobile:mobile telephone:telephone];
    [self.viewContact setFrame:CGRectMake(0, VIEW_BY(view) + 10, SCREEN_WIDTH, heightForContact + 10)];
    [imgContact setCenter:CGPointMake(imgContact.center.x, VIEW_H(self.viewContact) / 2)];
    
    if ([mobile rangeOfString:@"点击"].location != NSNotFound) {
        UIButton *btnContact = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self.viewContact), VIEW_H(self.viewContact))];
        [btnContact setTag:4];
        [btnContact addTarget:self action:@selector(contactClick) forControlEvents:UIControlEventTouchUpInside];
        [self.viewContact addSubview:btnContact];
    }
    
    // 投诉按钮
    UIButton *complainBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    complainBtn.frame = CGRectMake(SCREEN_WIDTH - 70, CGRectGetMaxY(lbContact.frame), 60, 20);
//    complainBtn.backgroundColor = [UIColor redColor];
    [self.viewContact addSubview:complainBtn];
    [complainBtn setTitle:@" 投诉" forState:UIControlStateNormal];
    [complainBtn setImage:[UIImage imageNamed:@"job_tousu"] forState:UIControlStateNormal];
    complainBtn.titleLabel.font = [UIFont systemFontOfSize:DEFAULTFONTSIZE];
    [complainBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [complainBtn addTarget:self action:@selector(complainClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewContact) + 10)];
}

- (void)fillDetail:(UIView *)view index:(NSInteger)index description:(NSString *)description {
    float widthForView = VIEW_W(view) / 5;
    UIView *viewItem = [[UIView alloc] initWithFrame:CGRectMake(widthForView * index, 0, widthForView, VIEW_H(view))];
    [view addSubview:viewItem];
    UIImageView *imgItem = [[UIImageView alloc] initWithFrame:CGRectMake((widthForView - 25) / 2, 0, 25, 25)];
    [imgItem setContentMode:UIViewContentModeScaleAspectFit];
    [imgItem setImage:[UIImage imageNamed:[NSString stringWithFormat:@"job_item%ld.png", index + 1]]];
    [viewItem addSubview:imgItem];
    
    WKLabel *lbItem = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgItem) + 10, widthForView, 15) content:description size:DEFAULTFONTSIZE color:nil];
    [lbItem setTextAlignment:NSTextAlignmentCenter];
    [viewItem addSubview:lbItem];
    
    if (index < 4) {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(widthForView - 1, 0, 1, VIEW_H(viewItem))];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [viewItem addSubview:viewSeparate];
    }
    
    if ([description containsString:@"经验不限"] ||[description containsString:@"应届毕业生"]) {
        lbItem.textColor = NAVBARCOLOR;
    }
}

- (void)contactClick {
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        [self.view.window makeToast:@"您当前的角色为企业，请切换至求职者后方可操作"];
        return;
    }
    if (!PERSONLOGIN) {
        [self loginClick];
        return;
    }
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:nil];
    [request setTag:7];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)loginClick {
    UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)companyClick {
    JobViewController *jobCtrl = (JobViewController *)self.parentViewController;
    [jobCtrl companyClickWithAnimated:YES];
}

- (void)mapClick {
    MapViewController *mapCtrl = [[MapViewController alloc] init];
    mapCtrl.lat = [self.jobData objectForKey:@"lat"];
    mapCtrl.lng = [self.jobData objectForKey:@"lng"];
    mapCtrl.pointTitle = [self.jobData objectForKey:@"Name"];
    mapCtrl.title = [self.jobData objectForKey:@"Name"];
    [self.navigationController pushViewController:mapCtrl animated:YES];
}

#pragma mark - 立即申请点击事件
- (void)applyClick {
  
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        [self.view.window makeToast:@"您当前的角色为企业，请切换至求职者后方可操作"];
        return;
    }
    if (!PERSONLOGIN) {
        [self loginClick];
        return;
    }
    // 获取可以用于投递的简历列表
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:nil];
    [request setTag:3];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1 || request.tag == 2) {
        for (UIView *view in self.scrollView.subviews) {
            [view removeFromSuperview];
        }
        self.jobData = [[Common getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
        [self fillData];
        if (request.tag == 2) {
            [self.scrollView setContentOffset:CGPointMake(0, 0)];
        }
    }
    else if (request.tag == 3) {
        NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayCv.count == 0) {
//            [self.view makeToast:@"您还没有完整简历，无法申请职位"];
            [self presentOneMinutesViewController];
        }
        else if (arrayCv.count > 0) {// 取第一个用于投递的简历
            self.cvListApplyArr = [NSArray arrayWithArray:arrayCv];
            [self applyJob:[[arrayCv objectAtIndex:0] objectForKey:@"ID"]];
        }
        else {// 有多个可用简历的话默认投递第一个简历
            WKApplyView *applyView = [[WKApplyView alloc] initWithArrayCv:arrayCv];
            [applyView setTag:1001];
            [applyView setDelegate:self];
            [applyView show:self];
        }
    }else if (request.tag == 4) {
        
        NSArray *arrayValidNumber = [Common getArrayFromXml:requestData tableName:@"Table"];
        NSArray *arrayJob;// 接口返回的推荐职位
        if (arrayValidNumber.count == 0) {
            [self.view.window makeToast:@"职位申请失败，可能是您30天内申请过该职位"];
            return;
        }
        else if ([[[arrayValidNumber objectAtIndex:0] objectForKey:@"ValidJobNumber"] isEqualToString:@"0"]) {
            [self.view.window makeToast:@"职位申请成功"];
        }
        else {
            arrayJob = [Common getArrayFromXml:requestData tableName:@"Table1"];
        }
        [self.btnApply setTitle:@"已申请" forState:UIControlStateNormal];
        [self.btnApply setTitleEdgeInsets:UIEdgeInsetsMake(0, -30, 0, 0)];
        [self.btnApply setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [self.btnApply setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
        [self.btnApply setImage:[UIImage imageNamed:@"job_hasapply.png"] forState:UIControlStateNormal];
        [self.btnApply.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.btnApply setImageEdgeInsets:UIEdgeInsetsMake(11, -10, 11, 0)];
        [self.btnApply removeTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
        
        // 检查可用于投递的所有简历是否填写了工作经历
        [self checkCvExpStatus:arrayJob];
        
    }
    else if (request.tag == 5) {
        [self.view.window makeToast:@"职位申请成功"];
    }
    
    else if (request.tag == 6) {
        NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayCv.count == 0) {
//            [self.view makeToast:@"您还没有完整简历，无法与HR沟通"];
            [self presentOneMinutesViewController];
        }
        else if (arrayCv.count == 1) {
            [self gotoChat:[[arrayCv objectAtIndex:0] objectForKey:@"ID"]];
        }
        else {
            WKApplyView *applyView = [[WKApplyView alloc] initWithArrayCv:arrayCv];
            [applyView setTag:1002];
            [applyView setDelegate:self];
            [applyView show:self];
        }
    }
    else if (request.tag == 7){// 查看联系方式
        NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayCv.count == 0) {
            [self presentOneMinutesViewController];
        
        }else if(arrayCv.count == 1){
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要查看该联系方式吗？" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetContact" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", [self.jobData objectForKey:@"id"], @"jobId", nil] viewController:self];
                [request setTag:1];
                [request setDelegate:self];
                [request startAsynchronous];
                self.runningRequest = request;
            }]];
            [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
        
        }else{
    
        }
    }else if (request.tag == 8){
        
        NSArray *arrayValidNumber = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayValidNumber.count == 0) {
            [self.view.window makeToast:@"职位申请失败，可能是您30天内申请过该职位"];
            return;
        }
        else if ([[[arrayValidNumber objectAtIndex:0] objectForKey:@"ValidJobNumber"] isEqualToString:@"0"]) {
            [self.view.window makeToast:@"投递成功"];
        }else{
            [self.view.window makeToast:@"投递成功"];
        }
    }
}

- (void)gotoChat:(NSString *)cvMainId {
    ChatViewController *chatCtrl = [[ChatViewController alloc] init];
    chatCtrl.title = [NSString stringWithFormat:@"%@ | %@", [self.jobData objectForKey:@"cpName"], [self.jobData objectForKey:@"caName"]];
    chatCtrl.jobId = [self.jobData objectForKey:@"id"];
    chatCtrl.caMainId = [self.jobData objectForKey:@"caMainID"];
    chatCtrl.cvMainId = cvMainId;
    [self.navigationController pushViewController:chatCtrl animated:YES];
}

#pragma mark - 申请职位的网络请求
- (void)applyJob:(NSString *)cvMainId {
    self.selCvMainId = cvMainId;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"PaMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", cvMainId, @"strCvMainID", [self.jobData objectForKey:@"id"], @"strJobIDs", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
    [request setTag:4];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (float)fillLink:(CGPoint)point mobile:(NSString *)mobile telephone:(NSString *)telephone {
    float heightForContact = point.y;
    if (mobile.length > 0) {
        WKLabel *lbMobile = [[WKLabel alloc] initWithFixedHeight:CGRectMake(point.x, heightForContact + 5, 300, 20) content:mobile size:DEFAULTFONTSIZE color:nil];
        [lbMobile setTag:3];
        [self.viewContact addSubview:lbMobile];
        if ([mobile rangeOfString:@"点击"].location != NSNotFound) {
            [lbMobile setTextColor:NAVBARCOLOR];
        }
        else if ([mobile rangeOfString:@"["].location != NSNotFound) {
            UIButton *btnMobile = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbMobile), VIEW_Y(lbMobile), 50, 20)];
            [btnMobile setTag:1];
            [btnMobile addTarget:self action:@selector(dialClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnMobile setImage:[UIImage imageNamed:@"img_dial.png"] forState:UIControlStateNormal];
            [btnMobile.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [btnMobile setTitle:@"拨打" forState:UIControlStateNormal];
            [btnMobile setTitleColor:GREENCOLOR forState:UIControlStateNormal];
            [btnMobile.titleLabel setFont:FONT(10)];
            [btnMobile setImageEdgeInsets:UIEdgeInsetsMake(2, -3, 2, 0)];
            [btnMobile setTitleEdgeInsets:UIEdgeInsetsMake(0, -13, 0, 0)];
            btnMobile.layer.borderColor = [GREENCOLOR CGColor];
            btnMobile.layer.borderWidth = 1;
            btnMobile.layer.cornerRadius = 3;
            [self.viewContact addSubview:btnMobile];
        }
        heightForContact = VIEW_BY(lbMobile);
    }
    
    if (telephone.length > 0) {
        WKLabel *lbTelephone = [[WKLabel alloc] initWithFixedHeight:CGRectMake(point.x, heightForContact + 5, 300, 20) content:telephone size:DEFAULTFONTSIZE color:nil];
        [self.viewContact addSubview:lbTelephone];
        if ([telephone rangeOfString:@"["].location != NSNotFound) {
            UIButton *btnTelephone = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbTelephone) + 3, VIEW_Y(lbTelephone), 50, 20)];
            [btnTelephone setTag:2];
            [btnTelephone addTarget:self action:@selector(dialClick:) forControlEvents:UIControlEventTouchUpInside];
            [btnTelephone setImage:[UIImage imageNamed:@"img_dial.png"] forState:UIControlStateNormal];
            [btnTelephone.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [btnTelephone setTitle:@"拨打" forState:UIControlStateNormal];
            [btnTelephone setTitleColor:GREENCOLOR forState:UIControlStateNormal];
            [btnTelephone.titleLabel setFont:FONT(10)];
            [btnTelephone setImageEdgeInsets:UIEdgeInsetsMake(2, -3, 2, 0)];
            [btnTelephone setTitleEdgeInsets:UIEdgeInsetsMake(0, -13, 0, 0)];
            btnTelephone.layer.borderColor = [GREENCOLOR CGColor];
            btnTelephone.layer.borderWidth = 1;
            btnTelephone.layer.cornerRadius = 3;
            [self.viewContact addSubview:btnTelephone];
        }
        heightForContact = VIEW_BY(lbTelephone);
    }
    return heightForContact;
}

- (void)dialClick:(UIButton *)button {
    NSString *no;
    if (button.tag == 1) {
        no = [self.jobData objectForKey:@"caMobile"];
    }
    else {
        no = [self.jobData objectForKey:@"caTel"];
    }
    NSRange r = [no rangeOfString:@"["];
    if (r.location != NSNotFound) {
        no = [no substringToIndex:r.location - 1];
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", no]]];
}

- (void)setTitleButton:(UIButton *)btnAttention btnShare:(UIButton *)btnShare {
    [btnAttention setTitle:[self.jobData objectForKey:@"id"] forState:UIControlStateNormal];
    [btnShare setTag:0];
    if ([[self.jobData objectForKey:@"hasAttention"] boolValue]) {
        [btnAttention setImage:[UIImage imageNamed:@"img_favorite1.png"] forState:UIControlStateNormal];
        [btnAttention setTag:0];
    }
    else {
        [btnAttention setImage:[UIImage imageNamed:@"img_favorite2.png"] forState:UIControlStateNormal];
        [btnAttention setTag:2];
    }
}

- (void)changeAttention {
    NSMutableDictionary *data = [self.jobData mutableCopy];
    [data setValue:@"true" forKey:@"hasAttention"];
    self.jobData = data;
}

- (void)WKApplyViewConfirm:(WKApplyView *)applyView arrayJobId:(NSString *)cvMainId {
    if (applyView.tag == 1001) {
        [self applyJob:cvMainId];
    }
    else if (applyView.tag == 1002) {
        [self gotoChat:cvMainId];
    }
}

- (void)WKApplyViewApplyBatch:(NSArray *)arrayJobId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"PaMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.selCvMainId, @"strCvMainID", [arrayJobId componentsJoinedByString:@","], @"strJobIDs", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
    [request setTag:5];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)applySuccess:(NSArray *)arrayJob {
    if (arrayJob.count == 0) {
        return;
    }
    NSMutableArray *arrayJobWithoutThisJob = [arrayJob mutableCopy];
    for (NSDictionary *data in arrayJobWithoutThisJob) {
        if ([[data objectForKey:@"ID"] isEqualToString:[self.jobData objectForKey:@"id"]]) {
            [arrayJobWithoutThisJob removeObject:data];
            break;
        }
    }
    WKApplyView *recommendView = [[WKApplyView alloc] initWithRecommendJob:arrayJobWithoutThisJob];
    [recommendView setDelegate:self];
    [recommendView showRecommend:self];
}

- (void)chatClick {
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        [self.view.window makeToast:@"您当前的角色为企业，请切换至求职者后方可操作"];
        return;
    }
    if (!PERSONLOGIN) {
        [self loginClick];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:6];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 点击事件
- (void)complainClick{
    ComplainViewController *cvc = [ComplainViewController new];
    cvc.jobId = self.jobData[@"id"];
    cvc.caMainId = self.jobData[@"caMainID"];
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)presentOneMinutesViewController{
    OneMinuteCVViewController *oneCV = [[OneMinuteCVViewController alloc]init];
    oneCV.pageType = PageType_JobInfo;
    [self.navigationController pushViewController:oneCV animated:NO];
}

- (void)checkCvExpStatus:(NSArray *)jobArr{
    for (NSDictionary *cvDict in self.cvListApplyArr) {
        BOOL expStatus = [cvDict[@"CvExpStatus"] boolValue];
        cvExpStatus = expStatus || cvExpStatus;
    }
    
    // 无工作尽力则提示补充工作经历
    if(cvExpStatus == NO){
        NSString *cvMainId = @"";
        for (NSDictionary *cvDict in self.cvListApplyArr) {
            cvMainId = cvDict[@"ID"];
        }
        ApplySucceedAlert *applySucceedAlert = [ApplySucceedAlert new];
        [applySucceedAlert show];
        __weak typeof(self)weakself = self;
        applySucceedAlert.completeInformation = ^{
            DLog(@"去完善");
            ExperienceModifyViewController *evc = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"experienceModifyView"];
            evc.cvMainId = cvMainId;
            [weakself.navigationController pushViewController:evc animated:YES];
        };
    
    }else if (self.cvListApplyArr.count > 1){// 有多个简历则选择可以改变投递的简历
        SelectCvAlert *selectAlert = [[SelectCvAlert alloc]initWithData:self.cvListApplyArr];
        [selectAlert show];
        selectAlert.ensureEvent = ^(NSString *cvMainID) {
            
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"PaMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", cvMainID, @"strCvMainID", [self.jobData objectForKey:@"id"], @"strJobIDs", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
            [request setTag:8];
            [request setDelegate:self];
            [request startAsynchronous];
            self.runningRequest = request;
            
        };
        
    }else if(jobArr != nil && jobArr.count > 0){// 投递成功后展示推荐职位
        [self applySuccess:jobArr];
    }
}

@end
