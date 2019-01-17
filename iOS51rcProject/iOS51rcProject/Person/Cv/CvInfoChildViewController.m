//
//  CvInfoChildViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/3.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  简历页面

#import "CvInfoChildViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "UIButton+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "UIView+Toast.h"
#import "PaInfoModifyViewController.h"
#import "IntentionModifyViewController.h"
#import "EducationModifyViewController.h"
#import "SetCvTopViewController.h"// 简历置顶页面
#import "EducationViewController.h"
#import "ExperienceViewController.h"
#import "ExperienceModifyViewController.h"
#import "SpecialityModifyViewController.h"
#import "PreviewViewController.h"
#import "WKPopView.h"
#import "AttachmentModel.h"// 简历附件模型
#import "AttachMentView.h"
#import "AlertView.h"
#import "RCAlertView.h"

@interface CvInfoChildViewController ()<NetWebServiceRequestDelegate, MLImageCropDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PaInfoModifyDelegate, IntentionModifyDelegate, WKPopViewDelegate, UITextFieldDelegate>
{
    BOOL isUpdateHead;// 默认更新头像
    BOOL isTop;// 置顶中、默认不置顶NO
    BOOL isFullCV;// 是不是完整简历cvlevel，默认不是完整简历
    NSString *JobPlaceName;// 期望工作地点
}
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) GDataXMLDocument *xmlData;
@property (nonatomic, strong) UIButton *btnPhoto;
@property (nonatomic, strong) UITextField *txtMobile;
@property (nonatomic, strong) UIButton *btnCareerStatus;
@property (nonatomic, strong) WKPopView *refreshPop;
@property (nonatomic, strong) UIButton *btnAddAttachment;// 添加附件简历按钮
@property (nonatomic, strong) WKButton *btnDelete;// 删除简历按钮
@property (nonatomic , strong) UIButton *setTopBtn;// 置顶按钮
@property (nonatomic , strong) NSMutableArray *attachmentData;// 附件简历模型
@property (nonatomic , strong) UIImageView *tipSetTopView;// 提醒去简历置顶的view
@property float heightForScroll;
@end

@implementation CvInfoChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isUpdateHead = YES;
    isTop = NO;
    isFullCV = NO;
    
    if (!self.onlyOne) {
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [self.view addSubview:viewSeparate];
    }
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, (self.onlyOne ? 0 : 10), SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * (self.onlyOne ? 1 : 2))];
    [self.view addSubview:self.scrollView];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

#pragma mark - 懒加载
- (NSMutableArray *)attachmentData{
    if (!_attachmentData) {
        _attachmentData = [NSMutableArray array];
    }
    return _attachmentData;
}
- (void)getData {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", nil];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:paramDict viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}
#pragma mark - 获取置顶信息
- (void)getPaOrder{
    
    NSArray *dataArr = [Common getArrayFromXml:self.xmlData tableName:@"PaOrder"];
    if (dataArr == nil || dataArr.count == 0) {
        return;
    }
    NSDictionary *paData = [dataArr objectAtIndex:0];
    if(paData == nil){
        return;
    }
    
    isTop = YES;
    // 简历置顶置顶到期时间
    NSString *endDate = [self changeBeginFormatWithDateString:[paData objectForKey:@"endDate"]];
    UILabel *endDateLab = [UILabel new];
    endDateLab.frame = CGRectMake(0, 0, SCREEN_WIDTH, 40);
    [self.scrollView addSubview:endDateLab];
    endDateLab.textAlignment = NSTextAlignmentCenter;
    endDateLab.font = SMALLERFONT;
    NSString *endStr = [NSString stringWithFormat:@"简历置顶中      有效期至%@",endDate];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc]initWithString:endStr];
    NSRange range = [endStr rangeOfString:@"简历置顶中"];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:DEFAULTFONTSIZE] range:range];
    [attrStr addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:range];
    endDateLab.attributedText = attrStr;
    
    UIView *lineView = [UIView new];
    lineView.frame = CGRectMake(0, 35, SCREEN_WIDTH, 1);
    lineView.backgroundColor = SEPARATECOLOR;
    [self.scrollView addSubview:lineView];
}

