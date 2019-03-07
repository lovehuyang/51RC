//
//  AssessIndexCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AssessIndexCell.h"
#import "AssessIndexModel.h"

@implementation AssessIndexCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupModel:(AssessIndexModel *)model{
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    UIColor *greenColor = [UIColor colorWithHex:0x15A31B];
    
    // 标题
    UILabel *titleLab = [UILabel new];
    [self.contentView addSubview:titleLab];
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .topSpaceToView(self.contentView, 10)
    .autoHeightRatio(0);
    [titleLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    titleLab.text = model.Name;
    
    if ([model.isPay boolValue]) {
        UIButton *payStatus = [UIButton new];
        [self.contentView addSubview:payStatus];
        payStatus.sd_layout
        .rightSpaceToView(self.contentView, 10)
        .heightRatioToView(titleLab, 1)
        .centerYEqualToView(titleLab)
        .widthIs(80);
        [payStatus setTitle:@"已付款" forState:UIControlStateNormal];
        [payStatus setImage:[UIImage imageNamed:@"ico_buyed"] forState:UIControlStateNormal];
        payStatus.titleLabel.font = DEFAULTFONT;
        [payStatus setTitleColor:greenColor forState:UIControlStateNormal];
    }
    
    UIView *line1 = [UIView new];
    [self.contentView addSubview:line1];
    line1.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(titleLab, 10)
    .heightIs(1);
    line1.backgroundColor = SEPARATECOLOR;
    
    // 简介
    UILabel *summaryLab = [UILabel new];
    [self.contentView addSubview:summaryLab];
    summaryLab.sd_layout
    .leftEqualToView(titleLab)
    .rightSpaceToView(self.contentView, 10)
    .topSpaceToView(summaryLab, 10)
    .autoHeightRatio(0);
    summaryLab.font = DEFAULTFONT;
    summaryLab.text = model.Summary;
    
    UIView *line2 = [UIView new];
    [self.contentView addSubview:line2];
    line2.sd_layout
    .leftEqualToView(line1)
    .rightEqualToView(line1)
    .topSpaceToView(summaryLab, 10)
    .heightRatioToView(line1, 1);
    line2.backgroundColor = SEPARATECOLOR;

    // 我要测评/开始测评
    NSArray *btnImgArr = @[[model.isPay boolValue]?@"ico_start_test":@"ico_preparing_test",@"ico_yaoqing"];
    NSArray *btnTitleArr = @[[model.isPay boolValue]?@" 开始测评": @" 我要测评",@"邀请朋友"];
    CGFloat W = SCREEN_WIDTH/2;
    for (int i = 0 ; i < 2; i ++) {
        UIView *bgView = [UIView new];
        [self.contentView addSubview:bgView];
        bgView.sd_layout
        .leftSpaceToView(self.contentView, W * i)
        .topSpaceToView(line2, 0)
        .widthIs(W)
        .heightIs(40);
        bgView.userInteractionEnabled = YES;
       
        UIButton *assessBtn = [UIButton new];
        [bgView addSubview:assessBtn];
        assessBtn.sd_layout
        .topSpaceToView(bgView, 10)
        .bottomSpaceToView(bgView, 10)
        .centerXEqualToView(bgView)
        .widthIs(100);
        [assessBtn setImage:[UIImage imageNamed:btnImgArr[i]] forState:UIControlStateNormal];
        [assessBtn setTitle:btnTitleArr[i] forState:UIControlStateNormal];
        assessBtn.titleLabel.font = DEFAULTFONT;
        if(i == 0){
             [assessBtn setTitleColor:[model.isPay boolValue]?greenColor:NAVBARCOLOR forState:UIControlStateNormal];
        }else{
            [assessBtn setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        }
        assessBtn.tag = 100 + i;
        [assessBtn addTarget:self action:@selector(assessBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    UIView *separateView = [UIView new];
    [self.contentView addSubview:separateView];
    separateView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(line2, 41)
    .heightIs(15);
    separateView.backgroundColor = SEPARATECOLOR;
    
     [self setupAutoHeightWithBottomView:separateView bottomMargin:0];
}

- (void)setModel:(AssessIndexModel *)model{
    _model = model;
    [self setupModel:_model];
}

- (void)assessBtnClick:(UIButton *)button{
    self.assessBlock(_model, button);
}
@end
