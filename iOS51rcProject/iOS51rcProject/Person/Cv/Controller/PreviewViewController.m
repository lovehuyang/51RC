//
//  PreviewViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/18.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "PreviewViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "UIImageView+WebCache.h"

@interface PreviewViewController ()<NetWebServiceRequestDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GDataXMLDocument *xmlData;
@property float heightForScroll;
@end

@implementation PreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"简历预览";
    [self.view setBackgroundColor:SEPARATECOLOR];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setDelegate:self];
    [self.view addSubview:self.scrollView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.runningRequest cancel];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y > 170) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
    }
    else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

- (void)getData {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillData {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    
    UIView *viewBlank = [[UIView alloc] initWithFrame:CGRectMake(0, -300, SCREEN_WIDTH, 300)];
    [viewBlank setBackgroundColor:NAVBARCOLOR];
    [self.scrollView addSubview:viewBlank];
    
    UIView *viewTop = [[UIView alloc] init];
    [viewTop setBackgroundColor:NAVBARCOLOR];
    [self.scrollView addSubview:viewTop];
    
    UIButton *btnBack = [[UIButton alloc] initWithFrame:CGRectMake(15, 30, 25, 25)];
    [btnBack setBackgroundImage:[UIImage imageNamed:@"img_back"] forState:UIControlStateNormal];
    [btnBack addTarget:self action:@selector(backClick) forControlEvents:UIControlEventTouchUpInside];
    [viewTop addSubview:btnBack];
    
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, 77, 77)];
    [imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
    [imgPhoto.layer setBorderColor:[UIColorWithRGBA(207, 207, 207, 1) CGColor]];
    [imgPhoto.layer setBorderWidth:3];
    [imgPhoto.layer setCornerRadius:VIEW_W(imgPhoto) / 2];
    [imgPhoto.layer setMasksToBounds:YES];
    [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[paData objectForKey:@"PhotoUrl"]] placeholderImage:[UIImage imageNamed:@"pa_photo.png"]];
    [imgPhoto setCenter:CGPointMake(SCREEN_WIDTH / 2, imgPhoto.center.y)];
    [viewTop addSubview:imgPhoto];
    
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, VIEW_BY(imgPhoto) + 10, 500, 20) content:[paData objectForKey:@"Name"] size:BIGGESTFONTSIZE color:[UIColor whiteColor]];
    [lbName setCenter:CGPointMake(SCREEN_WIDTH / 2, lbName.center.y)];
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
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, VIEW_BY(lbName) + 5, 500, 20) content:[NSString stringWithFormat:@"%@ | %@岁%@%@", gender, [paData objectForKey:@"Age"], (workYears.length == 0 ? @"": [NSString stringWithFormat:@" | %@工作经验", workYears]), ([[cvData objectForKey:@"DegreeName"] length] == 0 ? @"": [NSString stringWithFormat:@" | %@", [cvData objectForKey:@"DegreeName"]])] size:DEFAULTFONTSIZE color:[UIColor whiteColor]];
    [lbDetail setCenter:CGPointMake(SCREEN_WIDTH / 2, lbDetail.center.y)];
    [viewTop addSubview:lbDetail];
    
    [viewTop setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDetail) + 5)];
    
    self.heightForScroll = VIEW_BY(viewTop);
}

