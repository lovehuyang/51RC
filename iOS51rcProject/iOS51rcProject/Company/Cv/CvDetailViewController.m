//
//  CvDetailViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/10.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  简历详情页面

#import "CvDetailViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "UIImageView+WebCache.h"
#import "CvOperate.h"
#import "UIView+Toast.h"
#import "OrderApplyViewController.h"

@interface CvDetailViewController ()<NetWebServiceRequestDelegate, UIScrollViewDelegate, CvOperateDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) CvOperate *operate;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GDataXMLDocument *xmlData;
@property (nonatomic, strong) NSString *applyLogId;
@property float heightForScroll;
@property float widthForView;
@property float paddingLeft;
@end

@implementation CvDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:SEPARATECOLOR];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 51)];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
    self.widthForView = SCREEN_WIDTH - 20;
    self.paddingLeft = 10;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

#pragma mark - 获取简历详情
- (void)getData {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCvDetailByView" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.cvMainId, @"cvMainID", self.jobId, @"intJobID", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillData {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    NSDictionary *otherData = [[Common getArrayFromXml:self.xmlData tableName:@"dtOtherInfo"] objectAtIndex:0];
    //self.title = [NSString stringWithFormat:@"简历编号：%@", [cvData objectForKey:@"SecondId"]];
    self.title = @"简历详情";
    if (self.operate == nil) {
        self.operate = [[CvOperate alloc] init:self.cvMainId paName:[paData objectForKey:@"Name"] viewController:self];
        [self.operate setJobId:self.jobId];
        [self.operate setDelegate:self];
    }
    else {
        [self.operate setPaName:[paData objectForKey:@"Name"]];
    }
    UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 15, 0, 0)];
    if ([[otherData objectForKey:@"RecruitmentCerInfo"] length] > 0) {
        WKLabel *lbRecruitment = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(45, 15, SCREEN_WIDTH - 55, 10) content:[otherData objectForKey:@"RecruitmentCerInfo"] size:DEFAULTFONTSIZE color:NAVBARCOLOR spacing:10];
        [self.scrollView addSubview:lbRecruitment];
        
        UIImageView *imgRecruitment = [[UIImageView alloc] initWithFrame:CGRectMake(15, VIEW_Y(lbRecruitment), 20, 20)];
        [imgRecruitment setContentMode:UIViewContentModeScaleAspectFit];
        [imgRecruitment setImage:[UIImage imageNamed:@"cp_cvrm.png"]];
        [self.scrollView addSubview:imgRecruitment];
        
        viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbRecruitment) + 15, 0, 0)];
    }
    
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewTop];
    
    bool hasApplyed = NO;
    if ([[otherData objectForKey:@"MatchJobName"] length] > 0) {
        hasApplyed = YES;
    }
    if (hasApplyed) {
        WKLabel *lbApply = [[WKLabel alloc] initWithFixedHeight:CGRectMake(self.paddingLeft, 10, 500, 20) content:[NSString stringWithFormat:@"应聘：%@", [otherData objectForKey:@"MatchJobName"]] size:DEFAULTFONTSIZE color:nil];
        [viewTop addSubview:lbApply];
        
        WKLabel *lbMatch = [[WKLabel alloc] initWithFrame:CGRectMake(self.widthForView - 85, VIEW_Y(lbApply), 80, 20) content:@"" size:DEFAULTFONTSIZE color:nil];
        [lbMatch setTextAlignment:NSTextAlignmentRight];
        NSMutableAttributedString *matchString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"匹配度%@%%", [otherData objectForKey:@"MatchPercent"]]];
        [matchString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(3, matchString.length - 3)];
        [lbMatch setAttributedText:matchString];
        [viewTop addSubview:lbMatch];
    }
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, (hasApplyed ? 30 : 20), 77, 77)];
    [imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
    [imgPhoto.layer setCornerRadius:VIEW_W(imgPhoto) / 2];
    [imgPhoto.layer setMasksToBounds:YES];
    [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[otherData objectForKey:@"PaPhotoInfo"]] placeholderImage:[UIImage imageNamed:([[paData objectForKey:@"Gender"] boolValue] ? @"img_photowoman.png" : @"img_photoman.png")]];
    [imgPhoto setCenter:CGPointMake(self.widthForView / 2, imgPhoto.center.y)];
    [viewTop addSubview:imgPhoto];
    
    WKLabel *lbName = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgPhoto) + 10, self.widthForView, 20) content:[otherData objectForKey:@"PaShowTitle"] size:BIGGESTFONTSIZE color:nil];
    [lbName setTextAlignment:NSTextAlignmentCenter];
    [viewTop addSubview:lbName];
    
    NSString *gender;
    if ([[paData objectForKey:@"LivePlace"] length] > 0) {
        gender = ([[paData objectForKey:@"Gender"] boolValue] ? @"女" : @"男");
    }
    else {
        gender = @"";
    }
    
    NSString *workYears = @"";
    if ([[cvData objectForKey:@"RelatedWorkYears"] isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([[cvData objectForKey:@"RelatedWorkYears"] isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([[cvData objectForKey:@"RelatedWorkYears"] length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", [cvData objectForKey:@"RelatedWorkYears"]];
    }
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbName) + 5, self.widthForView, 20) content:[NSString stringWithFormat:@"%@ | %@岁%@%@", gender, [paData objectForKey:@"Age"], (workYears.length == 0 ? @"": [NSString stringWithFormat:@" | %@工作经验", workYears]), ([[cvData objectForKey:@"DegreeName"] length] == 0 ? @"": [NSString stringWithFormat:@" | %@", [cvData objectForKey:@"DegreeName"]])] size:DEFAULTFONTSIZE color:nil];
    [lbDetail setTextAlignment:NSTextAlignmentCenter];
    [viewTop addSubview:lbDetail];
    
    WKLabel *lbCareer = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbDetail) + 10, self.widthForView, 10) content:[NSString stringWithFormat:@"%@（%@更新）", ([[paData objectForKey:@"CareerStatus"] length] > 0 ? [paData objectForKey:@"CareerStatus"] : @"求职状态未填写"), [Common stringFromDateString:[cvData objectForKey:@"RefreshDate"] formatType:@"yyyy年MM月dd日"]] size:DEFAULTFONTSIZE color:nil];
    [lbCareer setTextAlignment:NSTextAlignmentCenter];
    [viewTop addSubview:lbCareer];
    
    [viewTop setFrame:CGRectMake(self.paddingLeft, VIEW_Y(viewTop), self.widthForView, VIEW_BY(lbCareer) + 15)];
    [viewTop.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewTop);
}