#pragma mark - 提醒置顶简历
- (void)reminderUserToSetTop{
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    // 判断简历是不是完整的
    isFullCV = [CommonTools cvIsFull:cvData[@"cvLevel"]];
    // 浏览次数
    NSInteger cacvviewCnt = [cvData[@"cacvviewCnt"] integerValue];
    //是完整简历 && 当前简历无置顶 && 被浏览次数<5次，则展示该提示，6秒后自动隐藏
    if (isFullCV && !isTop && cacvviewCnt < 5) {
        
        // 背景对话框
        UIImageView *bgView = [UIImageView new];
        bgView.image = [UIImage imageNamed:@"bg_resume_top_tishi_num"];
        [self.scrollView addSubview:bgView];
        self.tipSetTopView = bgView;
        
        UILabel *tipLab = [UILabel new];
        [bgView addSubview:tipLab];
        tipLab.text = [NSString stringWithFormat:@"该简历近期被浏览%ld次，建议购买置顶服务",(long)cacvviewCnt];
        tipLab.font = SMALLERFONT;
        tipLab.textColor = NAVBARCOLOR;
        [tipLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
        
        bgView.sd_layout
        .bottomSpaceToView(self.setTopBtn, 5)
        .rightSpaceToView(self.scrollView , 15)
        .heightIs(30)
        .widthRatioToView(tipLab, 1.02);
        
        tipLab.sd_layout
        .bottomSpaceToView(bgView, 6)
        .centerXEqualToView(bgView)
        .topSpaceToView(bgView, 1);
        
        // GCD延时执行
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [bgView removeFromSuperview];
            [tipLab removeFromSuperview];
        });
        
    }else{
        DLog(@"不提示简历置顶");
    }
}
#pragma mark -
- (void)fillData {
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    WKLabel *lbScore = [[WKLabel alloc] initWithFrame:CGRectMake(25,isTop ? 40 :15, 50, 30) content:[NSString stringWithFormat:@"%@分", [cvData objectForKey:@"Score"]] size:25 color:([[cvData objectForKey:@"Valid"] isEqualToString:@"0"] ? NAVBARCOLOR : GREENCOLOR)];
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:lbScore.text];
    [attrString addAttribute:NSForegroundColorAttributeName value:TEXTGRAYCOLOR range:NSMakeRange(lbScore.text.length - 1, 1)];
    [attrString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(lbScore.text.length - 1, 1)];
    [lbScore setAttributedText:attrString];
    [lbScore sizeToFit];
    [self.scrollView addSubview:lbScore];
    
    WKLabel *lbScoreTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbScore), VIEW_BY(lbScore) + 5, 200, 20) content:@"完整度" size:SMALLERFONTSIZE color:TEXTGRAYCOLOR];
    [self.scrollView addSubview:lbScoreTitle];
    
    WKLabel *lbCvName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbScore) + 15, VIEW_Y(lbScore) + 3, SCREEN_WIDTH - (VIEW_BX(lbScore) + 15) - 60 - 20, 20) content:[cvData objectForKey:@"Name"] size:BIGGESTFONTSIZE color:nil];
    [self.scrollView addSubview:lbCvName];
    
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(lbCvName) + 5, VIEW_Y(lbCvName) + 2, 16, 16)];
    [btnEdit setImage:[UIImage imageNamed:@"pa_edit.png"] forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(nameEdit) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnEdit];
    
    WKLabel *lbCvOther = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCvName), VIEW_Y(lbScoreTitle), 500, 20) content:[NSString stringWithFormat:@"浏览量%@    %@更新", [cvData objectForKey:@"ViewNumber"], [Common stringFromDateString:[cvData objectForKey:@"RefreshDate"] formatType:@"yyyy-MM-dd"]] size:SMALLERFONTSIZE color:nil];
    [self.scrollView addSubview:lbCvOther];
    
    UIButton *btnPreview = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbCvName), 60, VIEW_BY(lbCvOther) - VIEW_Y(lbCvName))];
    [btnPreview setTitle:@"预览" forState:UIControlStateNormal];
    [btnPreview setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [btnPreview.titleLabel setFont:BIGGERFONT];
    [btnPreview addTarget:self action:@selector(preview) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnPreview];
    
    // 分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbCvOther) + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate];
    
    // 姓名状态的开关
    //CGRectMake(0, VIEW_BY(viewSeparate) + 10, SCREEN_WIDTH/3.1, 50)
    bool blnNameOpen = ![[cvData objectForKey:@"IsNameHidden"] boolValue];
    UIButton *btnNameOpen = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewSeparate) + 10, SCREEN_WIDTH/3.1, 50)];
    [btnNameOpen setTag:(blnNameOpen ? 1 : 0)];
    [btnNameOpen addTarget:self action:@selector(nameOpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnNameOpen];
    
    UIImageView *imgNameOpen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(btnNameOpen), 25)];
    [imgNameOpen setImage:[UIImage imageNamed:(blnNameOpen ? @"pa_open1.png" : @"pa_open2.png")]];
    [imgNameOpen setContentMode:UIViewContentModeScaleAspectFit];
    [btnNameOpen addSubview:imgNameOpen];
    
    WKLabel *lbNameOpen = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgNameOpen) + 5, VIEW_W(btnNameOpen), 20) content:@"姓名状态" size:DEFAULTFONTSIZE color:nil];
    [lbNameOpen setTextAlignment:NSTextAlignmentCenter];
    
    [btnNameOpen addSubview:lbNameOpen];
    
    UIView *viewSeparate1 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W(btnNameOpen) - 1, 0, 1, VIEW_H(btnNameOpen))];
    [viewSeparate1 setBackgroundColor:SEPARATECOLOR];
    [btnNameOpen addSubview:viewSeparate1];
    
    // 简历状态的开关
    bool blnCvOpen = ![[cvData objectForKey:@"IscvHidden"] boolValue];
    UIButton *btnCvOpen = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnNameOpen), VIEW_Y(btnNameOpen), VIEW_W(btnNameOpen), VIEW_H(btnNameOpen))];
    [btnCvOpen setTag:(blnCvOpen ? 1 : 0)];
    [btnCvOpen addTarget:self action:@selector(cvOpenClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnCvOpen];
    
    UIImageView *imgCvOpen = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(btnCvOpen), 25)];
    [imgCvOpen setImage:[UIImage imageNamed:(blnCvOpen ? @"pa_open1.png" : @"pa_open2.png")]];
    [imgCvOpen setContentMode:UIViewContentModeScaleAspectFit];
    [btnCvOpen addSubview:imgCvOpen];
    
    WKLabel *lbCvOpen = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgCvOpen) + 5, VIEW_W(btnCvOpen), 20) content:@"简历状态" size:DEFAULTFONTSIZE color:nil];
    [lbCvOpen setTextAlignment:NSTextAlignmentCenter];
    [btnCvOpen addSubview:lbCvOpen];
    
    UIView *viewSeparate2 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W(btnCvOpen) - 1, 0, 1, VIEW_H(btnCvOpen))];
    [viewSeparate2 setBackgroundColor:SEPARATECOLOR];
    [btnCvOpen addSubview:viewSeparate2];
    
    // 更新按钮
    //CGRectMake(VIEW_BX(btnCvOpen), VIEW_Y(btnNameOpen), SCREEN_WIDTH/3/2, VIEW_H(btnNameOpen)
    UIButton *btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnCvOpen), VIEW_Y(btnNameOpen), SCREEN_WIDTH/3/2, VIEW_H(btnNameOpen))];
    [btnRefresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnRefresh];
    
    UIImageView *imgRefresh = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(btnRefresh), 25)];
    [imgRefresh setImage:[UIImage imageNamed:@"pa_refresh.png"]];
    [imgRefresh setContentMode:UIViewContentModeScaleAspectFit];
    [btnRefresh addSubview:imgRefresh];
    
    WKLabel *lbRefresh = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgRefresh) + 5, VIEW_W(btnRefresh), 20) content:@"更新" size:DEFAULTFONTSIZE color:nil];
    [lbRefresh setTextAlignment:NSTextAlignmentCenter];
    [btnRefresh addSubview:lbRefresh];
    
    UIView *viewSeparate3 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W(btnRefresh) - 1, 0, 1, VIEW_H(btnRefresh))];
    [viewSeparate3 setBackgroundColor:SEPARATECOLOR];
    [btnRefresh addSubview:viewSeparate3];
    
    // 置顶按钮
    UIButton *setTopBtn = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnRefresh), VIEW_Y(btnRefresh), SCREEN_WIDTH/3/2, VIEW_H(btnRefresh))];
    [setTopBtn addTarget:self action:@selector(setCvToTop) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:setTopBtn];
    self.setTopBtn = setTopBtn;

    UIImageView *setTopImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(setTopBtn), 25)];
    [setTopImg setImage:[UIImage imageNamed:@"pa_SetTop"]];
    [setTopImg setContentMode:UIViewContentModeScaleAspectFit];
    [setTopBtn addSubview:setTopImg];

    WKLabel *setTopLab = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(setTopImg) + 5, VIEW_W(setTopBtn), 20) content:@"置顶" size:DEFAULTFONTSIZE color:nil];
    [setTopLab setTextAlignment:NSTextAlignmentCenter];
    [setTopBtn addSubview:setTopLab];
    
    UIView *viewSeparate4 = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewSeparate), VIEW_BY(btnNameOpen) + 10, VIEW_W(viewSeparate), 1)];
    [viewSeparate4 setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate4];
    
    self.heightForScroll = VIEW_BY(viewSeparate4);
}

