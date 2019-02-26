//
//  RCAlertView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/12.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RCAlertView.h"

@interface RCAlertView()
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *alertView;
@end

@implementation RCAlertView

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content leftBtn:(NSString *)leftBtnTitle rightBtn:(NSString *)rightBtnTitle{
    if (self = [super init]) {
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
        self.alertView = [[UIView alloc]init];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .centerXEqualToView(self)
        .leftSpaceToView(self, 40)
        .rightSpaceToView(self, 40)
        .heightIs(200)
        .centerYEqualToView(self);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(10);
        
        [self setupSubViewsWithTitle:title content:content leftBtn:leftBtnTitle rightBtn:rightBtnTitle];
    }
    return self;
}
- (void)setupSubViewsWithTitle:(NSString *)title content:(NSString *)content leftBtn:(NSString *)leftBtnTitle rightBtn:(NSString *)rightBtnTitle{
    UILabel *titleLab = [UILabel new];
    [self.alertView addSubview:titleLab];
    titleLab.sd_layout
    .leftSpaceToView(self.alertView, 0)
    .rightSpaceToView(self.alertView, 0)
    .topSpaceToView(self.alertView, 15)
    .autoHeightRatio(0);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.font = BIGGERFONT;
    titleLab.text = title;
    
    UILabel *contentLab = [UILabel new];
    [self.alertView addSubview:contentLab];
    contentLab.sd_layout
    .leftSpaceToView(self.alertView, 15)
    .rightSpaceToView(self.alertView, 15)
    .topSpaceToView(titleLab, 15)
    .autoHeightRatio(0);
    contentLab.font = DEFAULTFONT;
    contentLab.text = content;
    
    // 水平分割线
    UIView *hLineView = [UIView new];
    [self.alertView addSubview:hLineView];
    hLineView.sd_layout
    .topSpaceToView(contentLab, 15)
    .rightSpaceToView(self.alertView, 0)
    .leftSpaceToView(self.alertView, 0)
    .heightIs(1);
    hLineView.backgroundColor = SEPARATECOLOR;
    
    if (leftBtnTitle && rightBtnTitle && leftBtnTitle.length > 0 && rightBtnTitle.length > 0) {
        
        // 竖直分割线
        UIView *vLineView = [UIView new];
        [self.alertView addSubview:vLineView];
        vLineView.backgroundColor = SEPARATECOLOR;
        vLineView.sd_layout
        .topSpaceToView(hLineView, 0)
        .widthIs(1)
        .centerXEqualToView(self.alertView)
        .heightIs(40);
        
        UIButton *leftBtn = [UIButton new];
        [self.alertView addSubview:leftBtn];
        leftBtn.sd_layout
        .leftSpaceToView(self.alertView, 0)
        .rightSpaceToView(vLineView, 0)
        .topSpaceToView(hLineView, 0)
        .bottomEqualToView(vLineView);
        leftBtn.titleLabel.font = DEFAULTFONT;
        [leftBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [leftBtn setTitle:leftBtnTitle forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *rightBtn = [UIButton new];
        [self.alertView addSubview:rightBtn];
        rightBtn.sd_layout
        .leftSpaceToView(vLineView, 0)
        .rightSpaceToView(self.alertView, 0)
        .topSpaceToView(hLineView, 0)
        .bottomEqualToView(vLineView);
        rightBtn.titleLabel.font = leftBtn.titleLabel.font;
        [rightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [rightBtn setTitle:rightBtnTitle forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.alertView setupAutoHeightWithBottomView:vLineView bottomMargin:0];
    
    }else{
        
        UIButton *btn = [UIButton new];
        [self.alertView addSubview:btn];
        btn.sd_layout
        .leftSpaceToView(self.alertView, 0)
        .rightSpaceToView(self.alertView, 0)
        .heightIs(40)
        .topSpaceToView(hLineView, 0);
        btn.titleLabel.font = DEFAULTFONT;
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn setTitle:leftBtnTitle forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
         [self.alertView setupAutoHeightWithBottomView:btn bottomMargin:0];
    }
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
    
    self.alertView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss{
    [self removeFromSuperview];
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}
@end
