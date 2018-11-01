//
//  WKCvTableViewCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/24.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "WKCvTableViewCell.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "UIImageView+WebCache.h"
#import "CvOperate.h"

@interface WKCvTableViewCell ()<CvOperateDelegate>

@property (nonatomic, strong) CvOperate *operate;
@end

@implementation WKCvTableViewCell

- (instancetype)initWithListType:(NSInteger)listType reuseIdentifier:(NSString *)reuseIdentifier viewController:(UIViewController *)viewController {
    self = [[WKCvTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        self.viewController = viewController;
        self.listType = listType;
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)fillCvInfo:(NSString *)topString gender:(NSString *)gender name:(NSString *)name relatedWorkYears:(NSString *)relatedWorkYears age:(NSString *)age degree:(NSString *)degree livePlace:(NSString *)livePlace loginDate:(NSString *)loginDate mobileVerifyDate:(NSString *)mobileVerifyDate paPhoto:(NSString *)paPhoto online:(NSString *)online paMainId:(NSString *)paMainId cvMainId:(NSString *)cvMainId {
    self.cvMainId = cvMainId;
    UIButton *btnOnline = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 85, 0, 70, 40)];
    [btnOnline setTitle:@"跟TA聊聊" forState:UIControlStateNormal];
    [btnOnline setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnOnline setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btnOnline.titleLabel setFont:DEFAULTFONT];
    [btnOnline addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnOnline];
    
    WKLabel *lbSalaryAndCollege = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 0, VIEW_X(btnOnline) - 15, VIEW_H(btnOnline)) content:topString size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbSalaryAndCollege];
    
    UIView *viewSeparateTop = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbSalaryAndCollege), SCREEN_WIDTH, 1)];
    [viewSeparateTop setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparateTop];
    
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbSalaryAndCollege), VIEW_BY(viewSeparateTop) + 20, 50, 50)];
    [imgPhoto setImage:[UIImage imageNamed:([gender boolValue] ? @"img_photowoman.png" : @"img_photoman.png")]];
    [imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
    [imgPhoto.layer setMasksToBounds:YES];
    [imgPhoto.layer setCornerRadius:25];
    if ([paPhoto length] > 0 && [paMainId length] > 0) {
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[Common getPaPhotoUrl:paPhoto paMainId:paMainId]]];
    }
    [self.contentView addSubview:imgPhoto];
    
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPhoto) + 15, VIEW_Y(imgPhoto), 500, 30) content:name size:BIGGERFONTSIZE color:nil];
    [self.contentView addSubview:lbName];
    
    float xForName = VIEW_BX(lbName);
    if ([mobileVerifyDate length] > 0) {
        UIImageView *imgMobile = [[UIImageView alloc] initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 16, 16)];
        [imgMobile setImage:[UIImage imageNamed:@"cp_mobilecer.png"]];
        [imgMobile setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgMobile];
        xForName = VIEW_BX(imgMobile);
    }
    
    if ([online boolValue]) {
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 16, 16)];
        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
        [imgOnline setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgOnline];
    }
    
    NSString *workYears = @"";
    if ([relatedWorkYears isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([relatedWorkYears isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([relatedWorkYears length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", relatedWorkYears];
    }
    WKLabel *lbInfo = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbName), VIEW_BY(lbName), 500, 30) content:[NSString stringWithFormat:@"%@ | %@岁 | %@ | %@工作经验 | %@", ([gender boolValue] ? @"女" : @"男"), age, (degree.length == 0 ? @"学历未填写" : degree), workYears, livePlace] size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbInfo];
    
    UIView *viewSeparateBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgPhoto) + 20, SCREEN_WIDTH, 1)];
    [viewSeparateBottom setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparateBottom];
    
    UIButton *btnInvitation = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, VIEW_BY(viewSeparateBottom) + 7, 75, 26)];
    [btnInvitation.layer setCornerRadius:5];
    [btnInvitation setTitle:@"应聘邀请" forState:UIControlStateNormal];
    [btnInvitation setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnInvitation setBackgroundColor:GREENCOLOR];
    [btnInvitation.titleLabel setFont:DEFAULTFONT];
    [btnInvitation addTarget:self action:@selector(invitationClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnInvitation];
    
    UIButton *btnFavorite = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(btnInvitation) - 80, VIEW_Y(btnInvitation), 75, VIEW_H(btnInvitation))];
    [btnFavorite.layer setCornerRadius:5];
    [btnFavorite setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnFavorite setBackgroundColor:GREENCOLOR];
    [btnFavorite.titleLabel setFont:DEFAULTFONT];
    [self.contentView addSubview:btnFavorite];
    if (self.listType == 0 || self.listType == 3) {
        [btnFavorite setTitle:@"收藏" forState:UIControlStateNormal];
        [btnFavorite addTarget:self action:@selector(favoriteClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else {
        [btnFavorite setTitle:@"面试通知" forState:UIControlStateNormal];
        [btnFavorite addTarget:self action:@selector(interviewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    NSString *dateTitle = @"登录日期";
    if (self.listType == 1) {
        dateTitle = @"下载日期";
    }
    else if (self.listType == 2) {
        dateTitle = @"收藏日期";
    }
    else if (self.listType == 3) {
        dateTitle = @"推荐日期";
    }
    WKLabel *lbLoginDate = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbSalaryAndCollege), VIEW_BY(viewSeparateBottom), 500, VIEW_H(btnOnline)) content:[NSString stringWithFormat:@"%@：%@", dateTitle, [Common stringFromDateString:loginDate formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbLoginDate];
    
    [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbLoginDate))];
    //操作
    self.operate = [[CvOperate alloc] init:self.cvMainId paName:name viewController:self.viewController];
    [self.operate setDelegate:self];
}

- (void)setJobId:(NSString *)jobId {
    [self.operate setJobId:jobId];
}

- (void)chatClick {
    [self.operate beginChat];
}

- (void)invitationClick {
    [self.operate invitation];
}

- (void)favoriteClick {
    [self.operate favorite];
}

- (void)interviewClick {
    [self.operate interview];
}

@end