- (void)backClick {
    [self.navigationController popViewControllerAnimated:YES];
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
    
    WKLabel *lbBirthTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 15, 500, 20) content:@"出生年月：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameBirthTitle = lbBirthTitle.frame;
    frameBirthTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameBirthTitle.size.width;
    [lbBirthTitle setFrame:frameBirthTitle];
    [viewContent addSubview:lbBirthTitle];
    
    WKLabel *lbBirth = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbBirthTitle), VIEW_Y(lbBirthTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbBirthTitle) - 15, 20) content:birth size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbBirth];
    
    WKLabel *lbLivePlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbBirth) + 10, 500, 20) content:@"现居住地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameLivePlaceTitle = lbLivePlaceTitle.frame;
    frameLivePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameLivePlaceTitle.size.width;
    [lbLivePlaceTitle setFrame:frameLivePlaceTitle];
    [viewContent addSubview:lbLivePlaceTitle];
    
    WKLabel *lbLivePlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLivePlaceTitle), VIEW_Y(lbLivePlaceTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbLivePlaceTitle) - 15, 20) content:[paData objectForKey:@"LiveRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbLivePlace];
    
    WKLabel *lbAccountPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbLivePlace) + 10, 500, 20) content:@"户口所在地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameAccountPlaceTitle = lbAccountPlaceTitle.frame;
    frameAccountPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameAccountPlaceTitle.size.width;
    [lbAccountPlaceTitle setFrame:frameAccountPlaceTitle];
    [viewContent addSubview:lbAccountPlaceTitle];
    
    WKLabel *lbAccountPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbAccountPlaceTitle), VIEW_Y(lbAccountPlaceTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbAccountPlaceTitle) - 15, 20) content:[paData objectForKey:@"AccountRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbAccountPlace];
    
    WKLabel *lbGrowPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbAccountPlace) + 10, 500, 20) content:@"我成长在：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameGrowPlaceTitle = lbGrowPlaceTitle.frame;
    frameGrowPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameGrowPlaceTitle.size.width;
    [lbGrowPlaceTitle setFrame:frameGrowPlaceTitle];
    [viewContent addSubview:lbGrowPlaceTitle];
    
    WKLabel *lbGrowPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbGrowPlaceTitle), VIEW_Y(lbGrowPlaceTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbGrowPlaceTitle) - 15, 20) content:[paData objectForKey:@"GrowRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbGrowPlace];
    
    WKLabel *lbLoginDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbGrowPlace) + 10, 500, 20) content:@"登录时间：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameLoginDateTitle = lbLoginDateTitle.frame;
    frameLoginDateTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameLoginDateTitle.size.width;
    [lbLoginDateTitle setFrame:frameLoginDateTitle];
    [viewContent addSubview:lbLoginDateTitle];
    
    WKLabel *lbLoginDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLoginDateTitle), VIEW_Y(lbLoginDateTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbLoginDateTitle) - 15, 20) content:[Common stringFromDateString:[paData objectForKey:@"LastLoginDate"] formatType:@"yyyy-MM-dd HH:mm"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbLoginDate];
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, VIEW_BY(lbLoginDate) + 15)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillJobIntention {
    NSDictionary *jobIntentionData = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"", nil];
    NSArray *arrayJobIntention = [Common getArrayFromXml:self.xmlData tableName:@"JobIntention"];
    if (arrayJobIntention.count > 0) {
        jobIntentionData = [arrayJobIntention objectAtIndex:0];
    }
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
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
    
    WKLabel *lbCareerTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 15, 500, 20) content:@"求职状态：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameCareerTitle = lbCareerTitle.frame;
    frameCareerTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameCareerTitle.size.width;
    [lbCareerTitle setFrame:frameCareerTitle];
    [viewContent addSubview:lbCareerTitle];
    
    WKLabel *lbCareer = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCareerTitle), VIEW_Y(lbCareerTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbCareerTitle) - 15, 20) content:[paData objectForKey:@"CareerStatus"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbCareer];
    
    WKLabel *lbRefreshDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbCareer) + 10, 500, 20) content:@"相关工作经验：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameRefreshDateTitle = lbRefreshDateTitle.frame;
    frameRefreshDateTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameRefreshDateTitle.size.width;
    [lbRefreshDateTitle setFrame:frameRefreshDateTitle];
    [viewContent addSubview:lbRefreshDateTitle];
    
    WKLabel *lbRefreshDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbRefreshDateTitle), VIEW_Y(lbRefreshDateTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbRefreshDateTitle) - 15, 20) content:[Common stringFromDateString:[cvData objectForKey:@"RefreshDate"] formatType:@"yyyy-MM-dd HH:mm"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbRefreshDate];
    
    WKLabel *lbEmployTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbRefreshDate) + 10, 500, 20) content:@"期望工作性质：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameEmployTypeTitle = lbEmployTypeTitle.frame;
    frameEmployTypeTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameEmployTypeTitle.size.width;
    [lbEmployTypeTitle setFrame:frameEmployTypeTitle];
    [viewContent addSubview:lbEmployTypeTitle];
    
    WKLabel *lbEmployType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEmployTypeTitle), VIEW_Y(lbEmployTypeTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbEmployTypeTitle) - 15, 20) content:[cvData objectForKey:@"EmployTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbEmployType];
    
    WKLabel *lbSalaryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbEmployType) + 10, 500, 20) content:@"期望月薪：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameSalaryTitle = lbSalaryTitle.frame;
    frameSalaryTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameSalaryTitle.size.width;
    [lbSalaryTitle setFrame:frameSalaryTitle];
    [viewContent addSubview:lbSalaryTitle];
    
    NSString *salary = @"";
    if ([[jobIntentionData objectForKey:@"Salary"] length] > 0) {
        salary = [NSString stringWithFormat:@"%@ %@", [jobIntentionData objectForKey:@"Salary"], ([[jobIntentionData objectForKey:@"IsNegotiable"] boolValue] ? @"可面议" : @"不可面议")];
    }
    WKLabel *lbSalary = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbSalaryTitle), VIEW_Y(lbSalaryTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbSalaryTitle) - 15, 20) content:salary size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbSalary];
    
    WKLabel *lbPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbSalary) + 10, 500, 20) content:@"期望工作地点：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect framePlaceTitle = lbPlaceTitle.frame;
    framePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - framePlaceTitle.size.width;
    [lbPlaceTitle setFrame:framePlaceTitle];
    [viewContent addSubview:lbPlaceTitle];
    
    WKLabel *lbPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbPlaceTitle), VIEW_Y(lbPlaceTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbPlaceTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobPlaceName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbPlace];
    
    WKLabel *lbJobTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, (lbPlace.text.length > 0 ? VIEW_BY(lbPlace) : VIEW_BY(lbPlaceTitle)) + 10, 500, 20) content:@"期望职位类别：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameJobTypeTitle = lbJobTypeTitle.frame;
    frameJobTypeTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameJobTypeTitle.size.width;
    [lbJobTypeTitle setFrame:frameJobTypeTitle];
    [viewContent addSubview:lbJobTypeTitle];
    
    WKLabel *lbJobType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobTypeTitle), VIEW_Y(lbJobTypeTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbJobTypeTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbJobType];
    
    WKLabel *lbIndustryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, (lbJobType.text.length > 0 ? VIEW_BY(lbJobType) : VIEW_BY(lbJobTypeTitle)) + 10, 500, 20) content:@"期望从事行业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameIndustryTitle = lbIndustryTitle.frame;
    frameIndustryTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameIndustryTitle.size.width;
    [lbIndustryTitle setFrame:frameIndustryTitle];
    [viewContent addSubview:lbIndustryTitle];
    
    WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbIndustryTitle) - 15, 20) content:[jobIntentionData objectForKey:@"IndustryName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbIndustry];
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, (lbIndustry.text.length > 0 ? VIEW_BY(lbIndustry) : VIEW_BY(lbIndustryTitle)) + 15)];
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
        
        float widthForLable = SCREEN_WIDTH - 50;
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
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, heightForEducation)];
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
        
        float widthForLable = SCREEN_WIDTH - 50;
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
        
        WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), widthForLable, 20) content:[data objectForKey:@"Industry"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbIndustry];
        
        WKLabel *lbCompanySizeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbIndustry) + 10, 500, 20) content:@"企业规模：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
        [viewContent addSubview:lbCompanySizeTitle];
        
        WKLabel *lbCompanySize = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCompanySizeTitle), VIEW_Y(lbCompanySizeTitle), widthForLable, 20) content:[data objectForKey:@"CpmpanySize"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [viewContent addSubview:lbCompanySize];
        
        WKLabel *lbDetailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbCompanySize) + 10, 500, 20) content:@"工作描述：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
        [viewContent addSubview:lbDetailTitle];
        
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbDetailTitle), VIEW_Y(lbDetailTitle), widthForLable, 20) content:[data objectForKey:@"Description"] size:DEFAULTFONTSIZE color:nil spacing:0];
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
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, heightForExperience)];
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
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, VIEW_BY(lbSpeciality) + 15)];
    [viewContent.layer setCornerRadius:5];
    
    self.heightForScroll = VIEW_BY(viewContent);
}

