//
//  RecommendJobCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/12.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "RecommendJobCell.h"
#import "Common.h"
#import "NSString+RCString.h"
#import "InsertJobApplyModel.h"

@interface RecommendJobCell()
@property (nonatomic , strong) InsertJobApplyModel *model;
@end

@implementation RecommendJobCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(InsertJobApplyModel *)model{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.model = model;
        [self setupAllSubViews];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}
- (void)setupAllSubViews{
    // 选择按钮
    UIButton *selectedBtn = [UIButton new];
    [self.contentView addSubview:selectedBtn];
    selectedBtn.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .centerYEqualToView(self.contentView)
    .widthIs(20)
    .heightEqualToWidth();
    [selectedBtn setImage:[UIImage imageNamed:@"img_checksmall1"] forState:UIControlStateSelected];
    [selectedBtn setImage:[UIImage imageNamed:@"img_checksmall2"] forState:UIControlStateNormal];
    selectedBtn.selected = YES;
    [selectedBtn addTarget:self action:@selector(selectedBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    // 公司名
    UILabel *companyLab = [UILabel new];
    [self.contentView addSubview:companyLab];
    companyLab.sd_layout
    .leftSpaceToView(selectedBtn, 5)
    .centerYEqualToView(self.contentView)
    .heightIs(25);
    companyLab.font = DEFAULTFONT;
    companyLab.text = self.model.cpName;
    [companyLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH - 35 - 40 - 100];
    companyLab.textColor = TEXTGRAYCOLOR;
    
    
    // 职位名
    UILabel *positionLab = [UILabel new];
    [self.contentView addSubview:positionLab];
    positionLab.sd_layout
    .leftEqualToView(companyLab)
    .bottomSpaceToView(companyLab, 0)
    .heightIs(18);
    positionLab.text = self.model.JobName;
    positionLab.font = BIGGERFONT;
    [positionLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH - 35 - 40 - 100];
//    positionLab.backgroundColor = [UIColor redColor];
    
    // 薪资
    UILabel *salaryLab = [UILabel new];
    [self.contentView addSubview:salaryLab];
    salaryLab.sd_layout
    .rightSpaceToView(self.contentView, 5)
    .leftSpaceToView(positionLab, 0)
    .topEqualToView(positionLab)
    .heightRatioToView(positionLab, 1);
    salaryLab.textAlignment = NSTextAlignmentRight;
    salaryLab.textColor = NAVBARCOLOR;
    salaryLab.font = DEFAULTFONT;
//    salaryLab.backgroundColor = [UIColor greenColor];
    salaryLab.text = [Common getSalary:self.model.dcSalaryID salaryMin:self.model.dcSalary salaryMax:self.model.dcSalaryMax negotiable:@""];
    
    // 发布日期
    UILabel *releaseTimeLab = [UILabel new];
    [self.contentView addSubview:releaseTimeLab];
    releaseTimeLab.sd_layout
    .rightEqualToView(salaryLab)
    .widthIs(80)
    .heightRatioToView(companyLab, 1)
    .centerYEqualToView(companyLab);
    releaseTimeLab.text = [Common stringFromRefreshDate:self.model.RefreshDate];
    releaseTimeLab.textColor =TEXTGRAYCOLOR;
    releaseTimeLab.font = DEFAULTFONT;
    releaseTimeLab.textAlignment = NSTextAlignmentRight;
    
    
    // 其他信息
    NSString *experience = self.model.ExperienceName ;
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = self.model.EducationName;
    if ([education length] == 0) {
        education = @"学历不限";
    }
    NSString *reginStr = [NSString cutProvince:self.model.Region];
    UILabel *infoLab = [UILabel new];
    [self.contentView addSubview:infoLab];
    infoLab.sd_layout
    .leftEqualToView(companyLab)
    .rightEqualToView(salaryLab)
    .topSpaceToView(companyLab, 0)
    .heightRatioToView(positionLab, 1);
    infoLab.font = DEFAULTFONT;
    infoLab.textColor = TEXTGRAYCOLOR;
    infoLab.text = [NSString stringWithFormat:@"%@ | %@ | %@", reginStr, experience, education];
}

- (void)selectedBtnClick:(UIButton *)btn{
    btn.selected = !btn.selected;
    self.model.isSeleted = btn.selected;
    self.selectedPositon(self.model);
}
@end
