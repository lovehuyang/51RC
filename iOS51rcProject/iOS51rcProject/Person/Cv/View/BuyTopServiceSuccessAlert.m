//
//  BuyTopServiceSuccessAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/8.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "BuyTopServiceSuccessAlert.h"

@interface BuyTopServiceSuccessAlert()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *successAlert;
@property (nonatomic , strong) UIImageView *successView;
@property (nonatomic , strong) UILabel *cvNameLab;
@end

@implementation BuyTopServiceSuccessAlert
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
        self.userInteractionEnabled = YES;
        
        //创建alertView
        self.successAlert = [[UIImageView alloc]init];
        [self addSubview:self.successAlert];
        self.successAlert.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .centerYEqualToView(self)
        .heightEqualToWidth();
        self.successAlert.image = [UIImage imageNamed:@"bg_resume_top_success"];
        self.successAlert.userInteractionEnabled = YES;
        
        
        self.successView = [UIImageView new];
        [self.successAlert addSubview:self.successView];
        self.successView.sd_layout
        .centerXEqualToView(self.successAlert)
        .centerYEqualToView(self.successAlert)
        .widthIs(260)
        .heightEqualToWidth();
        self.successView.image = [UIImage imageNamed:@"bg_resume_top_success_white"];
        self.successView.userInteractionEnabled = YES;
        [self setupAllSubViews];
    }
    return self;
}
- (void)setOrderName:(NSString *)orderName{
    _orderName = orderName;
    self.cvNameLab.text = _orderName;
}
- (void)setupAllSubViews{
    
    // 关闭按钮
    UIButton *closeBtn = [UIButton new];
    [self.successView addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(self.successView, 0)
    .topSpaceToView(self.successView, 0)
    .widthIs(30)
    .heightEqualToWidth();
    closeBtn.sd_cornerRadius = @(15);
    closeBtn.backgroundColor = SEPARATECOLOR;
    [closeBtn setImage:[UIImage imageNamed:@"icon_pay_success_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
    
    // 喜欢的职位还需要主动申请哦~
    UILabel *tipLab = [UILabel new];
    [self.successView addSubview:tipLab];
    tipLab.textAlignment = NSTextAlignmentCenter;
    tipLab.sd_layout
    .leftSpaceToView(self.successView, 0)
    .rightSpaceToView(self.successView, 0)
    .centerYEqualToView(self.successView)
    .autoHeightRatio(0);
    tipLab.text = @"喜欢的职位还需要主动申请哦~";
    tipLab.font = SMALLERFONT;
    
    // 简历名
    UILabel *cvNameLab = [UILabel new];
    [self.successView addSubview:cvNameLab];
    cvNameLab.textAlignment = NSTextAlignmentCenter;
    cvNameLab.sd_layout
    .leftSpaceToView(self.successView, 0)
    .rightSpaceToView(self.successView, 0)
    .bottomSpaceToView(tipLab, 25)
    .autoHeightRatio(0);
    [cvNameLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
    cvNameLab.textColor = UIColorFromHex(0xE45D68);
    self.cvNameLab = cvNameLab;
    
    // 恭喜，您已开通
    UILabel *congratulationLab = [UILabel new];
    [self.successView addSubview:congratulationLab];
    congratulationLab.textAlignment = NSTextAlignmentCenter;
    congratulationLab.sd_layout
    .leftSpaceToView(self.successView, 0)
    .rightSpaceToView(self.successView, 0)
    .bottomSpaceToView(cvNameLab, 15)
    .autoHeightRatio(0);
    congratulationLab.text = @"恭喜，您已成功开通";
    congratulationLab.font = BIGGERFONT;
    congratulationLab.textColor = cvNameLab.textColor;
    
    
    UIImageView *leftImgView = [UIImageView new];
    [self.successView addSubview:leftImgView];
    leftImgView.sd_layout
    .rightSpaceToView(self.successView, 125)
    .leftSpaceToView(self.successView, -10)
    .heightIs(45)
    .bottomSpaceToView(self.successView, 40);
    leftImgView.image = [UIImage imageNamed:@"bg_resume_top_success_search"];
    leftImgView.userInteractionEnabled = YES;
    
    UIImageView *rightImgView = [UIImageView new];
    [self.successView addSubview:rightImgView];
    rightImgView.sd_layout
    .leftSpaceToView(leftImgView, 0)
    .rightSpaceToView(self.successView, -10)
    .heightRatioToView(leftImgView, 1)
    .bottomEqualToView(leftImgView);
    rightImgView.image = [UIImage imageNamed:@"bg_resume_top_success_order"];
    rightImgView.userInteractionEnabled = YES;
    
    
    UIButton *leftBtn = [UIButton new];
    [leftImgView addSubview:leftBtn];
    leftBtn.sd_layout
    .rightSpaceToView(leftImgView, 0)
    .topSpaceToView(leftImgView, 0)
    .heightRatioToView(leftImgView, 0.81)
    .widthRatioToView(leftImgView, 0.66);
    [leftBtn setTitle:@"搜索职位" forState:UIControlStateNormal];
    leftBtn.titleLabel.font = DEFAULTFONT;
    leftBtn.tag = 100;
    [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *rightBtn = [UIButton new];
    [rightImgView addSubview:rightBtn];
    rightBtn.sd_layout
    .leftSpaceToView(rightImgView, 0)
    .topSpaceToView(rightImgView, 0)
    .heightRatioToView(rightImgView, 0.81)
    .widthRatioToView(rightImgView, 0.66);
    [rightBtn setTitle:@"查看订单" forState:UIControlStateNormal];
    rightBtn.titleLabel.font = leftBtn.titleLabel.font;
    rightBtn.tag = 101;
    [rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick:(UIButton *)btn{
    [self dissmiss];
    
    self.clickBlock(btn);
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.successView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.successView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss {
    [self removeFromSuperview];
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