- (void)fillBasic {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSString *gender, *birth;
    if ([[paData objectForKey:@"LivePlace"] length] > 0) {
        gender = ([[paData objectForKey:@"Gender"] boolValue] ? @"女" : @"男");
        birth = [NSString stringWithFormat:@"%@年%@月", [[paData objectForKey:@"BirthDay"] substringToIndex:4], [[paData objectForKey:@"BirthDay"] substringFromIndex:4]];
    }
    else {
        gender = @"";
        birth = @"";
    }
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem1.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"基本信息" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    WKLabel *lbLivePlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 15, 500, 20) content:@"现居住地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameLivePlaceTitle = lbLivePlaceTitle.frame;
    frameLivePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameLivePlaceTitle.size.width;
    [lbLivePlaceTitle setFrame:frameLivePlaceTitle];
    [viewContent addSubview:lbLivePlaceTitle];
    
    NSString *liveRegion = [paData objectForKey:@"LiveRegion"];
    if ([[paData objectForKey:@"MapPlaceName"] length] > 0) {
        liveRegion = [NSString stringWithFormat:@"%@（%@）", liveRegion, [paData objectForKey:@"MapPlaceName"]];
    }
    WKLabel *lbLivePlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLivePlaceTitle), VIEW_Y(lbLivePlaceTitle), self.widthForView - VIEW_BX(lbLivePlaceTitle) - 15, 20) content:liveRegion size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbLivePlace];
    
    WKLabel *lbAccountPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbLivePlace) + 10, 500, 20) content:@"户口所在地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameAccountPlaceTitle = lbAccountPlaceTitle.frame;
    frameAccountPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameAccountPlaceTitle.size.width;
    [lbAccountPlaceTitle setFrame:frameAccountPlaceTitle];
    [viewContent addSubview:lbAccountPlaceTitle];
    
    WKLabel *lbAccountPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbAccountPlaceTitle), VIEW_Y(lbAccountPlaceTitle), self.widthForView - VIEW_BX(lbAccountPlaceTitle) - 15, 20) content:[paData objectForKey:@"AccountRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbAccountPlace];
    
    WKLabel *lbGrowPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbAccountPlaceTitle) + 10, 500, 20) content:@"我成长在：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameGrowPlaceTitle = lbGrowPlaceTitle.frame;
    frameGrowPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameGrowPlaceTitle.size.width;
    [lbGrowPlaceTitle setFrame:frameGrowPlaceTitle];
    [viewContent addSubview:lbGrowPlaceTitle];
    
    WKLabel *lbGrowPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbGrowPlaceTitle), VIEW_Y(lbGrowPlaceTitle), self.widthForView - VIEW_BX(lbGrowPlaceTitle) - 15, 20) content:[paData objectForKey:@"GrowRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbGrowPlace];
    
    WKLabel *lbLoginDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbGrowPlaceTitle) + 10, 500, 20) content:@"登录时间：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameLoginDateTitle = lbLoginDateTitle.frame;
    frameLoginDateTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameLoginDateTitle.size.width;
    [lbLoginDateTitle setFrame:frameLoginDateTitle];
    [viewContent addSubview:lbLoginDateTitle];
    
    WKLabel *lbLoginDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLoginDateTitle), VIEW_Y(lbLoginDateTitle), self.widthForView - VIEW_BX(lbLoginDateTitle) - 15, 20) content:[Common stringFromDateString:[paData objectForKey:@"LastLoginDate"] formatType:@"yyyy-MM-dd HH:mm"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbLoginDate];
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(lbLoginDate) + 15)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillJobIntention {
    NSDictionary *jobIntentionData = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"", nil];
    NSArray *arrayJobIntention = [Common getArrayFromXml:self.xmlData tableName:@"JobIntention"];
    if (arrayJobIntention.count > 0) {
        jobIntentionData = [arrayJobIntention objectAtIndex:0];
    }
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem2.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"求职意向" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    WKLabel *lbJobTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 15, 500, 20) content:@"工作职位：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameJobTypeTitle = lbJobTypeTitle.frame;
    frameJobTypeTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameJobTypeTitle.size.width;
    [lbJobTypeTitle setFrame:frameJobTypeTitle];
    [viewContent addSubview:lbJobTypeTitle];
    
    WKLabel *lbJobType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobTypeTitle), VIEW_Y(lbJobTypeTitle), self.widthForView - VIEW_BX(lbJobTypeTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbJobType];
    
    WKLabel *lbPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbJobType) + 10, 500, 20) content:@"工作地点：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect framePlaceTitle = lbPlaceTitle.frame;
    framePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - framePlaceTitle.size.width;
    [lbPlaceTitle setFrame:framePlaceTitle];
    [viewContent addSubview:lbPlaceTitle];
    
    WKLabel *lbPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbPlaceTitle), VIEW_Y(lbPlaceTitle), self.widthForView - VIEW_BX(lbPlaceTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobPlaceName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbPlace];
    
    WKLabel *lbSalaryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbPlace) + 10, 500, 20) content:@"期望月薪：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameSalaryTitle = lbSalaryTitle.frame;
    frameSalaryTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameSalaryTitle.size.width;
    [lbSalaryTitle setFrame:frameSalaryTitle];
    [viewContent addSubview:lbSalaryTitle];
    
    NSString *salary = @"";
    if ([[jobIntentionData objectForKey:@"Salary"] length] > 0) {
        salary = [NSString stringWithFormat:@"%@ %@", [jobIntentionData objectForKey:@"Salary"], ([[jobIntentionData objectForKey:@"IsNegotiable"] boolValue] ? @"可面议" : @"不可面议")];
    }
    WKLabel *lbSalary = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbSalaryTitle), VIEW_Y(lbSalaryTitle), self.widthForView - VIEW_BX(lbSalaryTitle) - 15, 20) content:salary size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbSalary];
    
    WKLabel *lbEmployTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbSalary) + 10, 500, 20) content:@"工作性质：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameEmployTypeTitle = lbEmployTypeTitle.frame;
    frameEmployTypeTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameEmployTypeTitle.size.width;
    [lbEmployTypeTitle setFrame:frameEmployTypeTitle];
    [viewContent addSubview:lbEmployTypeTitle];
    
    WKLabel *lbEmployType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEmployTypeTitle), VIEW_Y(lbEmployTypeTitle), self.widthForView - VIEW_BX(lbEmployTypeTitle) - 15, 20) content:[cvData objectForKey:@"EmployTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbEmployType];
    
    WKLabel *lbIndustryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbEmployType) + 10, 500, 20) content:@"期望从事行业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameIndustryTitle = lbIndustryTitle.frame;
    frameIndustryTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameIndustryTitle.size.width;
    [lbIndustryTitle setFrame:frameIndustryTitle];
    [viewContent addSubview:lbIndustryTitle];
    
    WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), self.widthForView - VIEW_BX(lbIndustryTitle) - 15, 20) content:[jobIntentionData objectForKey:@"IndustryName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbIndustry];
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, (lbIndustry.text.length > 0 ? VIEW_BY(lbIndustry) : VIEW_BY(lbIndustryTitle)) + 15)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillEducation {
    NSArray *arrayEducation = [Common getArrayFromXml:self.xmlData tableName:@"Education"];
    
    if (arrayEducation.count == 0) {
        return;
    }
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem3.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"教育背景" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    self.heightForScroll = VIEW_BY(lbTitle);
    float heightForEducation = 15;
    for (NSDictionary *data in arrayEducation) {
        NSString *graduation = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"Graduation"] substringToIndex:4], [[data objectForKey:@"Graduation"] substringFromIndex:4]];
        
        float widthForLable = SCREEN_WIDTH - 60;
        WKLabel *lbGraduation = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(30, heightForEducation, widthForLable, 20) content:graduation size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbGraduation];
        
        WKLabel *lbCollege = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbGraduation), VIEW_BY(lbGraduation) + 10, widthForLable, 20) content:[data objectForKey:@"GraduateCollage"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbCollege];
        
        WKLabel *lbOther = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCollege), VIEW_BY(lbCollege) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@（%@）", [data objectForKey:@"Major"], [data objectForKey:@"MajorName"], [data objectForKey:@"DegreeName"], [data objectForKey:@"EduTypeName"]] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbOther];
        
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbOther), VIEW_BY(lbOther) + 10, widthForLable, 20) content:[data objectForKey:@"Details"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbDetail];
        
        UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbGraduation) - 20, VIEW_Y(lbGraduation) + 3, 10, 10)];
        [viewTips setBackgroundColor:UIColorWithRGBA(171, 171, 171, 1)];
        viewTips.layer.cornerRadius = 5;
        viewTips.layer.borderColor = [UIColorWithRGBA(215, 215, 215, 1) CGColor];
        viewTips.layer.borderWidth = 2;
        [viewContent addSubview:viewTips];
        
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewTips) + 4.5, VIEW_BY(viewTips), 1, (lbDetail.text.length > 0 ? VIEW_BY(lbDetail) : VIEW_BY(lbOther)) - VIEW_BY(viewTips))];
        [viewLine setBackgroundColor:SEPARATECOLOR];
        [viewContent addSubview:viewLine];
        
        heightForEducation = (lbDetail.text.length > 0 ? VIEW_BY(lbDetail) : VIEW_BY(lbOther)) + 15;
    }
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, heightForEducation)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillExperience {
    NSArray *arrayExperience = [Common getArrayFromXml:self.xmlData tableName:@"Experience"];
    
    if (arrayExperience.count == 0) {
        return;
    }
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem4.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"工作经历" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    float heightForExperience = 15;
    for (NSDictionary *data in arrayExperience) {
        float widthForLable = SCREEN_WIDTH - 60;
        NSString *beginDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"BeginDate"] substringToIndex:4], [[data objectForKey:@"BeginDate"] substringFromIndex:5]];
        NSString *endDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"EndDate"] substringToIndex:4], [[data objectForKey:@"EndDate"] substringFromIndex:5]];
        if ([[data objectForKey:@"EndDate"] isEqualToString:@"999999"]) {
            endDate = @"至今";
        }
        WKLabel *lbWorkDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(30, heightForExperience, widthForLable, 20) content:[NSString stringWithFormat:@"%@ 至 %@", beginDate, endDate] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbWorkDate];
        
        WKLabel *lbCompanyName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbWorkDate) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"CompanyName"], [data objectForKey:@"JobName"], [data objectForKey:@"LowerNumber"]] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbCompanyName];
        
        WKLabel *lbIndustryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbCompanyName) + 10, 500, 20) content:@"所属行业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
        [viewContent addSubview:lbIndustryTitle];
        
        WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), widthForLable - VIEW_W(lbIndustryTitle), 20) content:[data objectForKey:@"Industry"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbIndustry];
        
        WKLabel *lbDetailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbIndustry) + 10, 500, 20) content:@"工作描述：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
        [viewContent addSubview:lbDetailTitle];
        
        if ([[data objectForKey:@"CpmpanySize"] length] > 0) {
            WKLabel *lbCompanySizeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbIndustry) + 10, 500, 20) content:@"企业规模：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            [viewContent addSubview:lbCompanySizeTitle];
            
            WKLabel *lbCompanySize = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCompanySizeTitle), VIEW_Y(lbCompanySizeTitle), widthForLable, 20) content:[data objectForKey:@"CpmpanySize"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [viewContent addSubview:lbCompanySize];
            
            [lbDetailTitle setFrame:CGRectMake(VIEW_X(lbDetailTitle), VIEW_BY(lbCompanySize) + 10, VIEW_W(lbDetailTitle), VIEW_H(lbDetailTitle))];
        }
        
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbDetailTitle), VIEW_Y(lbDetailTitle), widthForLable - VIEW_W(lbIndustryTitle), 20) content:[data objectForKey:@"Description"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbDetail];
        
        UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbWorkDate) - 20, VIEW_Y(lbWorkDate) + 3, 10, 10)];
        [viewTips setBackgroundColor:UIColorWithRGBA(171, 171, 171, 1)];
        viewTips.layer.cornerRadius = 5;
        viewTips.layer.borderColor = [UIColorWithRGBA(215, 215, 215, 1) CGColor];
        viewTips.layer.borderWidth = 2;
        [viewContent addSubview:viewTips];
        
        UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewTips) + 4.5, VIEW_BY(viewTips), 1, VIEW_BY(lbDetail) - VIEW_BY(viewTips))];
        [viewLine setBackgroundColor:SEPARATECOLOR];
        [viewContent addSubview:viewLine];
        
        heightForExperience = (lbDetail.text.length > 0 ? VIEW_BY(lbDetail) : VIEW_BY(lbDetailTitle)) + 15;
    }
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, heightForExperience)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillSpeciality {
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    
    if ([[cvData objectForKey:@"Speciality"] length] == 0) {
        return;
    }
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem5.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"工作能力" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    WKLabel *lbSpeciality = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(20, 15, SCREEN_WIDTH - 60, 20) content:[cvData objectForKey:@"Speciality"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbSpeciality];
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(lbSpeciality) + 15)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillLink {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *otherData = [[Common getArrayFromXml:self.xmlData tableName:@"dtOtherInfo"] objectAtIndex:0];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem6.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"联系方式" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [viewContent.layer setCornerRadius:5];
    [self.scrollView addSubview:viewContent];
    
    NSArray *arrayApply = [Common getArrayFromXml:self.xmlData tableName:@"dtApplyLog"];
    self.applyLogId = @"";
    bool notReply = NO;
    if (arrayApply.count > 0) {
        for (NSDictionary *data in arrayApply) {
            self.applyLogId = [data objectForKey:@"ID"];
            if ([[data objectForKey:@"Reply"] isEqualToString:@"0"]) {
                notReply = YES;
            }
        }
    }
    if (notReply) {// 未答复
        WKLabel *lbReplyTips = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(self.paddingLeft, 15, self.widthForView - (self.paddingLeft * 2), 10) content:@"做出答复后即可展示联系方式，请点击下方的按钮进行答复" size:DEFAULTFONTSIZE color:[UIColor grayColor] spacing:10];
        [viewContent addSubview:lbReplyTips];
        
        UIButton *btnPass = [[UIButton alloc] initWithFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbReplyTips) + 10, (self.widthForView - 30) / 2, 50)];
        [btnPass setTag:1];
        [btnPass setTitle:@"符合要求，我会联系TA" forState:UIControlStateNormal];
        [btnPass.titleLabel setFont:DEFAULTFONT];
        [btnPass setBackgroundColor:CPNAVBARCOLOR];
        [btnPass addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnPass.layer setCornerRadius:5];
        [viewContent addSubview:btnPass];
        
        UIButton *btnDeny = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnPass) + 10, VIEW_Y(btnPass), VIEW_W(btnPass), VIEW_H(btnPass))];
        [btnDeny setTag:2];
        [btnDeny setTitle:@"暂不合适，放入储备人才库" forState:UIControlStateNormal];
        [btnDeny.titleLabel setFont:DEFAULTFONT];
        [btnDeny.titleLabel setNumberOfLines:0];
        [btnDeny setBackgroundColor:NAVBARCOLOR];
        [btnDeny addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
        [btnDeny.layer setCornerRadius:5];
        [viewContent addSubview:btnDeny];
        
        [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(btnPass) + 15)];
    }
    else {// 已答复
        if (arrayApply.count > 0) {
            NSDictionary *applyData = [arrayApply objectAtIndex:0];
            // reply == 1:不符合要求 ； reply == 2：符合要求
            bool replyPass = [[applyData objectForKey:@"Reply"] isEqualToString:@"1"];
            WKLabel *lbReply = [[WKLabel alloc] initWithFixedHeight:CGRectMake(self.paddingLeft, 10, SCREEN_WIDTH, 20) content:[NSString stringWithFormat:@"已答复简历%@", (replyPass ? @"符合要求" : @"不符合要求")] size:DEFAULTFONTSIZE color:nil];
            [viewContent addSubview:lbReply];
            
            UIView *viewLink = [[UIView alloc] init];
            [viewLink setBackgroundColor:CPNAVBARCOLOR];
            [viewContent addSubview:viewLink];
            
            NSString *link = [NSString stringWithFormat:@"手机：%@\n邮箱：%@", [paData objectForKey:@"Mobile"], [paData objectForKey:@"Email"]];
            if ([[paData objectForKey:@"Email"] rangeOfString:@"your_email"].location != NSNotFound) {
                link = [NSString stringWithFormat:@"手机：%@", [paData objectForKey:@"Mobile"]];
            }
            WKLabel *lbLink = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(5, 5, 500, 20) content:link size:DEFAULTFONTSIZE color:[UIColor whiteColor] spacing:0];
            [viewContent addSubview:lbLink];
            [viewLink addSubview:lbLink];
            lbLink.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapLink = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mobileClick)];
            [lbLink addGestureRecognizer:tapLink];
            
            [viewLink setFrame:CGRectMake(VIEW_X(lbReply), VIEW_BY(lbReply) + 10, VIEW_BX(lbLink) + 5, VIEW_BY(lbLink) + 5)];
            
            float widthForButton = self.widthForView - VIEW_BX(viewLink) - VIEW_X(lbReply);
            float xForButton = VIEW_BX(viewLink), yForButton = VIEW_Y(viewLink);
            if (widthForButton < self.widthForView * 0.4 && replyPass) {
                xForButton = self.paddingLeft;
                yForButton = VIEW_BY(viewLink);
                widthForButton = self.widthForView - self.paddingLeft * 2;
                [viewLink setFrame:CGRectMake(VIEW_X(viewLink), VIEW_Y(viewLink), widthForButton, VIEW_H(viewLink) + 5)];
            }
            UIButton *btnReply;
            if (replyPass) {
                widthForButton = widthForButton / 2;
                UIButton *btnInterview = [[UIButton alloc] initWithFrame:CGRectMake(xForButton, yForButton, widthForButton, VIEW_H(viewLink))];
                [btnInterview setTitle:@"发送面试通知" forState:UIControlStateNormal];
                [btnInterview.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [btnInterview.titleLabel setNumberOfLines:0];
                [btnInterview setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnInterview setBackgroundColor:GREENCOLOR];
                [btnInterview.titleLabel setFont:DEFAULTFONT];
                [btnInterview addTarget:self action:@selector(interviewClick) forControlEvents:UIControlEventTouchUpInside];
                [viewContent addSubview:btnInterview];
                btnReply.backgroundColor = [UIColor redColor];
                btnReply = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnInterview), VIEW_Y(btnInterview), widthForButton, VIEW_H(viewLink))];
                [btnReply setTag:2];
                [btnReply setTitle:@"改为暂不合适，放入储备人才库" forState:UIControlStateNormal];
                [btnReply setBackgroundColor:[UIColor redColor]];
                [btnReply.titleLabel setNumberOfLines:0];
                [btnReply.titleLabel setTextAlignment:NSTextAlignmentCenter];
                [btnReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btnReply.titleLabel setFont:SMALLERFONT];
            }
            else {
                [viewLink setBackgroundColor:[UIColor grayColor]];
                [lbLink setTextColor:[UIColor whiteColor]];
                
                btnReply = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(viewLink), VIEW_Y(viewLink), widthForButton, VIEW_H(viewLink))];
                [btnReply setTag:1];
                [btnReply setTitle:@"改为符合要求" forState:UIControlStateNormal];
                [btnReply setBackgroundColor:[UIColor whiteColor]];
                [btnReply setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
                [btnReply setTitleEdgeInsets:UIEdgeInsetsMake(0, 15, 0, 0)];
                [btnReply setTitleColor:CPNAVBARCOLOR forState:UIControlStateNormal];
                [btnReply.titleLabel setFont:DEFAULTFONT];
            }
            [btnReply.titleLabel setNumberOfLines:0];
            [btnReply addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewContent addSubview:btnReply];
            
            [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(btnReply) + 15)];
        }
        else {
            NSString *link = [NSString stringWithFormat:@"手机：%@\n邮箱：%@", [paData objectForKey:@"Mobile"], [paData objectForKey:@"Email"]];
            if ([[paData objectForKey:@"Email"] rangeOfString:@"your_email"].location != NSNotFound) {
                link = [NSString stringWithFormat:@"手机：%@", [paData objectForKey:@"Mobile"]];
            }
            WKLabel *lbLink = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(self.paddingLeft, 15, 500, 20) content:link size:DEFAULTFONTSIZE color:nil spacing:0];
            [viewContent addSubview:lbLink];
            lbLink.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapLink = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(mobileClick)];
            [lbLink addGestureRecognizer:tapLink];
            
            [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(lbLink) + 15)];
        }
        if ([[otherData objectForKey:@"CpMemberType"] integerValue] < 2) {
            WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(self.paddingLeft, VIEW_H(viewContent) - 5, self.widthForView - (self.paddingLeft * 2), 10) content:@"尽管您已经是我们的企业用户，但至今没有通过企业认证，无法看到联系方式。" size:DEFAULTFONTSIZE color:[UIColor redColor] spacing:10];
            [viewContent addSubview:lbWarning];
            [viewContent setFrame:CGRectMake(VIEW_X(viewContent), VIEW_Y(viewContent), VIEW_W(viewContent), VIEW_BY(lbWarning) + 15)];
        }
        else if ([[otherData objectForKey:@"IsPassed"] isEqualToString:@"0"]) {
            NSString *noticeText = [otherData objectForKey:@"NoticeTextIOS"];
            NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
            if (![[cvData objectForKey:@"isOpen"] boolValue] && [[otherData objectForKey:@"CpMemberType"] integerValue] < 3) {
                WKButton *btnVip = [[WKButton alloc] initWithFrame:CGRectMake(self.paddingLeft, VIEW_H(viewContent) - 5, 100, 40) title:@"申请VIP会员" fontSize:DEFAULTFONTSIZE color:[UIColor whiteColor] bgColor:GREENCOLOR];
                [btnVip addTarget:self action:@selector(vipClick) forControlEvents:UIControlEventTouchUpInside];
                [viewContent addSubview:btnVip];
                
                WKLabel *lbVip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(btnVip) + 10, VIEW_Y(btnVip), self.widthForView - VIEW_BX(btnVip) - 10 - self.paddingLeft, VIEW_H(btnVip)) content:@"这份简历位于“非开放简历”库中，联系方式只对VIP会员开放" size:DEFAULTFONTSIZE color:[UIColor redColor] spacing:5];
                [viewContent addSubview:lbVip];
                
                [viewContent setFrame:CGRectMake(VIEW_X(viewContent), VIEW_Y(viewContent), VIEW_W(viewContent), VIEW_BY(lbVip) + 15)];
            }
            else {
                NSArray *arrayNotice = [noticeText componentsSeparatedByString:@"$$##"];
                if (arrayNotice.count == 1) {
                    WKLabel *lbTip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(self.paddingLeft, VIEW_H(viewContent) - 5, self.widthForView - self.paddingLeft * 2, 20) content:noticeText size:DEFAULTFONTSIZE color:[UIColor redColor] spacing:10];
                    [viewContent addSubview:lbTip];
                    [viewContent setFrame:CGRectMake(VIEW_X(viewContent), VIEW_Y(viewContent), VIEW_W(viewContent), VIEW_BY(lbTip) + 15)];
                }
                else {
                    WKButton *btnContact = [[WKButton alloc] initWithFrame:CGRectMake(self.paddingLeft, VIEW_H(viewContent) - 5, 100, 40) title:@"查看联系方式" fontSize:DEFAULTFONTSIZE color:[UIColor whiteColor] bgColor:GREENCOLOR];
                    [btnContact addTarget:self action:@selector(contactClick) forControlEvents:UIControlEventTouchUpInside];
                    [viewContent addSubview:btnContact];
                    
                    WKLabel *lbTip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(btnContact) + 10, VIEW_Y(btnContact), self.widthForView - VIEW_BX(btnContact) - 10 - self.paddingLeft, VIEW_H(btnContact)) content:[arrayNotice objectAtIndex:0] size:DEFAULTFONTSIZE color:[UIColor redColor] spacing:5];
                    [viewContent addSubview:lbTip];
                    
                    [viewContent setFrame:CGRectMake(VIEW_X(viewContent), VIEW_Y(viewContent), VIEW_W(viewContent), VIEW_BY(lbTip) + 15)];
                }
            }
        }
    }
    self.heightForScroll = VIEW_BY(viewContent);
    
    UIView *viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.scrollView) + 1, SCREEN_WIDTH, 50)];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewBottom];
    if (notReply) {
        WKButton *btnReply = [[WKButton alloc] initWithFrame:CGRectMake(50, 7.5, (VIEW_W(viewBottom) - 150) / 2, 35) title:@"答复" fontSize:DEFAULTFONTSIZE color:[UIColor whiteColor] bgColor:CPNAVBARCOLOR];
        [btnReply addTarget:self action:@selector(replyScroll) forControlEvents:UIControlEventTouchUpInside];
        [viewBottom addSubview:btnReply];
        btnReply.layer.cornerRadius = 3;
        
        WKButton *btnChat = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnReply) + 50, VIEW_Y(btnReply), VIEW_W(btnReply), VIEW_H(btnReply)) image:@"cp_chat.png" title:@"跟TA聊聊" fontSize:DEFAULTFONTSIZE color:GREENCOLOR bgColor:[UIColor clearColor]];
        [btnChat addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
        [viewBottom addSubview:btnChat];
    }
    else {
        
        NSDictionary *applyData = [arrayApply objectAtIndex:0];
        // reply == 1:符合要求 ； reply == 2：储备;reply == 5:储备（自动）
        NSString *replyStatus = [applyData objectForKey:@"Reply"];
        
//        WKButton *btnInvitation = [[WKButton alloc] initWithFrame:CGRectMake(30, 10, (VIEW_W(viewBottom) - 120) / 3, 30) title:@"应聘邀请" fontSize:DEFAULTFONTSIZE color:[UIColor whiteColor] bgColor:CPNAVBARCOLOR];
//        [btnInvitation addTarget:self action:@selector(invitationClick) forControlEvents:UIControlEventTouchUpInside];
//        [viewBottom addSubview:btnInvitation];
        
        CGFloat BTN_W = (VIEW_W(viewBottom) - 30 *3)/2;
        CGFloat BTN_H = 35;
        WKButton *btnInterview = [[WKButton alloc] initWithFrame:CGRectMake(30, 7.5, BTN_W,BTN_H) title:@"面试通知" fontSize:DEFAULTFONTSIZE color:[UIColor whiteColor] bgColor:CPNAVBARCOLOR];
        [btnInterview addTarget:self action:@selector(interviewClick) forControlEvents:UIControlEventTouchUpInside];
        [viewBottom addSubview:btnInterview];
        btnInterview.layer.cornerRadius = 3;
        
        WKButton *btnChat = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, 7.5, BTN_W, BTN_H) image:@"cp_chat.png" title:@"跟TA聊聊" fontSize:DEFAULTFONTSIZE color:GREENCOLOR bgColor:[UIColor clearColor]];
        [btnChat addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
        
        if ([replyStatus isEqualToString:@"1"]) {// 通过
            
            btnInterview.frame = CGRectMake(30, 7.5, BTN_W, BTN_H);
            btnChat.frame = CGRectMake(VIEW_BX(btnInterview) + 30, 7.5, BTN_W, BTN_H);
            btnInterview.hidden = NO;
            
        }else if([replyStatus isEqualToString:@"2"]){// 已放入储备人才库
            btnInterview.hidden = YES;
            btnChat.center = CGPointMake(VIEW_W(viewBottom)/2, btnChat.center.y);
        }else{
            btnInterview.hidden = YES;
            btnChat.center = CGPointMake(VIEW_W(viewBottom)/2, btnChat.center.y);
        }
        
        [viewBottom addSubview:btnChat];
    }
}

