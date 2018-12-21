//
//  SelectCvAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "SelectCvAlert.h"

@interface SelectCvAlert()

@property (nonatomic , strong) UIView *bgView;// 全局背景
@property (nonatomic , strong) UIView *alertView;// alerview

@end

@implementation SelectCvAlert

- (instancetype)init{
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
        
        //创建alertView
        self.alertView = [[UIView alloc]init];
        self.alertView.center = CGPointMake(self.center.x, self.center.y);
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 5;
        self.alertView.clipsToBounds = YES;
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .leftSpaceToView(self, 40)
        .rightSpaceToView(self, 40)
        .heightIs(200)
        .centerYEqualToView(self);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(5);
        
        [self setupAllsubviews];
    }
    return self;
}


#pragma mark - 初始化子控件
- (void)setupAllsubviews{
    
    UILabel *titleLab = [UILabel new];
    [self.alertView addSubview:titleLab];
    titleLab.text = @"申请成功！";
    titleLab.sd_layout
    .centerXEqualToView(self.alertView)
    .topSpaceToView(self.alertView, 20)
    .heightIs(30);
    [titleLab setSingleLineAutoResizeWithMaxWidth:200];
    //    titleLab.backgroundColor = [UIColor redColor];
    
    UIImageView *succeedImg = [UIImageView new];
    [self.alertView addSubview:succeedImg];
    succeedImg.sd_layout
    .rightSpaceToView(titleLab, 10)
    .centerYEqualToView(titleLab)
    .widthIs(28)
    .heightEqualToWidth();
    succeedImg.image = [UIImage imageNamed:@"job_applysuccess"];
    
    // 分割线
    UILabel *lineLab = [UILabel new];
    [self.alertView addSubview:lineLab];
    lineLab.sd_layout
    .leftSpaceToView(self.alertView, 10)
    .rightSpaceToView(self.alertView, 10)
    .topSpaceToView(succeedImg, 10)
    .heightIs(1);
    lineLab.backgroundColor = SEPARATECOLOR;
    
    // 您可以更换其他简历：
    UILabel *tipLab = [UILabel new];
    [self.alertView addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(self.alertView, 10)
    .topSpaceToView(lineLab, 20)
    .rightSpaceToView(self.alertView, 10)
    .heightIs(20);
    tipLab.text = @"您可以更换其他简历：";
    tipLab.font = DEFAULTFONT;
    
    CGFloat btn_H = 25;
    for (int i = 0; i < 3; i ++) {
        
        UIImageView *imgView = [UIImageView new];
//        [self.alertView addSubview:imgView];
//        imgView.sd_layout
//        .leftSpaceToView(self.alertView, 25)
//        .topSpaceToView(<#id viewOrViewsArray#>, <#CGFloat value#>)
//        
//        UIButton *btn = [UIButton new];
//        btn.backgroundColor = [UIColor redColor];
//        [self.alertView addSubview:btn];
//        btn.sd_layout
//        .leftSpaceToView(self.alertView, 20)
//        .topSpaceToView(tipLab, btn_H *i);
//        [btn setTitle:@"dffffff" forState:UIControlStateNormal];
//        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn setupAutoSizeWithHorizontalPadding:10 buttonHeight:btn_H];
//        [btn setImage:[UIImage imageNamed:@"img_checksmall1"] forState:UIControlStateSelected];
//        [btn setImage:[UIImage imageNamed:@"img_checksmall2"] forState:UIControlStateNormal];
//        btn.selected = YES;
    }
    
    
    CGFloat btn_W = (SCREEN_WIDTH - 80 - 40 - 20)/2;
    UIButton *acceptBtn = [UIButton new];
    [self.alertView addSubview:acceptBtn];
    acceptBtn.sd_layout
    .rightSpaceToView(self.alertView, 20)
    .heightIs(35)
    .widthIs(btn_W)
    .topSpaceToView(tipLab, 25);
    acceptBtn.backgroundColor = NAVBARCOLOR;
    acceptBtn.sd_cornerRadius = @(5);
    [acceptBtn setTitle:@"马上去完善" forState:UIControlStateNormal];
    acceptBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    acceptBtn.tag = 100;
    [acceptBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *rejectBtn = [UIButton new];
    [self.alertView addSubview:rejectBtn];
    rejectBtn.sd_layout
    .heightRatioToView(acceptBtn, 1)
    .leftSpaceToView(self.alertView, 20)
    .topEqualToView(acceptBtn)
    .widthRatioToView(acceptBtn, 1);
    rejectBtn.sd_cornerRadius = @(5);
    [rejectBtn setTitle:@"放弃机会" forState:UIControlStateNormal];
    rejectBtn.layer.borderWidth = 1;
    rejectBtn.layer.borderColor = SEPARATECOLOR.CGColor;
    [rejectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rejectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    [rejectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.alertView setupAutoHeightWithBottomView:rejectBtn bottomMargin:20];
    
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

- (void)dissmiss {
    
    [UIView animateWithDuration:.3 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {// 去完善
        self.completeInformation();
    }
    
    [self dissmiss];
}

@end
