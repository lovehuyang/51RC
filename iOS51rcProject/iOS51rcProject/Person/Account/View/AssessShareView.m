//
//  AssessShareView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AssessShareView.h"
static CGFloat const H = 125;
@interface AssessShareView()
@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *shareView;
@end

@implementation AssessShareView

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
        self.shareView = [[UIView alloc]init];
        self.shareView.center = CGPointMake(self.center.x, self.center.y);
        self.shareView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.shareView];
        self.shareView.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .heightIs(H)
        .bottomSpaceToView(self, -H - 50);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissmiss)];
        [self.bgView addGestureRecognizer:tap];
        [self setupSubViews];
    }
    return self;
}
- (void)setupSubViews{
    
    CGFloat w = SCREEN_WIDTH/3;
    
    NSArray *imgArr = @[@"AssessWechat",@"pengyouquan",@"AssessShoucang"];
    NSArray *titleArr = @[@"微信好友",@"微信朋友圈",@"微信收藏"];
    for (int i = 0; i < 3; i ++) {
    
        UIButton *shareBtn = [UIButton new];
        [self.shareView addSubview:shareBtn];
        shareBtn.sd_layout
        .topSpaceToView(self.shareView, 20)
        .centerXIs(w/2 + w *i)
        .widthIs(w)
        .heightEqualToWidth();
        shareBtn.imageView.sd_layout
        .topSpaceToView(shareBtn, 0)
        .widthIs(45)
        .heightEqualToWidth()
        .centerXEqualToView(shareBtn);
        [shareBtn setImage:[UIImage imageNamed:imgArr[i]] forState:UIControlStateNormal];
        
        shareBtn.titleLabel.sd_layout
        .topSpaceToView(shareBtn.imageView, 10)
        .heightIs(30)
        .centerXEqualToView(shareBtn);
        [shareBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:200];
        [shareBtn setTitle:titleArr[i] forState:UIControlStateNormal];
        [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        shareBtn.titleLabel.font = BIGGERFONT;
        shareBtn.tag = 100 + i;
        [shareBtn addTarget:self action:@selector(shareBTnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
    self.shareView.sd_layout
    .bottomSpaceToView(self, 0);
    
    [UIView animateWithDuration:.3 animations:^{
        [self.shareView updateLayout];
    } completion:^(BOOL finished) {
    }];
}

- (void)dissmiss {
    
    self.shareView.sd_layout
    .bottomSpaceToView(self, -H - 50);
    [UIView animateWithDuration:.3 animations:^{
        [self.shareView updateLayout];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)shareBTnClick:(UIButton *)button{
    [self dissmiss];
    self.shareBlock(button);
}

@end
