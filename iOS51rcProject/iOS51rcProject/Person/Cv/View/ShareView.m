//
//  ShareView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/2.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ShareView.h"
static CGFloat const H = 125;

@interface ShareView()


@property (nonatomic , strong) UIView *bgView;
@property (nonatomic , strong) UIView *shareView;
@end
@implementation ShareView

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
    UILabel *titleLab = [UILabel new];
    [self addSubview:titleLab];
    titleLab.sd_layout
    .leftEqualToView(self.shareView)
    .rightEqualToView(self.shareView)
    .bottomSpaceToView(self.shareView, 0)
    .heightIs(50);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor whiteColor];
    [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGESTFONTSIZE]];
    NSString *titleStr = @"分享到朋友圈返回即可领取代金券";
    NSRange range = [titleStr rangeOfString:@"领取代金券"];
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc]initWithString:titleStr];
    [attStr addAttribute:NSForegroundColorAttributeName value:[UIColor yellowColor] range:range];
    titleLab.attributedText = attStr;
    
    UIButton *shareBtn = [UIButton new];
    [self.shareView addSubview:shareBtn];
    shareBtn.sd_layout
    .topSpaceToView(self.shareView, 20)
    .centerXEqualToView(self.shareView)
    .bottomSpaceToView(self.shareView, 20)
    .leftSpaceToView(self.shareView, 40)
    .rightSpaceToView(self.shareView, 40);
    
    shareBtn.imageView.sd_layout
    .topSpaceToView(shareBtn, 0)
    .widthIs(45)
    .heightEqualToWidth()
    .centerXEqualToView(shareBtn);
    [shareBtn setImage:[UIImage imageNamed:@"pengyouquan"] forState:UIControlStateNormal];
    
    shareBtn.titleLabel.sd_layout
    .topSpaceToView(shareBtn.imageView, 10)
    .heightIs(30)
    .centerXEqualToView(shareBtn);
    [shareBtn.titleLabel setSingleLineAutoResizeWithMaxWidth:200];
    [shareBtn setTitle:@"微信朋友圈" forState:UIControlStateNormal];
    [shareBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(btnCLick) forControlEvents:UIControlEventTouchUpInside];
    shareBtn.titleLabel.font = BIGGERFONT;
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

- (void)btnCLick{
    [self dissmiss];
    self.shareBlock();
}
@end
