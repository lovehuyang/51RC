//
//  AssessPaySuccessAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AssessPaySuccessAlert.h"
@interface AssessPaySuccessAlert()

@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIImageView *successAlert;
@property (nonatomic , strong) UILabel *cvNameLab;
@end
@implementation AssessPaySuccessAlert

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
        .autoHeightRatio(0.722);
        self.successAlert.image = [UIImage imageNamed:@"ico_talent_pay_success_bg"];
        self.successAlert.userInteractionEnabled = YES;
        
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
    [self.successAlert addSubview:closeBtn];
    closeBtn.sd_layout
    .leftSpaceToView(self.successAlert, SCREEN_WIDTH * 0.76)
    .topSpaceToView(self.successAlert, 0)
    .widthIs(30)
    .heightEqualToWidth();
    closeBtn.sd_cornerRadius = @(15);
    closeBtn.backgroundColor = SEPARATECOLOR;
    [closeBtn setImage:[UIImage imageNamed:@"icon_pay_success_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];

    
    UIImageView *imgView = [UIImageView new];
    [self.successAlert addSubview:imgView];
    imgView.sd_layout
    .centerXEqualToView(self.successAlert)
    .centerYEqualToView(self.successAlert)
    .widthIs(SCREEN_WIDTH * 0.611)
    .heightIs(40);
    imgView.image = [UIImage imageNamed:@"ico_talent_pay_success_text"];
    imgView.userInteractionEnabled = YES;
    
    // 开始测评
    UILabel *startLab = [UILabel new];
    [imgView addSubview:startLab];
    startLab.sd_layout
    .leftSpaceToView(imgView, 0)
    .rightSpaceToView(imgView, 0)
    .topSpaceToView(imgView, 0)
    .heightIs(30);
    startLab.textColor = [UIColor whiteColor];
    startLab.text = @"开始测评";
    startLab.userInteractionEnabled = YES;
    startLab.textAlignment = NSTextAlignmentCenter;
    startLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(startAssessIndex)];
    [startLab addGestureRecognizer:tap];

    // 查看订单
    UIButton *orderBtn = [UIButton new];
    [self.successAlert addSubview:orderBtn];
    orderBtn.sd_layout
    .topSpaceToView(imgView, -5)
    .widthIs(80)
    .centerXEqualToView(imgView)
    .heightIs(30);
    orderBtn.titleLabel.font = startLab.font;
    orderBtn.tag = 101;
    [orderBtn addTarget:self action:@selector(checkOrder) forControlEvents:UIControlEventTouchUpInside];
    NSMutableAttributedString *title = [[NSMutableAttributedString alloc] initWithString:@"查看订单"];
    NSRange titleRange = {0, [title length]};
    [title addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:titleRange];
    [orderBtn setAttributedTitle:title forState:UIControlStateNormal];
    [orderBtn setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
    
    
    UILabel *titleLab2 = [UILabel new];
    [self.successAlert addSubview:titleLab2];
    titleLab2.text = @"现在可以开始测评了！";
    titleLab2.font = BIGGERFONT;
    titleLab2.sd_layout
    .centerXEqualToView(imgView)
    .bottomSpaceToView(imgView, 20)
    .autoHeightRatio(0);
    [titleLab2 setSingleLineAutoResizeWithMaxWidth:200];
    titleLab2.textAlignment = NSTextAlignmentCenter;
    
    UILabel *titleLab1 = [UILabel new];
    [self.successAlert addSubview:titleLab1];
    titleLab1.text = @"您已付款成功，";
    titleLab1.font = titleLab2.font;
    titleLab1.sd_layout
    .centerXEqualToView(imgView)
    .bottomSpaceToView(titleLab2, 5)
    .autoHeightRatio(0);
    [titleLab1 setSingleLineAutoResizeWithMaxWidth:200];
    titleLab1.textAlignment = NSTextAlignmentCenter;
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.successAlert.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.successAlert.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
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


#pragma mark - 开始测评
- (void)startAssessIndex{
    self.clickBlock(@"开始测评");
    [self dissmiss];
}

#pragma mark - 查看订单
- (void)checkOrder{
    self.clickBlock(@"查看订单");
    [self dissmiss];
}
@end