#pragma mark - 基本信息UI
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
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem1.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"基本信息" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbTitle), 60, 20)];
    [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    [btnEdit setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [btnEdit addTarget:self action:@selector(paInfoModify) forControlEvents:UIControlEventTouchUpInside];
    [btnEdit.titleLabel setFont:BIGGERFONT];
    [self.scrollView addSubview:btnEdit];
    
    WKLabel *lbNameTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbTitle) + 20, 500, 20) content:@"姓  名：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameNameTitle = lbNameTitle.frame;
    frameNameTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameNameTitle.size.width;
    [lbNameTitle setFrame:frameNameTitle];
    [self.scrollView addSubview:lbNameTitle];
    
    WKLabel *lbName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbNameTitle), VIEW_Y(lbNameTitle), SCREEN_WIDTH - VIEW_BX(lbNameTitle) - 15, 20) content:[paData objectForKey:@"Name"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbName];
    
    WKLabel *lbGenderTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbNameTitle) + 10, 500, 20) content:@"性  别：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameGenderTitle = lbGenderTitle.frame;
    frameGenderTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameGenderTitle.size.width;
    [lbGenderTitle setFrame:frameGenderTitle];
    [self.scrollView addSubview:lbGenderTitle];
    
    WKLabel *lbGender = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbGenderTitle), VIEW_Y(lbGenderTitle), SCREEN_WIDTH - VIEW_BX(lbGenderTitle) - 15, 20) content:gender size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbGender];
    
    WKLabel *lbBirthTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbGenderTitle) + 10, 500, 20) content:@"出生年月：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameBirthTitle = lbBirthTitle.frame;
    frameBirthTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameBirthTitle.size.width;
    [lbBirthTitle setFrame:frameBirthTitle];
    [self.scrollView addSubview:lbBirthTitle];
    
    WKLabel *lbBirth = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbBirthTitle), VIEW_Y(lbBirthTitle), SCREEN_WIDTH - VIEW_BX(lbBirthTitle) - 15, 20) content:birth size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbBirth];
    
    WKLabel *lbLivePlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbBirthTitle) + 10, 500, 20) content:@"现居住地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameLivePlaceTitle = lbLivePlaceTitle.frame;
    frameLivePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameLivePlaceTitle.size.width;
    [lbLivePlaceTitle setFrame:frameLivePlaceTitle];
    [self.scrollView addSubview:lbLivePlaceTitle];
    
    WKLabel *lbLivePlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLivePlaceTitle), VIEW_Y(lbLivePlaceTitle), SCREEN_WIDTH - VIEW_BX(lbLivePlaceTitle) - 15, 20) content:[paData objectForKey:@"LiveRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbLivePlace];
    
    WKLabel *lbAccountPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbLivePlaceTitle) + 10, 500, 20) content:@"户口所在地：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameAccountPlaceTitle = lbAccountPlaceTitle.frame;
    frameAccountPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameAccountPlaceTitle.size.width;
    [lbAccountPlaceTitle setFrame:frameAccountPlaceTitle];
    [self.scrollView addSubview:lbAccountPlaceTitle];
    
    WKLabel *lbAccountPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbAccountPlaceTitle), VIEW_Y(lbAccountPlaceTitle), SCREEN_WIDTH - VIEW_BX(lbAccountPlaceTitle) - 15, 20) content:[paData objectForKey:@"AccountRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbAccountPlace];
    
    WKLabel *lbGrowPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbAccountPlaceTitle) + 10, 500, 20) content:@"我成长在：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameGrowPlaceTitle = lbGrowPlaceTitle.frame;
    frameGrowPlaceTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameGrowPlaceTitle.size.width;
    [lbGrowPlaceTitle setFrame:frameGrowPlaceTitle];
    [self.scrollView addSubview:lbGrowPlaceTitle];
    
    WKLabel *lbGrowPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbGrowPlaceTitle), VIEW_Y(lbGrowPlaceTitle), SCREEN_WIDTH - VIEW_BX(lbGrowPlaceTitle) - 15, 20) content:[paData objectForKey:@"GrowRegion"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbGrowPlace];
    
    WKLabel *lbMobileTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbGrowPlaceTitle) + 10, 500, 20) content:@"手机号码：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameMobileTitle = lbMobileTitle.frame;
    frameMobileTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameMobileTitle.size.width;
    [lbMobileTitle setFrame:frameMobileTitle];
    [self.scrollView addSubview:lbMobileTitle];
    
    WKLabel *lbMobile = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbMobileTitle), VIEW_Y(lbMobileTitle), SCREEN_WIDTH - VIEW_BX(lbMobileTitle) - 15, 20) content:[paData objectForKey:@"Mobile"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbMobile];
    
    WKLabel *lbEmailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbMobileTitle) + 10, 500, 20) content:@"电子邮箱：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameEmailTitle = lbEmailTitle.frame;
    frameEmailTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameEmailTitle.size.width;
    [lbEmailTitle setFrame:frameEmailTitle];
    [self.scrollView addSubview:lbEmailTitle];
    
    WKLabel *lbEmail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEmailTitle), VIEW_Y(lbEmailTitle), SCREEN_WIDTH - VIEW_BX(lbEmailTitle) - 15, 20) content:[paData objectForKey:@"Email"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbEmail];
    
    self.btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, VIEW_Y(lbName), 64, 80)];
    [self.btnPhoto setImage:[UIImage imageNamed:@"pa_photo.png"] forState:UIControlStateNormal];
    [self.btnPhoto sd_setImageWithURL:[paData objectForKey:@"PhotoUrl"] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"pa_photo.png"]];
    [self.btnPhoto addTarget:self action:@selector(photoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.btnPhoto];
    
    UIImageView *imgCamera = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(self.btnPhoto) - 10, VIEW_BY(self.btnPhoto) - 10, 18, 18)];
    [imgCamera setImage:[UIImage imageNamed:@"pa_camera.png"]];
    [self.scrollView addSubview:imgCamera];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbEmail) + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate];
    
    self.heightForScroll = VIEW_BY(viewSeparate);
}

