//
//  RedPacketView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/2.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RedPacketView.h"

@interface RedPacketView()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *redPacketView;// 红包
@property (nonatomic , strong) UILabel *moneyLab;// 金额的lable
@end

@implementation RedPacketView


- (instancetype)init{
    self = [super init];
    if (self) {
        
        self.bgView = [UIView new];
        [self addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.5;
        self.bgView.userInteractionEnabled = YES;
        
        //创建alertView
        self.redPacketView = [[UIView alloc]init];
        self.redPacketView.center = CGPointMake(self.center.x, self.center.y);
        self.redPacketView.backgroundColor = UIColorFromHex(0xFF5A66);
        self.redPacketView.sd_cornerRadius = @(5);
        [self addSubview:self.redPacketView];
        self.redPacketView.sd_layout
        .heightIs(290)
        .autoWidthRatio(0.8)
        .centerXEqualToView(self)
        .centerYEqualToView(self);
        
        // 关闭按钮
        UIButton *closeBtn = [UIButton new];
        [self addSubview:closeBtn];
        closeBtn.sd_layout
        .leftSpaceToView(self.redPacketView, 0)
        .bottomSpaceToView(self.redPacketView, 0)
        .widthIs(30)
        .heightEqualToWidth();
        [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
        [closeBtn setImage:[UIImage imageNamed:@"p_registerClose"] forState:UIControlStateNormal];
        closeBtn.sd_cornerRadius = @(15);
        closeBtn.backgroundColor = UIColorFromHex(0xFF5A66);
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    UILabel *tipLab = [UILabel new];
    [self.redPacketView addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(self.redPacketView, 0)
    .rightSpaceToView(self.redPacketView, 0)
    .centerYEqualToView(self.redPacketView)
    .autoHeightRatio(0);
    tipLab.text = @"无门槛代金券1张";
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.textColor = [UIColor whiteColor];
    tipLab.font = DEFAULTFONT;
    
    
    self.moneyLab = [UILabel new];
    [self.redPacketView addSubview:self.moneyLab];
    self.moneyLab.sd_layout
    .leftSpaceToView(self.redPacketView, 0)
    .rightSpaceToView(self.redPacketView, 0)
    .bottomSpaceToView(tipLab, 30)
    .autoHeightRatio(0);
    self.moneyLab.textAlignment = NSTextAlignmentCenter;
    self.moneyLab.textColor = [UIColor whiteColor];
    self.moneyLab.font = [UIFont boldSystemFontOfSize:40];
    
    UILabel *luckyLab = [UILabel new];
    [self.redPacketView addSubview:luckyLab];
    luckyLab.sd_layout
    .leftSpaceToView(self.redPacketView, 0)
    .rightSpaceToView(self.redPacketView, 0)
    .topSpaceToView(self.redPacketView, 0)
    .bottomSpaceToView(self.moneyLab, 0);
    luckyLab.textAlignment = NSTextAlignmentCenter;
    luckyLab.text = @"运气不错";
    luckyLab.font = tipLab.font;
    luckyLab.textColor = UIColorFromHex(0xF9E433);
    
    UILabel *explainLab = [UILabel new];
    [self.redPacketView addSubview:explainLab];
    explainLab.sd_layout
    .leftSpaceToView(self.redPacketView, 0)
    .rightSpaceToView(self.redPacketView, 0)
    .bottomSpaceToView(self.redPacketView, 45)
    .autoHeightRatio(0);
    explainLab.textAlignment = NSTextAlignmentCenter;
    explainLab.textColor = luckyLab.textColor;
    explainLab.font = luckyLab.font;
    explainLab.text = @"购买简历置顶时,自动使用代金券";
}

- (void)setMoney:(NSString *)money{
    _money = money;
    self.moneyLab.text = [NSString stringWithFormat:@"%@元",money];
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.redPacketView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.redPacketView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss {
    
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
