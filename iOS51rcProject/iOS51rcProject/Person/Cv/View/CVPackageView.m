//
//  CVPackageView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CVPackageView.h"
#import "CVTopPackageModel.h"

@interface CVPackageView()
@property (nonatomic , strong) UILabel *disCountLab;
@property (nonatomic , strong) UIImageView *zhekouImgView;
@property (nonatomic , strong) UILabel *titleLab;
@property (nonatomic , strong) UILabel *rawPriceLab;
@property (nonatomic , strong) UILabel *nowPriceLab;
@end

@implementation CVPackageView
- (instancetype)init{
    if (self = [super init]) {
        [self setupSubViews];
    }
    return self;
}
- (void)setupSubViews{
    
    CGFloat H = SCREEN_WIDTH/2;
    
    UIView *bgView = [UIView new];
    [self addSubview:bgView];
    bgView.sd_layout
    .leftSpaceToView(self, 5)
    .rightSpaceToView(self, 5)
    .topSpaceToView(self, 0)
    .bottomSpaceToView(self, 0);
    bgView.layer.borderWidth = 1;
    bgView.layer.borderColor = UIColorWithRGBA(226, 226, 226, 1).CGColor;
    
    // 左上角角标
    UIImageView *zhekouImgView = [UIImageView new];
    [bgView addSubview:zhekouImgView];
    zhekouImgView.image = [UIImage imageNamed:@"icon_resume_top_list_zhekou"];
    self.zhekouImgView = zhekouImgView;
    
    // 折扣
    UILabel *disCountLab = [UILabel new];
    [bgView addSubview:disCountLab];
    disCountLab.font = SMALLERFONT;
    disCountLab.textColor = [UIColor whiteColor];
    self.disCountLab = disCountLab;
    
    disCountLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .topSpaceToView(bgView, 0)
    .heightIs(15);
    [disCountLab setSingleLineAutoResizeWithMaxWidth:50];
    
    zhekouImgView.sd_layout
    .leftSpaceToView(bgView, 0)
    .topSpaceToView(bgView, 0)
    .widthRatioToView(disCountLab, 1.5)
    .heightEqualToWidth();
    
    // 套餐标题
    UILabel *titleLab = [UILabel new];
    [bgView addSubview: titleLab];
    titleLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .rightSpaceToView(bgView, 0)
    .centerYIs(H/5)
    .autoHeightRatio(0);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = DEFAULTFONT;
    self.titleLab = titleLab;
    
    // 原价
    UILabel *rawPriceLab = [UILabel new];
    [bgView addSubview:rawPriceLab];
    rawPriceLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .rightSpaceToView(bgView, 0)
    .centerYIs(H/5 * 2)
    .autoHeightRatio(0);
    rawPriceLab.textAlignment = NSTextAlignmentCenter;
    rawPriceLab.font = [UIFont systemFontOfSize:DEFAULTFONTSIZE - 1];
    rawPriceLab.textColor = TEXTGRAYCOLOR;
    self.rawPriceLab = rawPriceLab;
    
    // 现价
    UILabel *nowPriceLab = [UILabel new];
    [bgView addSubview:nowPriceLab];
    nowPriceLab.sd_layout
    .leftSpaceToView(bgView, 0)
    .rightSpaceToView(bgView, 0)
    .centerYIs(H/5 * 3)
    .autoHeightRatio(0);
    nowPriceLab.textAlignment = NSTextAlignmentCenter;
    nowPriceLab.font = DEFAULTFONT;
    nowPriceLab.textColor = NAVBARCOLOR;
    self.nowPriceLab = nowPriceLab;
    
    // 购买
    UIButton *buyBtn = [UIButton new];
    [bgView addSubview:buyBtn];
    buyBtn.sd_layout
    .centerYIs(H/5 *4)
    .heightIs(25)
    .centerXEqualToView(bgView)
    .widthIs(80);
    [buyBtn setTitle:@"购买" forState:UIControlStateNormal];
    buyBtn.sd_cornerRadius = @(3);
    buyBtn.backgroundColor = UIColorFromHex(0x16A777);
    buyBtn.titleLabel.font = DEFAULTFONT;
    [buyBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self setupAutoHeightWithBottomView:buyBtn bottomMargin:15];
}

- (void)setModel:(CVTopPackageModel *)model{
    _model = model;
    self.disCountLab.text = [NSString stringWithFormat:@" %@折",_model.discount];
    self.titleLab.text = model.orderName;
    self.rawPriceLab.text = [NSString stringWithFormat:@"%@元",model.rawPrice];
    [self addDeleteLine];
    self.nowPriceLab.text = [NSString stringWithFormat:@"%@元",model.nowPrice];
}

// 添加删除线
- (void)addDeleteLine{
    NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.rawPriceLab.text];
    [attri addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, self.rawPriceLab.text.length)];
    [attri addAttribute:NSStrikethroughColorAttributeName value:TEXTGRAYCOLOR range:NSMakeRange(0,self.rawPriceLab.text.length)];
    [self.rawPriceLab setAttributedText:attri];
}

- (void)btnClick{
    self.buyBtnClickBlock(self.model);
}
@end