#pragma mark - 求职意向UI
- (void)fillJobIntention {
    NSDictionary *jobIntentionData = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"", nil];
    NSArray *arrayJobIntention = [Common getArrayFromXml:self.xmlData tableName:@"JobIntention"];
    if (arrayJobIntention.count > 0) {
        jobIntentionData = [arrayJobIntention objectAtIndex:0];
    }
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem2.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"求职意向" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbTitle), 60, 20)];
    [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
    [btnEdit setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [btnEdit.titleLabel setFont:BIGGERFONT];
    [btnEdit addTarget:self action:@selector(jobIntentionModify) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnEdit];
    
    WKLabel *lbCareerTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbTitle) + 20, 500, 20) content:@"求职状态：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameCareerTitle = lbCareerTitle.frame;
    frameCareerTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameCareerTitle.size.width;
    [lbCareerTitle setFrame:frameCareerTitle];
    [self.scrollView addSubview:lbCareerTitle];
    
    WKLabel *lbCareer = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCareerTitle), VIEW_Y(lbCareerTitle), SCREEN_WIDTH - VIEW_BX(lbCareerTitle) - 15, 20) content:[paData objectForKey:@"CareerStatus"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbCareer];
    
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
    WKLabel *lbWorkYearsTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbCareerTitle) + 10, 500, 20) content:@"相关工作经验：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameWorkYearsTitle = lbWorkYearsTitle.frame;
    frameWorkYearsTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameWorkYearsTitle.size.width;
    [lbWorkYearsTitle setFrame:frameWorkYearsTitle];
    [self.scrollView addSubview:lbWorkYearsTitle];
    
    WKLabel *lbWorkYears = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbWorkYearsTitle), VIEW_Y(lbWorkYearsTitle), SCREEN_WIDTH - VIEW_BX(lbWorkYearsTitle) - 15, 20) content:workYears size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbWorkYears];
    
    WKLabel *lbEmployTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbWorkYearsTitle) + 10, 500, 20) content:@"期望工作性质：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameEmployTypeTitle = lbEmployTypeTitle.frame;
    frameEmployTypeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameEmployTypeTitle.size.width;
    [lbEmployTypeTitle setFrame:frameEmployTypeTitle];
    [self.scrollView addSubview:lbEmployTypeTitle];
    
    WKLabel *lbEmployType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEmployTypeTitle), VIEW_Y(lbEmployTypeTitle), SCREEN_WIDTH - VIEW_BX(lbEmployTypeTitle) - 15, 20) content:[cvData objectForKey:@"EmployTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbEmployType];
    
    WKLabel *lbSalaryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbEmployTypeTitle) + 10, 500, 20) content:@"期望月薪：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameSalaryTitle = lbSalaryTitle.frame;
    frameSalaryTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameSalaryTitle.size.width;
    [lbSalaryTitle setFrame:frameSalaryTitle];
    [self.scrollView addSubview:lbSalaryTitle];
    
    NSString *salary = @"";
    if ([[jobIntentionData objectForKey:@"Salary"] length] > 0) {
        salary = [NSString stringWithFormat:@"%@ %@", [jobIntentionData objectForKey:@"Salary"], ([[jobIntentionData objectForKey:@"IsNegotiable"] boolValue] ? @"可面议" : @"不可面议")];
    }
    WKLabel *lbSalary = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbSalaryTitle), VIEW_Y(lbSalaryTitle), SCREEN_WIDTH - VIEW_BX(lbSalaryTitle) - 15, 20) content:salary size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbSalary];
    
    WKLabel *lbPlaceTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbSalaryTitle) + 10, 500, 20) content:@"期望工作地点：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect framePlaceTitle = lbPlaceTitle.frame;
    framePlaceTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - framePlaceTitle.size.width;
    [lbPlaceTitle setFrame:framePlaceTitle];
    [self.scrollView addSubview:lbPlaceTitle];
    
    WKLabel *lbPlace = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbPlaceTitle), VIEW_Y(lbPlaceTitle), SCREEN_WIDTH - VIEW_BX(lbPlaceTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobPlaceName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbPlace];
    
    JobPlaceName = [[NSString alloc]initWithString:[jobIntentionData objectForKey:@"JobPlaceName"] ?[jobIntentionData objectForKey:@"JobPlaceName"]:@""];
    
    WKLabel *lbJobTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, (lbPlace.text.length > 0 ? VIEW_BY(lbPlace) : VIEW_BY(lbPlaceTitle)) + 10, 500, 20) content:@"期望职位类别：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameJobTypeTitle = lbJobTypeTitle.frame;
    frameJobTypeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameJobTypeTitle.size.width;
    [lbJobTypeTitle setFrame:frameJobTypeTitle];
    [self.scrollView addSubview:lbJobTypeTitle];
    
    WKLabel *lbJobType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobTypeTitle), VIEW_Y(lbJobTypeTitle), SCREEN_WIDTH - VIEW_BX(lbJobTypeTitle) - 15, 20) content:[jobIntentionData objectForKey:@"JobTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbJobType];
    
    WKLabel *lbIndustryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, (lbJobType.text.length > 0 ? VIEW_BY(lbJobType) : VIEW_BY(lbJobTypeTitle)) + 10, 500, 20) content:@"期望从事行业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    CGRect frameIndustryTitle = lbIndustryTitle.frame;
    frameIndustryTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameIndustryTitle.size.width;
    [lbIndustryTitle setFrame:frameIndustryTitle];
    [self.scrollView addSubview:lbIndustryTitle];
    
    WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), SCREEN_WIDTH - VIEW_BX(lbIndustryTitle) - 15, 20) content:[jobIntentionData objectForKey:@"IndustryName"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [self.scrollView addSubview:lbIndustry];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, (lbIndustry.text.length > 0 ? VIEW_BY(lbIndustry) : VIEW_BY(lbIndustryTitle)) + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate];
    
    self.heightForScroll = VIEW_BY(viewSeparate);
}

#pragma mark - 教育背景UI
- (void)fillEducation {
    NSArray *arrayEducation = [Common getArrayFromXml:self.xmlData tableName:@"Education"];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem3.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"教育背景" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    if (arrayEducation.count > 0) {
        UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbTitle), 60, 20)];
        [btnEdit addTarget:self action:@selector(educationModify) forControlEvents:UIControlEventTouchUpInside];
        [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnEdit.titleLabel setFont:BIGGERFONT];
        [self.scrollView addSubview:btnEdit];
        
        self.heightForScroll = VIEW_BY(lbTitle);
        for (NSDictionary *data in arrayEducation) {
            WKLabel *lbCollegeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, self.heightForScroll + 20, 500, 20) content:@"学校名称：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameCollegeTitle = lbCollegeTitle.frame;
            frameCollegeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameCollegeTitle.size.width;
            [lbCollegeTitle setFrame:frameCollegeTitle];
            [self.scrollView addSubview:lbCollegeTitle];
            
            WKLabel *lbCollege = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCollegeTitle), VIEW_Y(lbCollegeTitle), SCREEN_WIDTH - VIEW_BX(lbCollegeTitle) - 15, 20) content:[data objectForKey:@"GraduateCollage"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbCollege];
            
            NSString *graduation = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"Graduation"] substringToIndex:4], [[data objectForKey:@"Graduation"] substringFromIndex:4]];
            WKLabel *lbGraduationTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbCollege) + 10, 500, 20) content:@"毕业时间：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameGraduationTitle = lbGraduationTitle.frame;
            frameGraduationTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameGraduationTitle.size.width;
            [lbGraduationTitle setFrame:frameGraduationTitle];
            [self.scrollView addSubview:lbGraduationTitle];
            
            WKLabel *lbGraduation = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbGraduationTitle), VIEW_Y(lbGraduationTitle), SCREEN_WIDTH - VIEW_BX(lbGraduationTitle) - 15, 20) content:graduation size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbGraduation];
            
            WKLabel *lbDegreeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbGraduation) + 10, 500, 20) content:@"学历：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameDegreeTitle = lbDegreeTitle.frame;
            frameDegreeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameDegreeTitle.size.width;
            [lbDegreeTitle setFrame:frameDegreeTitle];
            [self.scrollView addSubview:lbDegreeTitle];
            
            WKLabel *lbDegree = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbDegreeTitle), VIEW_Y(lbDegreeTitle), SCREEN_WIDTH - VIEW_BX(lbDegreeTitle) - 15, 20) content:[data objectForKey:@"DegreeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbDegree];
            
            WKLabel *lbEducationTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbDegree) + 10, 500, 20) content:@"学历类型：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameEducationTypeTitle = lbEducationTypeTitle.frame;
            frameEducationTypeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameEducationTypeTitle.size.width;
            [lbEducationTypeTitle setFrame:frameEducationTypeTitle];
            [self.scrollView addSubview:lbEducationTypeTitle];
            
            WKLabel *lbEducationType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbEducationTypeTitle), VIEW_Y(lbEducationTypeTitle), SCREEN_WIDTH - VIEW_BX(lbEducationTypeTitle) - 15, 20) content:[data objectForKey:@"EduTypeName"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbEducationType];
            
            WKLabel *lbMajorNameTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbEducationType) + 10, 500, 20) content:@"专业名称：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameMajorNameTitle = lbMajorNameTitle.frame;
            frameMajorNameTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameMajorNameTitle.size.width;
            [lbMajorNameTitle setFrame:frameMajorNameTitle];
            [self.scrollView addSubview:lbMajorNameTitle];
            
            WKLabel *lbMajorName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbMajorNameTitle), VIEW_Y(lbMajorNameTitle), SCREEN_WIDTH - VIEW_BX(lbMajorNameTitle) - 15, 20) content:[data objectForKey:@"MajorName"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbMajorName];
            
            WKLabel *lbMajorTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbMajorName) + 10, 500, 20) content:@"专业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameMajorTitle = lbMajorTitle.frame;
            frameMajorTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameMajorTitle.size.width;
            [lbMajorTitle setFrame:frameMajorTitle];
            [self.scrollView addSubview:lbMajorTitle];
            
            WKLabel *lbMajor = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbMajorTitle), VIEW_Y(lbMajorTitle), SCREEN_WIDTH - VIEW_BX(lbMajorTitle) - 15, 20) content:[data objectForKey:@"Major"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbMajor];
            
            WKLabel *lbDetailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbMajor) + 10, 500, 20) content:@"学习经历：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameDetailTitle = lbDetailTitle.frame;
            frameDetailTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameDetailTitle.size.width;
            [lbDetailTitle setFrame:frameDetailTitle];
            [self.scrollView addSubview:lbDetailTitle];
            
            WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbDetailTitle), VIEW_Y(lbDetailTitle), SCREEN_WIDTH - VIEW_BX(lbDetailTitle) - 15, 20) content:[data objectForKey:@"Details"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbDetail];
            
            UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbCollegeTitle) - 20, VIEW_Y(lbCollegeTitle) + 3, 10, 10)];
            [viewTips setBackgroundColor:UIColorWithRGBA(171, 171, 171, 1)];
            viewTips.layer.cornerRadius = 5;
            viewTips.layer.borderColor = [UIColorWithRGBA(215, 215, 215, 1) CGColor];
            viewTips.layer.borderWidth = 2;
            [self.scrollView addSubview:viewTips];
            
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewTips) + 4.5, VIEW_BY(viewTips), 1, VIEW_BY(lbDetailTitle) - VIEW_BY(viewTips))];
            [viewLine setBackgroundColor:SEPARATECOLOR];
            [self.scrollView addSubview:viewLine];
            
            self.heightForScroll = (lbDetail.text.length > 0 ? VIEW_BY(lbDetail) : VIEW_BY(lbDetailTitle));
        }
    }
    else {
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTitle) + 10, SCREEN_WIDTH, 60)];
        [btnAdd setTitle:@"添加教育背景" forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"pa_add.png"] forState:UIControlStateNormal];
        [btnAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnAdd setImageEdgeInsets:UIEdgeInsetsMake(20, 15, 20, 0)];
        [btnAdd setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnAdd.titleLabel setFont:BIGGERFONT];
        [btnAdd addTarget:self action:@selector(addEducation) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnAdd];
        
        self.heightForScroll = VIEW_BY(btnAdd);
    }
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate];
    
    self.heightForScroll = VIEW_BY(viewSeparate);
}

