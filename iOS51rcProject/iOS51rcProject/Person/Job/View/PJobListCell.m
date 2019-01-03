//
//  PJobListCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "PJobListCell.h"
#import "PJobListModel.h"
#import "WKLabel.h"
#import "OnlineLab.h"
#import "NSString+RCString.h"
#import "Common.h"


@implementation PJobListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
    }
    return self;
}

- (void)setModel:(PJobListModel *)model{
    _model = model;
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    if ([_model.IsTop boolValue]) {
        UIImageView *imgTop = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imgTop setImage:[UIImage imageNamed:@"job_top.png"]];
        [imgTop setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgTop];
    }
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:_model.LogoUrl] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [self.contentView addSubview:imgLogo];
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 20;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo) - 5, maxWidth - 70, 20) content:_model.JobName size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [self.contentView addSubview:lbJob];
    
    if ([_model.IsOnline boolValue]) {
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [self.contentView addSubview:onlineLab];
    }
    
    WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, VIEW_Y(lbJob), 70, 20) content:[Common getSalary:_model.dcSalaryID salaryMin:_model.dcSalary salaryMax:_model.dcSalaryMax negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:lbSalary];
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth - 65, 20) content:_model.cpName size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [self.contentView addSubview:lbCompany];
    
    // 刷新时间
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, VIEW_Y(lbCompany), 70, 20) content:[Common stringFromRefreshDate:_model.RefreshDate] size:SMALLERFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:lbDate];
    
    NSString *experience = _model.ExperienceName;
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = _model.EducationName;
    if ([education length] == 0) {
        education = @"学历不限";
    }
    NSString *reginStr = [NSString cutProvince:_model.Region];
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", reginStr, experience, education] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [self.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparate];
    
    [self setupAutoHeightWithBottomView:viewSeparate bottomMargin:0];
    
}

@end
