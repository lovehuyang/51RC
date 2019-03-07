//
//  AssessPayAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AssessPayAlert.h"
#import "Common.h"

@interface AssessPayAlert()<UITextViewDelegate>
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *alertView;
@property (nonatomic , strong) UILabel *titleLab;
@property (nonatomic , strong) UILabel *contentLab;
@property (nonatomic , strong) UIButton *btn;

@end
@implementation AssessPayAlert

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
        self.alertView = [[UIView alloc]init];
        self.alertView.center = CGPointMake(self.center.x, self.center.y);
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 5;
        self.alertView.clipsToBounds = YES;
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .centerXEqualToView(self)
        .leftSpaceToView(self, 40)
        .rightSpaceToView(self, 40)
        .heightIs(200)
        .centerYEqualToView(self);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(5);
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    UILabel *titleLab = [UILabel new];
    [self.alertView addSubview:titleLab];
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.sd_layout
    .topSpaceToView(self.alertView, 15)
    .autoHeightRatio(0)
    .leftSpaceToView(self.alertView, 15)
    .rightSpaceToView(self.alertView, 40);
    self.titleLab = titleLab;
    
    // 关闭
    UIButton *closeBtn = [UIButton new];
    [self.alertView addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(self.alertView, 10)
    .topEqualToView(titleLab)
    .bottomEqualToView(titleLab)
    .widthEqualToHeight();
    [closeBtn setImage:[UIImage imageNamed:@"paySuccessClose"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    
    UILabel *contentLab = [UILabel new];
    [self.alertView addSubview:contentLab];
    contentLab.sd_layout
    .leftEqualToView(titleLab)
    .topSpaceToView(titleLab, 15)
    .rightSpaceToView(self.alertView, 15)
    .autoHeightRatio(0);
    contentLab.font =DEFAULTFONT;
    self.contentLab = contentLab;
    
    
    UIButton *btn = [UIButton new];
    [self.alertView addSubview:btn];
    btn.sd_layout
    .widthIs(110)
    .centerXEqualToView(self.alertView)
    .heightIs(30)
    .topSpaceToView(contentLab, 20);
    btn.backgroundColor = NAVBARCOLOR;
    btn.sd_cornerRadius = @(3);
    btn.titleLabel.font = DEFAULTFONT;
    [btn addTarget:self action:@selector(payEvent) forControlEvents:UIControlEventTouchUpInside];
    self.btn = btn;
    [self.alertView setupAutoHeightWithBottomView:btn bottomMargin:15];
}

- (void)setTitle:(NSString *)title{
    _title = title;
    self.titleLab.text = _title;
}

- (void)setContent:(NSString *)content{
    _content = content;
    self.contentLab.text = _content;
    
}

- (void)setBtnStr:(NSString *)btnStr{
    _btnStr = btnStr;
    [self.btn setTitle:_btnStr forState:UIControlStateNormal];
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

- (void)closeBtnClick{
    [self dissmiss];
}

- (void)payEvent{
    [self dissmiss];
    self.clickAssessPayBlock();
}
@end