#pragma mark - 工作经历UI
- (void)fillExperience {
    NSArray *arrayExperience = [Common getArrayFromXml:self.xmlData tableName:@"Experience"];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem4.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"工作经历" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    if (arrayExperience.count > 0) {
        UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbTitle), 60, 20)];
        [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnEdit.titleLabel setFont:BIGGERFONT];
        [btnEdit addTarget:self action:@selector(experienceModify) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnEdit];
        
        self.heightForScroll = VIEW_BY(lbTitle);
        for (NSDictionary *data in arrayExperience) {
            WKLabel *lbCompanyNameTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, self.heightForScroll + 20, 500, 20) content:@"企业名称：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameCompanyNameTitle = lbCompanyNameTitle.frame;
            frameCompanyNameTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameCompanyNameTitle.size.width;
            [lbCompanyNameTitle setFrame:frameCompanyNameTitle];
            [self.scrollView addSubview:lbCompanyNameTitle];
            
            WKLabel *lbCompanyName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCompanyNameTitle), VIEW_Y(lbCompanyNameTitle), SCREEN_WIDTH - VIEW_BX(lbCompanyNameTitle) - 15, 20) content:[data objectForKey:@"CompanyName"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbCompanyName];
            
            WKLabel *lbIndustryTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbCompanyName) + 10, 500, 20) content:@"所属行业：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameIndustryTitle = lbIndustryTitle.frame;
            frameIndustryTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameIndustryTitle.size.width;
            [lbIndustryTitle setFrame:frameIndustryTitle];
            [self.scrollView addSubview:lbIndustryTitle];
            
            WKLabel *lbIndustry = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbIndustryTitle), VIEW_Y(lbIndustryTitle), SCREEN_WIDTH - VIEW_BX(lbIndustryTitle) - 15, 20) content:[data objectForKey:@"Industry"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbIndustry];
            
            WKLabel *lbCompanySizeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbIndustry) + 10, 500, 20) content:@"企业规模：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameCompanySizeTitle = lbCompanySizeTitle.frame;
            frameCompanySizeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameCompanySizeTitle.size.width;
            [lbCompanySizeTitle setFrame:frameCompanySizeTitle];
            [self.scrollView addSubview:lbCompanySizeTitle];
            
            WKLabel *lbCompanySize = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbCompanySizeTitle), VIEW_Y(lbCompanySizeTitle), SCREEN_WIDTH - VIEW_BX(lbCompanySizeTitle) - 15, 20) content:[data objectForKey:@"CpmpanySize"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbCompanySize];
            
            WKLabel *lbJobNameTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbCompanySize) + 10, 500, 20) content:@"职位名称：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameJobNameTitle = lbJobNameTitle.frame;
            frameJobNameTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameJobNameTitle.size.width;
            [lbJobNameTitle setFrame:frameJobNameTitle];
            [self.scrollView addSubview:lbJobNameTitle];
            
            WKLabel *lbJobName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobNameTitle), VIEW_Y(lbJobNameTitle), SCREEN_WIDTH - VIEW_BX(lbJobNameTitle) - 15, 20) content:[data objectForKey:@"JobName"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbJobName];
            
            WKLabel *lbJobTypeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbJobName) + 10, 500, 20) content:@"职位类别：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameJobTypeTitle = lbJobTypeTitle.frame;
            frameJobTypeTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameJobTypeTitle.size.width;
            [lbJobTypeTitle setFrame:frameJobTypeTitle];
            [self.scrollView addSubview:lbJobTypeTitle];
            
            WKLabel *lbJobType = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobTypeTitle), VIEW_Y(lbJobTypeTitle), SCREEN_WIDTH - VIEW_BX(lbJobTypeTitle) - 15, 20) content:[data objectForKey:@"JobType"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbJobType];
            
            WKLabel *lbWorkDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbJobType) + 10, 500, 20) content:@"工作时间：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameWorkDateTitle = lbWorkDateTitle.frame;
            frameWorkDateTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameWorkDateTitle.size.width;
            [lbWorkDateTitle setFrame:frameWorkDateTitle];
            [self.scrollView addSubview:lbWorkDateTitle];
            
            NSString *beginDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"BeginDate"] substringToIndex:4], [[data objectForKey:@"BeginDate"] substringFromIndex:4]];
            NSString *endDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"EndDate"] substringToIndex:4], [[data objectForKey:@"EndDate"] substringFromIndex:4]];
            if ([[data objectForKey:@"EndDate"] isEqualToString:@"999999"]) {
                endDate = @"至今";
            }
            WKLabel *lbWorkDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbWorkDateTitle), VIEW_Y(lbWorkDateTitle), SCREEN_WIDTH - VIEW_BX(lbWorkDateTitle) - 15, 20) content:[NSString stringWithFormat:@"%@ 至 %@", beginDate, endDate] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbWorkDate];
            
            WKLabel *lbLowerNumberTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbWorkDate) + 10, 500, 20) content:@"下属人数：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameLowerNumberTitle = lbLowerNumberTitle.frame;
            frameLowerNumberTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameLowerNumberTitle.size.width;
            [lbLowerNumberTitle setFrame:frameLowerNumberTitle];
            [self.scrollView addSubview:lbLowerNumberTitle];
            
            WKLabel *lbLowerNumber = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLowerNumberTitle), VIEW_Y(lbLowerNumberTitle), SCREEN_WIDTH - VIEW_BX(lbLowerNumberTitle) - 15, 20) content:[data objectForKey:@"LowerNumber"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbLowerNumber];
            
            WKLabel *lbDetailTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(lbLowerNumber) + 10, 500, 20) content:@"工作描述：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
            CGRect frameDetailTitle = lbDetailTitle.frame;
            frameDetailTitle.origin.x = (IS_IPHONE_6Plus ? 120 : 110) - frameDetailTitle.size.width;
            [lbDetailTitle setFrame:frameDetailTitle];
            [self.scrollView addSubview:lbDetailTitle];
            
            WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbDetailTitle), VIEW_Y(lbDetailTitle), SCREEN_WIDTH - VIEW_BX(lbDetailTitle) - 15, 20) content:[data objectForKey:@"Description"] size:DEFAULTFONTSIZE color:nil spacing:0];
            [self.scrollView addSubview:lbDetail];
            
            UIView *viewTips = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(lbCompanyNameTitle) - 20, VIEW_Y(lbCompanyNameTitle) + 3, 10, 10)];
            [viewTips setBackgroundColor:UIColorWithRGBA(171, 171, 171, 1)];
            viewTips.layer.cornerRadius = 5;
            viewTips.layer.borderColor = [UIColorWithRGBA(215, 215, 215, 1) CGColor];
            viewTips.layer.borderWidth = 2;
            [self.scrollView addSubview:viewTips];
            
            UIView *viewLine = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(viewTips) + 4.5, VIEW_BY(viewTips), 1, VIEW_BY(lbDetail) - VIEW_BY(viewTips))];
            [viewLine setBackgroundColor:SEPARATECOLOR];
            [self.scrollView addSubview:viewLine];
            
            self.heightForScroll = (lbDetail.text.length > 0 ? VIEW_BY(lbDetail) : VIEW_BY(lbDetailTitle));
        }
    }
    else {
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTitle) + 10, SCREEN_WIDTH, 60)];
        [btnAdd setTitle:@"添加工作经历" forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"pa_add.png"] forState:UIControlStateNormal];
        [btnAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnAdd setImageEdgeInsets:UIEdgeInsetsMake(20, 15, 20, 0)];
        [btnAdd setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnAdd addTarget:self action:@selector(addExperience) forControlEvents:UIControlEventTouchUpInside];
        [btnAdd.titleLabel setFont:BIGGERFONT];
        [self.scrollView addSubview:btnAdd];
        
        self.heightForScroll = VIEW_BY(btnAdd);
    }
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.scrollView addSubview:viewSeparate];
    
    self.heightForScroll = VIEW_BY(viewSeparate);
}

