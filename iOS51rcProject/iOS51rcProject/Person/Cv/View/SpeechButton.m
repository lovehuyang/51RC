//
//  SpeechButton.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/3.
//  Copyright © 2018年 Jerry. All rights reserved.
//  简历页面语音按钮

#import "SpeechButton.h"

@implementation SpeechButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViews];
        self.userInteractionEnabled = YES;
    }
    return self;
}
- (void)setupSubViews{
    
    UIButton *huaTongBtn = [UIButton new];
    [self addSubview:huaTongBtn];
    huaTongBtn.sd_layout
    .rightSpaceToView(self, 0)
    .centerYEqualToView(self)
    .widthIs(45)
    .heightIs(45);
    [huaTongBtn setImage:[UIImage imageNamed:@"ico_pasearch_startvoice"] forState:UIControlStateNormal];
    [huaTongBtn addTarget:self action:@selector(huaTongBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self bringSubviewToFront:huaTongBtn];
    
    
    UIImageView *tipImgView = [UIImageView new];
    [self addSubview:tipImgView];
    tipImgView.userInteractionEnabled = YES;
    
    tipImgView.sd_layout
    .rightSpaceToView(huaTongBtn, 0)
    .centerYEqualToView(huaTongBtn)
    .heightIs(35)
    .widthIs(150);
    tipImgView.image = [UIImage imageNamed:@"ico_paone_voicediglog"];
    
    
    // GCD延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [tipImgView removeFromSuperview];
        CGFloat width = self.frame.size.width - 150;
        self.frame =CGRectMake(self.frame.origin.x + self.frame.size.width - width, self.frame.origin.y, width, self.frame.size.height);
    });
}

- (void)huaTongBtnClick{
    self.speechInput();
}
@end
