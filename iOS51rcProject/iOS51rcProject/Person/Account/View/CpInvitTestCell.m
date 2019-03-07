//
//  CpInvitTestCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CpInvitTestCell.h"

@implementation CpInvitTestCell

- (void)setupSubViews{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UIImageView *imgView = [UIImageView new];
    [self.contentView addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.contentView, 15)
    .topSpaceToView(self.contentView, 10)
    .widthIs(30)
    .heightEqualToWidth();
    [imgView sd_setImageWithURL:[NSURL URLWithString:_model.CpLogoUrl]];
    
    UILabel *cpNameLab = [UILabel new];
    [self.contentView addSubview:cpNameLab];
    cpNameLab.sd_layout
    .leftSpaceToView(imgView, 5)
    .centerYEqualToView(imgView)
    .autoHeightRatio(0)
    .rightSpaceToView(self.contentView, 5);
    cpNameLab.font = DEFAULTFONT;
    cpNameLab.text = _model.CpName;
    
    UILabel *line = [UILabel new];
    [self.contentView addSubview:line];
    line.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(imgView, 10)
    .heightIs(1);
    line.backgroundColor = SEPARATECOLOR;
    
    // 测评名称
    UILabel *assessTypeNameLab  = [UILabel new];
    [self.contentView addSubview:assessTypeNameLab];
    assessTypeNameLab.sd_layout
    .leftEqualToView(imgView)
    .rightSpaceToView(self.contentView, 5)
    .topSpaceToView(line, 10)
    .autoHeightRatio(0);
    assessTypeNameLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    NSString *assessTypeName = [NSString stringWithFormat:@"测评名称：%@",self.model.AssessTypeName];
    NSMutableAttributedString *AttributedStr1 = [[NSMutableAttributedString alloc]initWithString:assessTypeName];
    [AttributedStr1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    assessTypeNameLab.attributedText = AttributedStr1;
    
    
    // 邀请时间
    UILabel  *addDateLab = [UILabel new];
    [self.contentView addSubview:addDateLab];
    addDateLab.sd_layout
    .leftEqualToView(assessTypeNameLab)
    .rightEqualToView(assessTypeNameLab)
    .topSpaceToView(assessTypeNameLab, 10)
    .autoHeightRatio(0);
    addDateLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    NSString * addDate = [NSString stringWithFormat:@"邀请时间：%@",[CommonTools changeDateWithDateString:self.model.AddDate]];
    NSMutableAttributedString *AttributedStr2 = [[NSMutableAttributedString alloc]initWithString:addDate];
    [AttributedStr2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    addDateLab.attributedText = AttributedStr2;
    
    // 截止时间
    UILabel  *endDateLab = [UILabel new];
    [self.contentView addSubview:endDateLab];
    endDateLab.sd_layout
    .leftEqualToView(addDateLab)
    .rightEqualToView(addDateLab)
    .topSpaceToView(addDateLab, 10)
    .autoHeightRatio(0);
    endDateLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    NSString * endDate = [NSString stringWithFormat:@"截止时间：%@",[CommonTools changeDateWithDateString:self.model.EndDate]];
    NSMutableAttributedString *AttributedStr3 = [[NSMutableAttributedString alloc]initWithString:endDate];
    [AttributedStr3 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    endDateLab.attributedText = AttributedStr3;
    
    
    // 测评状态
    UILabel  *assessStatusLab = [UILabel new];
    [self.contentView addSubview:assessStatusLab];
    assessStatusLab.sd_layout
    .leftEqualToView(addDateLab)
    .rightEqualToView(addDateLab)
    .topSpaceToView(endDateLab, 10)
    .autoHeightRatio(0);
    assessStatusLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    NSString * endassessStatus = [NSString stringWithFormat:@"测评状态：%@",self.model.isComplete];
    NSMutableAttributedString *AttributedStr4 = [[NSMutableAttributedString alloc]initWithString:endassessStatus];
    [AttributedStr4 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    assessStatusLab.attributedText = AttributedStr4;
    
    if(![self.model.isAssessStatus isEqualToString:@"2"]){
        
        UILabel *line2 = [UILabel new];
        [self.contentView addSubview:line2];
        line2.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(assessStatusLab, 5)
        .heightIs(1);
        line2.backgroundColor = SEPARATECOLOR;
        // 开始测评按钮
        UIButton *assessBtn = [UIButton new];
        [self.contentView addSubview:assessBtn];
        assessBtn.sd_layout
        .topSpaceToView(line2, 5)
        .heightIs(40)
        .centerXEqualToView(self.contentView)
        .widthIs(80);
        [assessBtn setImage:[UIImage imageNamed:@"ico_play"] forState:UIControlStateNormal];
        NSString *btnTitle = [self.model.isAssessStatus isEqualToString:@"0"]?@"开始测评":@"继续测评";
        [assessBtn setTitle:btnTitle forState:UIControlStateNormal];
        assessBtn.titleLabel.font = DEFAULTFONT;
        [assessBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [assessBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
        
        UIView *bottomView = [UIView new];
        [self.contentView addSubview:bottomView];
        bottomView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(assessBtn, 0)
        .heightIs(10);
        bottomView.backgroundColor = SEPARATECOLOR;
        [self setupAutoHeightWithBottomView:bottomView bottomMargin:0];
        
    }else if([self.model.isAssessStatus isEqualToString:@"2"]){
        UIView *bottomView = [UIView new];
        [self.contentView addSubview:bottomView];
        bottomView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(assessStatusLab, 10)
        .heightIs(10);
        bottomView.backgroundColor = SEPARATECOLOR;
        [self setupAutoHeightWithBottomView:bottomView bottomMargin:0];
    }
}

- (void)setModel:(CpInvitTestModel *)model{
    _model = model;
    [self setupSubViews];
}

- (void)btnClick{
    self.cellBlock(self.model);
}
@end