#pragma mark - 工作能力UI
- (void)fillSpeciality {
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem5.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"工作能力" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    if ([[cvData objectForKey:@"Speciality"] length] > 0) {
        UIButton *btnEdit = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbTitle), 60, 20)];
        [btnEdit setTitle:@"编辑" forState:UIControlStateNormal];
        [btnEdit setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnEdit.titleLabel setFont:BIGGERFONT];
        [btnEdit addTarget:self action:@selector(specialityModify) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnEdit];
        
        WKLabel *lbSpeciality = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(30, VIEW_BY(lbTitle) + 20, SCREEN_WIDTH - 60, 20) content:[cvData objectForKey:@"Speciality"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [self.scrollView addSubview:lbSpeciality];
        
        self.heightForScroll = VIEW_BY(lbSpeciality);
    }
    else {
        UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTitle) + 10, SCREEN_WIDTH, 60)];
        [btnAdd setTitle:@"添加工作能力" forState:UIControlStateNormal];
        [btnAdd setImage:[UIImage imageNamed:@"pa_add.png"] forState:UIControlStateNormal];
        [btnAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnAdd setImageEdgeInsets:UIEdgeInsetsMake(20, 15, 20, 0)];
        [btnAdd setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnAdd.titleLabel setFont:BIGGERFONT];
        [btnAdd addTarget:self action:@selector(specialityModify) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:btnAdd];
        
        self.heightForScroll = VIEW_BY(btnAdd);
    }
}
#pragma mark - 附件简历UI
- (void)setupAttachment{
    UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(15, self.heightForScroll + 15, 20, 20)];
    [imgTitle setImage:[UIImage imageNamed:@"pa_cvitem6.png"]];
    [self.scrollView addSubview:imgTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, VIEW_Y(imgTitle), SCREEN_WIDTH, 20) content:@"附件简历" size:BIGGERFONTSIZE color:nil];
    [self.scrollView addSubview:lbTitle];
    
    UIButton *btnAddAttachment = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTitle) + 10, SCREEN_WIDTH, 60)];
    [btnAddAttachment setTitle:@"添加附件简历" forState:UIControlStateNormal];
    [btnAddAttachment setImage:[UIImage imageNamed:@"pa_add.png"] forState:UIControlStateNormal];
    [btnAddAttachment.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnAddAttachment setImageEdgeInsets:UIEdgeInsetsMake(20, 15, 20, 0)];
    [btnAddAttachment setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    [btnAddAttachment.titleLabel setFont:BIGGERFONT];
    [btnAddAttachment addTarget:self action:@selector(addAttachment) forControlEvents:UIControlEventTouchUpInside];
    self.btnAddAttachment = btnAddAttachment;
    [self.scrollView addSubview:self.btnAddAttachment];
    
    self.heightForScroll = VIEW_BY(self.btnAddAttachment);
}

#pragma mark - 点击头像
- (void)photoClick {
    UIAlertController *alerPhoto = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isUpdateHead = YES;
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isUpdateHead = YES;
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alerPhoto animated:YES completion:nil];
}

#pragma mark - 删除按钮
- (void)setupDeleteBtn{
    [self.btnDelete removeFromSuperview];
    WKButton *btnDelete = [[WKButton alloc] initWithFrame:CGRectMake(30, self.heightForScroll + 20, SCREEN_WIDTH - 60, 40)];
    [btnDelete setBackgroundColor:UIColorWithRGBA(182, 182, 182, 1)];
    [btnDelete setTitle:@"删除简历" forState:UIControlStateNormal];
    [btnDelete.titleLabel setFont:BIGGERFONT];
    [btnDelete addTarget:self action:@selector(delete) forControlEvents:UIControlEventTouchUpInside];
    self.btnDelete = btnDelete;
    [self.scrollView addSubview:self.btnDelete];
    
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(btnDelete) + 20)];
}

#pragma mark - 打开相册/相机
- (void)getPhoto:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count]>0){
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
    else{
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备不支持拍摄功能" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
}

#pragma mark - 选取图片
#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage]) {
        UIImage *imgSelect = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = imgSelect;
        imgCrop.ratioOfWidthAndHeight = 3.0f/4.0f;
        [imgCrop showWithAnimation:true];
    }
    else if([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie]) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统只支持图片格式" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -
- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage {
    [self.btnPhoto setImage:cropImage forState:UIControlStateNormal];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0.1);
    
    if(isUpdateHead){
        [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    }else{
        [self addAttachment:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
    }
    
}

#pragma mark - 上传头像的网络请求
- (void)uploadPhoto:(NSString *)dataPhoto {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UploadPhoto" Params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 上传附件的网络请求
- (void)addAttachment:(NSString *)dataPhoto {
    
    [SVProgressHUD show];
    NSDictionary *paramDic = [NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId ,@"cvMainID",nil];
    [AFNManager requestWithMethod:POST ParamDict:paramDic url:URL_UPLOADCVANNEX tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        BOOL result = [(NSString *)dataDict isEqualToString:@"1"];
        if (!result) {
            [RCToast showMessage:@"上传失败，请稍后重试"];
        }else{
            [self getCvAttachmentList];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 删除附件简历
- (void)deleteCVAttachment:(AttachmentModel *)attach{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"attachmentID":attach.Id};
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_DELETECVATTACHMENT tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        BOOL result = [(NSString *)dataDict isEqualToString:@"1"];
        if (result) {
            [self getCvAttachmentList];
        }else{
            [RCToast showMessage:@"附件简历删除失败，请稍后再试"];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:@"附件简历删除失败，请稍后再试"];
    }];
}

#pragma mark - 姓名状态点击事件
- (void)nameOpenClick:(UIButton *)button {
    [self setOpen:@"" nameHidden:(button.tag == 0 ? @"0" : @"1")];
    UIImageView *imgOpen;
    for (UIView *view in button.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgOpen = (UIImageView *)view;
        }
    }
    if (button.tag == 0) {
        [imgOpen setImage:[UIImage imageNamed:@"pa_open1.png"]];
        button.tag = 1;
    }
    else {
        [imgOpen setImage:[UIImage imageNamed:@"pa_open2.png"]];
        button.tag = 0;
    }
}

#pragma mark - 简历状态点击事件
- (void)cvOpenClick:(UIButton *)switchButton {
    
    if(isTop && switchButton.tag == 1){
        RCAlertView *alert = [[RCAlertView alloc]initWithTitle:@"提示" content:@"隐藏简历后，您的置顶服务会继续倒计时，您确定隐藏么？" leftBtn:@"确定" rightBtn:@"取消"];
        alert.clickBlock = ^(UIButton *button) {
            if ([button.titleLabel.text isEqualToString:@"确定"]) {
                [self changeCvOpenStatus:switchButton];
            }
        };
        [alert show];
    }else{
        [self changeCvOpenStatus:switchButton];
    }
}
// 改变隐藏/显示简历按钮的显示状态
- (void)changeCvOpenStatus:(UIButton *)button{
    [self setOpen:(button.tag == 0 ? @"0" : @"1") nameHidden:@""];
    UIImageView *imgOpen;
    for (UIView *view in button.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgOpen = (UIImageView *)view;
        }
    }
    if (button.tag == 0) {
        [imgOpen setImage:[UIImage imageNamed:@"pa_open1.png"]];
        button.tag = 1;
    }
    else {
        [imgOpen setImage:[UIImage imageNamed:@"pa_open2.png"]];
        button.tag = 0;
    }
}
#pragma mark - 姓名状态/简历状态网络请求
- (void)setOpen:(NSString *)cvHidden nameHidden:(NSString *)nameHidden {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"OpenSet" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", cvHidden, @"cvHidden", nameHidden, @"nameHidden", nil] viewController:nil];
    [request setTag:6];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)nameEdit {
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"简历名称修改" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.text = [cvData objectForKey:@"Name"];
        textField.secureTextEntry = NO;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        UITextField *txtName = alert.textFields.firstObject;
        if (txtName.text.length == 0) {
            [self presentViewController:alert animated:YES completion:nil];
            [self.view.window makeToast:@"请输入简历名称"];
            return;
        }
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UpdateCvName" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", txtName.text, @"name", nil] viewController:nil];
        [request setTag:3];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        self.xmlData = requestData;
        [self getPaOrder];// 获取置顶信息
        [self fillData];
        [self reminderUserToSetTop];// 提醒用户去置顶简历
        [self fillBasic];
        [self fillJobIntention];
        [self fillEducation];
        [self fillExperience];
        [self fillSpeciality];
        [self setupAttachment];// 创建附件简历UI
        [self getCvAttachmentList];// 获取附件简历数据
        
    }else if (request.tag == 4){// 删除简历
        [self.delegate cvInfoReload];
        
    }else if(request.tag == 6){
        // 改变姓名状态/简历状态接口返回结果
    }else{
        [self getData];
    }
    
//    else if (request.tag == 2) {
//        [self.delegate cvInfoReload];
//    }
//    else if (request.tag == 3) {
//        [self.delegate cvInfoReload];
//    }
//    else if (request.tag == 4) {
//        [self.delegate cvInfoReload];
//    }
//    else if (request.tag == 5) {
//        [self.delegate cvInfoReload];
//    }
}

- (void)delete {
    
    if(isTop){
        RCAlertView *alert = [[RCAlertView alloc]initWithTitle:@"提示" content:@"该简历的“简历置顶”服务未到期，无法删除。若已找到工作，可隐藏简历或服务到期后删除" leftBtn:@"我知道了" rightBtn:nil];
        alert.clickBlock = ^(UIButton *button) {
            
        };
        [alert show];
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"该简历删除后，对应的申请记录、面试通知会一并删除，您确认删除吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteResume" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", nil] viewController:self];
        [request setTag:4];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)paInfoModify {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    PaInfoModifyViewController *paInfoModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"paInfoModifyView"];
    [paInfoModifyCtrl setDelegate:self];
    paInfoModifyCtrl.dataPa = paData;
    paInfoModifyCtrl.dataCv = cvData;
    [self.navigationController pushViewController:paInfoModifyCtrl animated:YES];
}

- (void)jobIntentionModify {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    NSDictionary *jobIntentionData = [[NSDictionary alloc] initWithObjectsAndKeys:@"", @"", nil];
    NSArray *arrayJobIntention = [Common getArrayFromXml:self.xmlData tableName:@"JobIntention"];
    if (arrayJobIntention.count > 0) {
        jobIntentionData = [arrayJobIntention objectAtIndex:0];
    }
    IntentionModifyViewController *intentionModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"intentionModifyView"];
    [intentionModifyCtrl setDelegate:self];
    intentionModifyCtrl.dataPa = paData;
    intentionModifyCtrl.dataCv = cvData;
    intentionModifyCtrl.dataJobIntention = jobIntentionData;
    [self.navigationController pushViewController:intentionModifyCtrl animated:YES];
}

- (void)paInfoModifySuccess {
    [self.delegate cvInfoReload];
}

- (void)intentionModifySuccess {
    [self.delegate cvInfoReload];
}

- (void)educationModify {
    EducationViewController *educationCtrl = [[EducationViewController alloc] init];
    educationCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:educationCtrl animated:YES];
}

- (void)addEducation {
    EducationModifyViewController *educationModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"educationModifyView"];
    educationModifyCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:educationModifyCtrl animated:YES];
}

- (void)experienceModify {
    ExperienceViewController *experienceCtrl = [[ExperienceViewController alloc] init];
    experienceCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:experienceCtrl animated:YES];
}

- (void)addExperience {
    ExperienceModifyViewController *experienceModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"experienceModifyView"];
    experienceModifyCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:experienceModifyCtrl animated:YES];
}

- (void)specialityModify {
    NSDictionary *cvData = [[Common getArrayFromXml:self.xmlData tableName:@"CvMain"] objectAtIndex:0];
    SpecialityModifyViewController *specialityCtrl = [[SpecialityModifyViewController alloc] init];
    specialityCtrl.cvMainId = [cvData objectForKey:@"ID"];
    specialityCtrl.speciality = [cvData objectForKey:@"Speciality"];
    [self.navigationController pushViewController:specialityCtrl animated:YES];
}

