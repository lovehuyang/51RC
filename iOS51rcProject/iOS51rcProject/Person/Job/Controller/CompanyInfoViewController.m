//
//  CompanyInfoViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/26.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  企业信息页面

#import "CompanyInfoViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "UIImageView+WebCache.h"
#import "CompanyDetailViewController.h"
#import "JobListViewController.h"
#import "SCNavTabBarController.h"
#import "MapViewController.h"

@interface CompanyInfoViewController ()<JobListViewDelegate>

@end

@implementation CompanyInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:SEPARATECOLOR];
    [self fillData];
}

- (void)fillData {
    // 顶部展示公司信息的容器
    UIView *viewCpInfo = [[UIView alloc] init];
    [viewCpInfo setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:viewCpInfo];
    // logo
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[self.companyData objectForKey:@"LogoFile"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [viewCpInfo addSubview:imgLogo];
    //存放公司名、公司信息的容器
    UIView *viewInfo = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(imgLogo), 0, SCREEN_WIDTH - VIEW_BX(imgLogo), 500)];
    [viewCpInfo addSubview:viewInfo];
    
    float maxWidth = VIEW_W(viewInfo) - 10;
    //公司名称
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(10, 15, maxWidth - 43.5, 20) content:[self.companyData objectForKey:@"Name"] size:BIGGERFONTSIZE color:nil spacing:0];
    [viewInfo addSubview:lbCompany];
    //实名认证图标
    UIImageView *imgCompany;
    
    float widthForLastline = [Common getLastLineWidth:lbCompany];
    if ([[self.companyData objectForKey:@"RealName"] isEqualToString:@"1"]) {
        imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbCompany) + widthForLastline, VIEW_BY(lbCompany) - 15, 43.2, 15)];
        [imgCompany setImage:[UIImage imageNamed:@"img_realname.png"]];
    }
    else if ([[self.companyData objectForKey:@"MemberType"] intValue] > 1) {
        imgCompany = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbCompany) + widthForLastline + 3, VIEW_BY(lbCompany) - 15, 20.3, 15)];
        [imgCompany setImage:[UIImage imageNamed:@"img_licence.png"]];
    }
    if (imgCompany != nil) {
        [viewInfo addSubview:imgCompany];
        if (VIEW_BX(imgCompany) > VIEW_W(viewInfo) - 43.5) {
            CGRect frameImgCompany = imgCompany.frame;
            frameImgCompany.origin.x = VIEW_X(lbCompany);
            frameImgCompany.origin.y = VIEW_BY(lbCompany) + 5;
            [imgCompany setFrame:frameImgCompany];
        }
    }
    
    //公司信息
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompany), VIEW_BY((imgCompany == nil ? lbCompany : imgCompany)) + 5, maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [self.companyData objectForKey:@"Industry"], [self.companyData objectForKey:@"CompanyKind"], [self.companyData objectForKey:@"CompanySize"]] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewInfo addSubview:lbDetail];
    
    CGRect frameViewInfo = viewInfo.frame;
    frameViewInfo.size.height = VIEW_BY(lbDetail) ;