#pragma mark - 联系
- (void)fillContact {
    NSMutableArray *arrayContact = [[NSMutableArray alloc] init];
    NSDictionary *contactData;
    
    NSArray *arrayApply = [Common getArrayFromXml:self.xmlData tableName:@"dtApplyLog"];
    if (arrayApply.count > 0) {
        contactData = [arrayApply objectAtIndex:0];
        [arrayContact addObject:[NSString stringWithFormat:@"%@ 应聘[%@]", [Common stringFromDateString:[contactData objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd HH:mm"], [contactData objectForKey:@"Name"]]];
    }
    
    NSArray *arrayInterview = [Common getArrayFromXml:self.xmlData tableName:@"dtInterviewLog"];
    if (arrayInterview.count > 0) {
        contactData = [arrayInterview objectAtIndex:0];
        [arrayContact addObject:[NSString stringWithFormat:@"%@ 发送面试通知", [Common stringFromDateString:[contactData objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd HH:mm"]]];
    }
    
    NSArray *arrayFavorate = [Common getArrayFromXml:self.xmlData tableName:@"dtFavorate"];
    if (arrayFavorate.count > 0) {
        contactData = [arrayFavorate objectAtIndex:0];
        [arrayContact addObject:[NSString stringWithFormat:@"%@ 收藏该简历", [Common stringFromDateString:[contactData objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd HH:mm"]]];
    }
    
    NSArray *arrayView = [Common getArrayFromXml:self.xmlData tableName:@"dtViewLog"];
    if (arrayView.count > 0) {
        contactData = [arrayView objectAtIndex:0];
        [arrayContact addObject:[NSString stringWithFormat:@"上次浏览：%@", [Common stringFromDateString:[contactData objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd HH:mm"]]];
    }
    
    if (arrayContact.count == 0) {
        return;
    }
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem7.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"联系记录" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [viewContent.layer setCornerRadius:5];
    [self.scrollView addSubview:viewContent];
    
    WKLabel *lbContact = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(self.paddingLeft, 15, self.widthForView - (self.paddingLeft * 2), 10) content:[arrayContact componentsJoinedByString:@"\n"] size:DEFAULTFONTSIZE color:nil spacing:10];
    [viewContent addSubview:lbContact];
    
    [viewContent setFrame:CGRectMake(self.paddingLeft, VIEW_BY(lbTitle) + 15, self.widthForView, VIEW_BY(lbContact) + 15)];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        self.xmlData = requestData;
        [self fillData];
        [self fillBasic];
        [self fillJobIntention];
        [self fillEducation];
        [self fillExperience];
        [self fillSpeciality];
        [self fillLink];
        [self fillContact];
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForScroll + 20)];
    }
    else if (request.tag == 2) {
        if ([result isEqualToString:@"1"]) {
            [self getData];
        }
        else if ([result rangeOfString:@"#$"].location != NSNotFound) {
            NSArray *arrayReturn = [result componentsSeparatedByString:@"#$"];
            NSString *returnType = [[arrayReturn objectAtIndex:0] lowercaseString];
            NSString *returnValue = [[arrayReturn objectAtIndex:1] lowercaseString];
            NSString *errorString = @"";
            if ([returnType isEqualToString:@"1"]) {
                if ([returnValue isEqualToString:@"-1"]) {
                    errorString = @"您的企业信息或用户信息不正确，请修改后重试";
                }
                else if ([returnValue isEqualToString:@"-2"]) {
                    errorString = @"简历联系方式不完整，不能下载该简历";
                }
                else if ([returnValue isEqualToString:@"-3"]) {
                    errorString = @"本日赠送为0或空";
                }
                else if ([returnValue isEqualToString:@"-4"]) {
                    errorString = @"本日赠送已经消耗完毕";
                }
                else if ([returnValue isEqualToString:@"false"]) {
                    errorString = @"您剩余的每日系统赠送的简历下载数不足";
                }
                else {
                    errorString = @"未知错误，请稍后重试";
                }
            }
            else if ([returnType isEqualToString:@"2"]) {
                if ([returnValue isEqualToString:@"-1"]) {
                    errorString = @"您的企业信息或用户信息不正确，请修改后重试";
                }
                else if ([returnValue isEqualToString:@"-2"]) {
                    errorString = @"简历联系方式不完整，不能下载该简历";
                }
                else if ([returnValue isEqualToString:@"-3"]) {
                    errorString = @"本日赠送为0或空";
                }
                else if ([returnValue isEqualToString:@"-4"]) {
                    errorString = @"剩余简历下载数不足";
                }
                else if ([returnValue isEqualToString:@"false"]) {
                    errorString = @"您剩余的简历下载数不足";
                }
                else {
                    errorString = @"未知错误，请稍后重试";
                }
            }
            else if ([returnType isEqualToString:@"3"]) {
                if ([returnValue isEqualToString:@"-1"]) {
                    errorString = @"您的企业信息或用户信息不正确，请修改后重试";
                }
                else if ([returnValue isEqualToString:@"-2"]) {
                    errorString = @"简历联系方式不完整，不能下载该简历";
                }
                else if ([returnValue isEqualToString:@"-3"]) {
                    errorString = @"您没有积分，不能下载该简历";
                }
                else if ([returnValue isEqualToString:@"-4"]) {
                    errorString = @"您的积分不足，不能下载该简历";
                }
                else if ([returnValue isEqualToString:@"-5"]) {
                    errorString = @"您每天可使用网站积分查看简历的次数已全部用完";
                }
                else {
                    errorString = @"未知错误，请稍后重试";
                }
            }
            [self.view makeToast:errorString];
        }
    }
}

- (void)replyClick:(UIButton *)button {
    [self.operate replyCv:self.applyLogId replyType:[NSString stringWithFormat:@"%ld", button.tag]];
}

- (void)cvOperateFinished {
    [self getData];
}

- (void)interviewClick {
    [self.operate interview];
}

- (void)vipClick {
    OrderApplyViewController *orderApplyCtrl = [[OrderApplyViewController alloc] init];
    orderApplyCtrl.urlString = [NSString stringWithFormat:@"http://%@/company/order/applyvip", [USER_DEFAULT valueForKey:@"subsite"]];
    [self.navigationController pushViewController:orderApplyCtrl animated:YES];
}

- (void)mobileClick {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSString *mobile = [paData objectForKey:@"Mobile"];
    if (mobile.length == 0 || [mobile rangeOfString:@"*"].location != NSNotFound) {
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"telprompt://%@", mobile]]];
}

#pragma mark - 查看联系方式
- (void)contactClick {
    NSDictionary *otherData = [[Common getArrayFromXml:self.xmlData tableName:@"dtOtherInfo"] objectAtIndex:0];
    NSString *noticeText = [otherData objectForKey:@"NoticeTextIOS"];
    NSArray *arrayNotice = [noticeText componentsSeparatedByString:@"$$##"];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:[arrayNotice objectAtIndex:1] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCvContact" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.cvMainId, @"intCvMainID", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)replyScroll {
    [self.scrollView setContentOffset:CGPointMake(0, self.scrollView.contentSize.height - self.scrollView.bounds.size.height) animated:YES];
}

- (void)chatClick {
    [self.operate beginChat];
}

- (void)invitationClick {
    [self.operate invitation];
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
