//
//  MyselfAssessCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyselfAssessCell.h"
#import "MyselfAssessModel.h"
@interface MyselfAssessCell()

@property (nonatomic , strong) UILabel *assessTypeNameLab;// 测试名称
@property (nonatomic , strong) UILabel *beginTimeLab;// 开始时间
@property (nonatomic , strong) UILabel *generateLab;// 测评报告
@property (nonatomic , strong) UIButton *openBtn;//
@property (nonatomic , strong) UIView *bottomView;

@end
@implementation MyselfAssessCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    self.assessTypeNameLab  = [UILabel new];
    [self.contentView addSubview:self.assessTypeNameLab];
    self.assessTypeNameLab.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .rightSpaceToView(self.contentView, 10)
    .topSpaceToView(self.contentView, 15)
    .autoHeightRatio(0);
    self.assessTypeNameLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    
    self.beginTimeLab = [UILabel new];
    [self.contentView addSubview:self.beginTimeLab];
    self.beginTimeLab.sd_layout
    .leftEqualToView(self.assessTypeNameLab)
    .rightEqualToView(self.assessTypeNameLab)
    .topSpaceToView(self.assessTypeNameLab, 10)
    .autoHeightRatio(0);
    self.beginTimeLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    
    self.generateLab = [UILabel new];
    [self.contentView addSubview:self.generateLab];
    self.generateLab.sd_layout
    .leftEqualToView(self.beginTimeLab)
    .rightEqualToView(self.beginTimeLab)
    .topSpaceToView(self.beginTimeLab, 10)
    .autoHeightRatio(0);
    self.generateLab.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    
    // 已经测评完成的显示投递设置
    if([self.model.isComplete isEqualToString:@"已完成"]){
        // 投递设置
        UILabel *setLab = [UILabel new];
        [self.contentView addSubview:setLab];
        setLab.sd_layout
        .leftEqualToView(self.generateLab)
        .topSpaceToView(self.generateLab, 10)
        .autoHeightRatio(0);
        [setLab setSingleLineAutoResizeWithMaxWidth:200];
        setLab.font = DEFAULTFONT;
        setLab.text = @"投递设置：";
        
        self.openBtn = [UIButton new];
        [self.contentView addSubview:self.openBtn];
        self.openBtn.sd_layout
        .leftSpaceToView(setLab, 3)
        .centerYEqualToView(setLab)
        .heightRatioToView(setLab, 1.1)
        .widthIs(78);
        [self.openBtn setBackgroundImage:[UIImage imageNamed:@"ico_switch_close"] forState:UIControlStateSelected];
        [self.openBtn setBackgroundImage:[UIImage imageNamed:@"ico_switch_open"] forState:UIControlStateNormal];
        [self.openBtn setTitle:@"不可投递" forState:UIControlStateSelected];
        [self.openBtn setTitle:@"可投递" forState:UIControlStateNormal];
        self.openBtn.titleLabel.font =  [UIFont boldSystemFontOfSize:11];
        self.openBtn.tag = 103;
        [self.openBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
       
        UILabel *tipLab = nil;
        if ([self.model.IsOpen boolValue]) {
            tipLab = [UILabel new];
            [self.contentView addSubview:tipLab];
            tipLab.sd_layout
            .leftEqualToView(self.assessTypeNameLab)
            .topSpaceToView(setLab, 10)
            .autoHeightRatio(0)
            .rightSpaceToView(self.contentView, 10);
            tipLab.font = SMALLERFONT;
            tipLab.textColor = TEXTGRAYCOLOR;
            tipLab.text = @"申请职位时，自动投递本份测评报告";
        }
        
        UILabel *line = [UILabel new];
        [self.contentView addSubview:line];
        line.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(tipLab == nil ?self.openBtn: tipLab, 10)
        .heightIs(1);
        line.backgroundColor = SEPARATECOLOR;
        
        UILabel *lineV = [UILabel new];
        [self.contentView addSubview:lineV];
        lineV.sd_layout
        .centerXEqualToView(self.contentView)
        .topSpaceToView(line, 0)
        .widthIs(1)
        .heightIs(40);
        lineV.backgroundColor = SEPARATECOLOR;
        
        UIButton *assessreportBtn = [UIButton new];
        [self.contentView addSubview:assessreportBtn];
        CGFloat X1 = SCREEN_WIDTH/4;
        assessreportBtn.sd_layout
        .centerXIs(X1)
        .topSpaceToView(line, 0)
        .bottomEqualToView(lineV)
        .widthIs(110);
        [assessreportBtn setImage:[UIImage imageNamed:@"ico_view"] forState:UIControlStateNormal];
        [assessreportBtn setTitle:@"查看测评报告" forState:UIControlStateNormal];
        assessreportBtn.titleLabel.font = DEFAULTFONT;
        [assessreportBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        assessreportBtn.tag = 100;
        [assessreportBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        
        UIButton *reAssessBtn = [UIButton new];
        [self.contentView addSubview:reAssessBtn];
        CGFloat X2 = SCREEN_WIDTH/4 * 3;
        reAssessBtn.sd_layout
        .centerXIs(X2)
        .topEqualToView(assessreportBtn)
        .bottomEqualToView(assessreportBtn)
        .widthIs(80);
        [reAssessBtn setImage:[UIImage imageNamed:@"ico_play"] forState:UIControlStateNormal];
        [reAssessBtn setTitle:@"重新测评" forState:UIControlStateNormal];
        reAssessBtn.titleLabel.font = DEFAULTFONT;
        [reAssessBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        reAssessBtn.tag = 101;
        [reAssessBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        
        self.bottomView = [UIView new];
        [self.contentView addSubview:self.bottomView];
        self.bottomView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(lineV, 0)
        .heightIs(10);
        self.bottomView.backgroundColor = SEPARATECOLOR;
        
    }else{// 测评未完成
        UILabel *line = [UILabel new];
        [self.contentView addSubview:line];
        line.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(self.generateLab, 10)
        .heightIs(1);
        line.backgroundColor = SEPARATECOLOR;
        
        UIButton *assessreportBtn = [UIButton new];
        [self.contentView addSubview:assessreportBtn];
        CGFloat X = SCREEN_WIDTH/2;
        assessreportBtn.sd_layout
        .centerXIs(X)
        .topSpaceToView(line, 0)
        .heightIs(40)
        .widthIs(110);
        [assessreportBtn setImage:[UIImage imageNamed:@"ico_play"] forState:UIControlStateNormal];
        [assessreportBtn setTitle:@"继续完成测评" forState:UIControlStateNormal];
        assessreportBtn.titleLabel.font = DEFAULTFONT;
         [assessreportBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        assessreportBtn.tag = 102;
        [assessreportBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        self.bottomView = [UIView new];
        [self.contentView addSubview:self.bottomView];
        self.bottomView.sd_layout
        .leftSpaceToView(self.contentView, 0)
        .rightSpaceToView(self.contentView, 0)
        .topSpaceToView(assessreportBtn, 0)
        .heightIs(10);
        self.bottomView.backgroundColor = SEPARATECOLOR;
    }
    
    [self setupAutoHeightWithBottomView:self.bottomView bottomMargin:0];
}


- (void)setModel:(MyselfAssessModel *)model{
    _model = model;
    
    [self setupSubViews];
    //
    NSString *assessTypeName = [NSString stringWithFormat:@"测评名称：%@",self.model.AssessTypeName];
    NSMutableAttributedString *AttributedStr1 = [[NSMutableAttributedString alloc]initWithString:assessTypeName];
    [AttributedStr1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    self.assessTypeNameLab.attributedText = AttributedStr1;
    //
    NSString * beginTime = [NSString stringWithFormat:@"开始时间：%@ %@",[CommonTools changeDateWithDateString:self.model.BeginTime],self.model.isComplete];
    NSMutableAttributedString *AttributedStr2 = [[NSMutableAttributedString alloc]initWithString:beginTime];
    [AttributedStr2 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    self.beginTimeLab.attributedText = AttributedStr2;
    //
    NSString *generate = [NSString stringWithFormat:@"测评报告：%@",self.model.isGenerate];
    NSMutableAttributedString *AttributedStr3 = [[NSMutableAttributedString alloc]initWithString:generate];
    [AttributedStr3 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:DEFAULTFONTSIZE]range:NSMakeRange(0, 5)];
    self.generateLab.attributedText = AttributedStr3;
    
    //
    if ([self.model.IsOpen boolValue]) {
        self.openBtn.selected = NO;
    }else{
        self.openBtn.selected = YES;
    }
}


- (void)btnClick:(UIButton *)button{
    self.cellBlock(self.model, button);
}
@end