#pragma mark - 添加附件简历
- (void)addAttachment{
    UIAlertController *alerPhoto = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isUpdateHead = NO;// 上传附件
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        isUpdateHead = NO;// 上传附件
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alerPhoto animated:YES completion:nil];
}

#pragma mark - 更新
- (void)refresh {
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    UIView *viewRefresh = [[UIView alloc] init];
    WKLabel *lbMobile = [[WKLabel alloc] initWithFrame:CGRectMake(20, 10, 70, 60) content:@"手机号码" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [viewRefresh addSubview:lbMobile];
    self.txtMobile = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbMobile) + 15, VIEW_Y(lbMobile), SCREEN_WIDTH - VIEW_BX(lbMobile) - 30, VIEW_H(lbMobile))];
    [self.txtMobile setDelegate:self];
    [self.txtMobile setBorderStyle:UITextBorderStyleNone];
    [self.txtMobile setTextAlignment:NSTextAlignmentRight];
    [self.txtMobile setText:[paData objectForKey:@"Mobile"]];
    [self.txtMobile setFont:DEFAULTFONT];
    [viewRefresh addSubview:self.txtMobile];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(self.txtMobile), SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [viewRefresh addSubview:viewSeparate];
    
    WKLabel *lbCareerStatus = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(lbMobile), VIEW_BY(viewSeparate) + 5, VIEW_W(lbMobile), VIEW_H(lbMobile)) content:@"求职状态" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [viewRefresh addSubview:lbCareerStatus];
    
    self.btnCareerStatus = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(self.txtMobile), VIEW_Y(lbCareerStatus), VIEW_W(self.txtMobile), VIEW_H(self.txtMobile))];
    [self.btnCareerStatus setTitle:[paData objectForKey:@"CareerStatus"] forState:UIControlStateNormal];
    [self.btnCareerStatus setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.btnCareerStatus.titleLabel setFont:DEFAULTFONT];
    [self.btnCareerStatus setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.btnCareerStatus setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 20)];
    [self.btnCareerStatus addTarget:self action:@selector(careerStatusClick) forControlEvents:UIControlEventTouchUpInside];
    [viewRefresh addSubview:self.btnCareerStatus];
    
    UIImageView *imgCareerStatus = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 30, VIEW_Y(self.btnCareerStatus) + 22.5, 15, 15)];
    [imgCareerStatus setImage:[UIImage imageNamed:@"img_arrowright.png"]];
    [imgCareerStatus setContentMode:UIViewContentModeScaleAspectFit];
    [viewRefresh addSubview:imgCareerStatus];
    
    UIView *viewSeparate1 = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbCareerStatus), SCREEN_WIDTH - 30, 1)];
    [viewSeparate1 setBackgroundColor:SEPARATECOLOR];
    [viewRefresh addSubview:viewSeparate1];
    
    [viewRefresh setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate1) + 20)];
    
    [self.view setTag:1];
    self.refreshPop = [[WKPopView alloc] initWithCustomView:viewRefresh];
    [self.refreshPop setDelegate:self];
    [self.refreshPop showPopView:self];
}

#pragma mark - 置顶
- (void)setCvToTop{
    [MobClick event:@"clickSetTopBtn"];
    SetCvTopViewController *cvTopVC = [SetCvTopViewController new];
    cvTopVC.cvMainId = self.cvMainId;
    cvTopVC.JobPlaceName = JobPlaceName;
    [self.navigationController pushViewController:cvTopVC animated:YES];
}

- (void)careerStatusClick {
    [self.txtMobile resignFirstResponder];
    NSDictionary *paData = [[Common getArrayFromXml:self.xmlData tableName:@"PaMain"] objectAtIndex:0];
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCareerStatus value:[paData objectForKey:@"dcCareerStatus"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    [self.btnCareerStatus setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    [self.btnCareerStatus setTag:[[data objectForKey:@"id"] integerValue]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frameView = self.refreshPop.frame;
        frameView.origin.y = SCREEN_HEIGHT - VIEW_H(self.refreshPop) - KEYBOARD_HEIGHT + 30;
        [self.refreshPop setFrame:frameView];
    }];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.2 animations:^{
        CGRect frameView = self.refreshPop.frame;
        frameView.origin.y = SCREEN_HEIGHT - VIEW_H(self.refreshPop);
        [self.refreshPop setFrame:frameView];
    }];
    return YES;
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    [self.view endEditing:YES];
    NSString *mobile = self.txtMobile.text;
    if (![Common checkMobile:mobile]) {
        [self.view.window makeToast:@"请输入正确的手机号"];
        return;
    }
    else if (self.btnCareerStatus.tag == 0) {
        [self.view.window makeToast:@"请选择当前求职状态"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"RefreshResume" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", self.txtMobile.text, @"mobile", [NSString stringWithFormat:@"%ld", self.btnCareerStatus.tag], @"careerStatus", nil] viewController:self];
    [request setTag:5];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
    [popView cancelClick];
}

- (void)preview {
    PreviewViewController *previewCtrl = [[PreviewViewController alloc] init];
    previewCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:previewCtrl animated:YES];
}

#pragma mark - 获取附件简历
- (void)getCvAttachmentList{
    [AFNManager requestWithMethod:POST ParamDict:@{@"cvMainID":self.cvMainId} url:URL_GETCVATTACHMENTLIST tableName:@"ds" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [self.attachmentData removeAllObjects];
        for (NSDictionary *data in requestData) {
            AttachmentModel *model = [AttachmentModel buildModelWithDic:data];
            [self.attachmentData addObject:model];
        }
        [self fillAttachmentData];
        [self setupDeleteBtn];// 创建删除简历
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [RCToast showMessage:@"附件简历获取失败"];
    }];
}

#pragma mark - 加载附件简历数据
- (void)fillAttachmentData{
    
    UIView *temView = [self.scrollView  viewWithTag:101];
    [temView removeFromSuperview];
    
    if (!self.attachmentData.count) {
        self.heightForScroll = VIEW_BY(self.btnAddAttachment);
        return;
    }
    
    AttachMentView *attachmentView = [[AttachMentView alloc]initWithFrame:CGRectMake(0, VIEW_BY(self.btnAddAttachment) -10, SCREEN_WIDTH, 120) data:self.attachmentData];
    attachmentView.tag = 101;
    attachmentView.deleteAttachMent = ^(AttachmentModel *attach) {
        
        AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        __weak __typeof(alertView)WeakAlertView = alertView;
        [WeakAlertView initWithTitle:@"提示" content:@"确定要删除此附件简历吗？" btnTitleArr:@[@"取消",@"确定"] canDismiss:YES];
        WeakAlertView.clickButtonBlock = ^(UIButton *button) {
            if (button.tag == 101) {
                [self deleteCVAttachment:attach];
            }
        };
        [WeakAlertView show];
    };
    [self.scrollView addSubview:attachmentView];
    
    if (self.attachmentData.count == 3){
        self.btnAddAttachment.hidden = YES;
        CGRect frame = attachmentView.frame;
        frame.origin.y = frame.origin.y - 30;
        attachmentView.frame = frame;
    }else{
        self.btnAddAttachment.hidden = NO;
    }
    
    self.heightForScroll = VIEW_BY(attachmentView);
}

#pragma mark - 时间转化
-(NSString *)changeBeginFormatWithDateString:(NSString *)date{
    // 2021-01-04T17:55:00+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}

@end