//    if ([[self.companyData objectForKey:@"HomePage"] length] > 0) {
//        //公司主页
//        WKLabel *lbHomePage = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbDetail) + 5, maxWidth, 20) content:[self.companyData objectForKey:@"HomePage"] size:DEFAULTFONTSIZE color:nil spacing:0];
//        [viewInfo addSubview:lbHomePage];
//        frameViewInfo.size.height = VIEW_BY(lbHomePage);
//    }
    
    // 答复率
    //答复率
    float replyRate = [[self.companyData objectForKey:@"ReplyRate"] floatValue] * 100;
        if (replyRate > 60) {
            
            UILabel *replyRateLab = [[UILabel alloc]initWithFrame:CGRectMake(VIEW_X(lbCompany), CGRectGetMaxY(frameViewInfo) + 5, 150, 16)];
            replyRateLab.font = SMALLERFONT;
            replyRateLab.textColor = GREENCOLOR;
            NSString *contentStr = [NSString stringWithFormat:@"企业答复率:%.f%%", replyRate];
            NSMutableAttributedString *noteStr = [[NSMutableAttributedString alloc] initWithString:contentStr];
            NSRange redRange = NSMakeRange([[noteStr string] rangeOfString:@"企业答复率:"].location, [[noteStr string] rangeOfString:@"企业答复率:"].length);
            //需要设置的位置
            [noteStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:redRange];
            //设置颜色
            [replyRateLab setAttributedText:noteStr];
            [viewInfo addSubview:replyRateLab];
            frameViewInfo.size.height = VIEW_BY(replyRateLab) + 5;
        }
    
    [viewInfo setFrame:frameViewInfo];

    //调整Logo和右边文字的位置
    if (VIEW_BY(imgLogo) > VIEW_BY(viewInfo)) {
        [viewInfo setCenter:CGPointMake(viewInfo.center.x, imgLogo.center.y)];
    }
    else {
        [imgLogo setCenter:CGPointMake(imgLogo.center.x, viewInfo.center.y)];
    }
    
    // 分割线
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(viewInfo), SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [viewCpInfo addSubview:viewSeparate];
    
    //公司地址
    WKLabel *lbAddress = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(viewSeparate) + 10, SCREEN_WIDTH - 30, 15) content:[NSString stringWithFormat:@"%@%@", [self.companyData objectForKey:@"RegionName"], [self.companyData objectForKey:@"Address"]] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewCpInfo addSubview:lbAddress];
    //查看地图
    if ([[self.companyData objectForKey:@"Lng"] length] > 0) {
        widthForLastline = [Common getLastLineWidth:lbAddress];
        UIButton *btnAddress = [[UIButton alloc] initWithFrame:CGRectMake(widthForLastline + VIEW_X(lbAddress) + 3, VIEW_BY(lbAddress) - 15, 60, 15)];
        [btnAddress setImage:[UIImage imageNamed:@"img_map.png"] forState:UIControlStateNormal];
        [btnAddress.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnAddress addTarget:self action:@selector(mapClick) forControlEvents:UIControlEventTouchUpInside];
        [viewCpInfo addSubview:btnAddress];
        
        if (VIEW_BX(btnAddress) > SCREEN_WIDTH - 15) {
            CGRect frameBtnAddress = btnAddress.frame;
            frameBtnAddress.origin.x = VIEW_X(lbAddress);
            frameBtnAddress.origin.y = VIEW_BY(lbAddress) + 5;
            [btnAddress setFrame:frameBtnAddress];
        }
        //调整公司信息高度
        [viewCpInfo setFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, VIEW_BY(btnAddress) + 10)];
    }
    else {
        //调整公司信息高度
        [viewCpInfo setFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, VIEW_BY(lbAddress) + 10)];
    }
    [self fillCpOther:viewCpInfo];
}

- (void)fillCpOther:(UIView *)view {
    CompanyDetailViewController *detailCtrl = [[CompanyDetailViewController alloc] init];
    detailCtrl.companyData = self.companyData;
    detailCtrl.arrEnvironment = self.arrEnvironment;
    detailCtrl.title = @"企业简介";
    
    JobListViewController *listCtrl = [[JobListViewController alloc] init];
    [listCtrl setDelegate:self];
    listCtrl.companyId = [self.companyData objectForKey:@"ID"];
    listCtrl.title = @"职位列表";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[detailCtrl, listCtrl];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
    
    CGRect frameNav = navTabCtrl.view.frame;
    frameNav.origin.y = VIEW_BY(view) + 10;
    frameNav.size.height = SCREEN_HEIGHT - frameNav.origin.y;
    [navTabCtrl.view setFrame:frameNav];
    
    float childViewHeight = frameNav.size.height - NAVIGATION_BAR_HEIGHT;
    [detailCtrl adjustHeight:childViewHeight];
    [listCtrl adjustHeight:childViewHeight];
}

- (void)jobClick:(NSString *)jobId {
    [self.delegate jobClickFromCompany:jobId];
}

- (void)setTitleButton:(UIButton *)btnAttention btnShare:(UIButton *)btnShare {
    [btnAttention setTitle:[self.companyData objectForKey:@"ID"] forState:UIControlStateNormal];
    [btnShare setTag:1];
    if ([[self.companyData objectForKey:@"hasAttention"] boolValue]) {
        [btnAttention setImage:[UIImage imageNamed:@"img_favorite1.png"] forState:UIControlStateNormal];
        [btnAttention setTag:0];
    }
    else {
        [btnAttention setImage:[UIImage imageNamed:@"img_favorite2.png"] forState:UIControlStateNormal];
        [btnAttention setTag:1];
    }
}

- (void)changeAttention {
    NSMutableDictionary *data = [self.companyData mutableCopy];
    [data setValue:@"true" forKey:@"hasAttention"];
    self.companyData = data;
}

- (void)mapClick {
    MapViewController *mapCtrl = [[MapViewController alloc] init];
    mapCtrl.lat = [self.companyData objectForKey:@"Lat"];
    mapCtrl.lng = [self.companyData objectForKey:@"Lng"];
    mapCtrl.pointTitle = [NSString stringWithFormat:@"%@%@", [self.companyData objectForKey:@"RegionName"], [self.companyData objectForKey:@"Address"]];
    mapCtrl.title = [self.companyData objectForKey:@"Name"];
    [self.navigationController pushViewController:mapCtrl animated:YES];
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