- (void)fillLink {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvpreitem6.png"]];
    [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"联系方式" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIView *viewContent = [[UIView alloc] init];
    [viewContent setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewContent];
    
    WKLabel *lbMobileTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 15, 500, 20) content:@"手机：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameMobileTitle = lbMobileTitle.frame;
    frameMobileTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameMobileTitle.size.width;
    [lbMobileTitle setFrame:frameMobileTitle];
    [viewContent addSubview:lbMobileTitle];
    
    WKLabel *lbMobile = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbMobileTitle), VIEW_Y(lbMobileTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbMobileTitle) - 15, 20) content:[paData objectForKey:@"Mobile"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbMobile];
    
    WKLabel *lbEmailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbMobileTitle) + 10, 500, 20) content:@"邮箱：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameEmailTitle = lbEmailTitle.frame;
    frameEmailTitle.origin.x = (IS_IPHONE_6Plus ? 110 : 100) - frameEmailTitle.size.width;
    [lbEmailTitle setFrame:frameEmailTitle];
    [viewContent addSubview:lbEmailTitle];
    
    WKLabel *lbEmail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEmailTitle), VIEW_Y(lbEmailTitle), SCREEN_WIDTH - 20 - VIEW_BX(lbEmailTitle) - 15, 20) content:[paData objectForKey:@"Email"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewContent addSubview:lbEmail];
    
    [viewContent setFrame:CGRectMake(10, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 20, VIEW_BY(lbEmail) + 15)];
    [viewContent.layer setCornerRadius:5];
    
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
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForScroll + 20)];
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
