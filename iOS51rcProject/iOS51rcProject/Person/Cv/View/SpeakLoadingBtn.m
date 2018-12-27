//
//  SpeakLoadingBtn.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "SpeakLoadingBtn.h"
@interface SpeakLoadingBtn()
@property (nonatomic , strong) UIButton *speakBtn;
@property (nonatomic , strong) UILabel *tipLab;
@property (nonatomic , strong) UIImageView *leftImg;
@property (nonatomic , strong) UIImageView *rightImg;
@end

@implementation SpeakLoadingBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self setupSubView];
    }
    return self;
}
- (void)setupSubView{
    _tipLab = [UILabel new];
    [self addSubview:_tipLab];
    _tipLab.sd_layout
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 0)
    .heightIs(20)
    .topSpaceToView(self, 0);
    _tipLab.textAlignment = NSTextAlignmentCenter;
    _tipLab.text = @"点击说话";
    _tipLab.font =  DEFAULTFONT;
    _tipLab.textColor = NAVBARCOLOR;
    
    // 说话按钮
    _speakBtn = [UIButton new];
    [self addSubview:_speakBtn];
    _speakBtn.sd_layout
    .centerXEqualToView(_tipLab)
    .topSpaceToView(_tipLab, 0)
    .widthIs(40*1.2)// 1.1575
    .heightIs(46.3*1.2);
    [_speakBtn setImage:[UIImage imageNamed:@"ico_cvlist_startvoice"] forState:UIControlStateNormal];
    [_speakBtn setImage:[UIImage imageNamed:@"ico_cvlist_stopvoice"] forState:UIControlStateSelected];
    [_speakBtn addTarget:self action:@selector(speakBtnClick) forControlEvents:UIControlEventTouchUpInside];
    _speakBtn.selected = NO;
    
    // 左侧loading
    _leftImg = [UIImageView new];
    [self addSubview:_leftImg];
    _leftImg.sd_layout
    .rightSpaceToView(_speakBtn, 5)
    .centerYIs(42.5*1.2)
    .widthIs(32)
    .heightIs(8);
    NSMutableArray *leftImgArr = [NSMutableArray array];
    for (int i = 0; i <6; i ++) {
        NSString *imgName = [NSString stringWithFormat:@"voice_loadingleft_%d",i+1];
        [leftImgArr addObject:[UIImage imageNamed:imgName]];
    }
    _leftImg.animationImages = leftImgArr;
    _leftImg.animationDuration = 1.5;
    _leftImg.animationRepeatCount = 0;
    
    // 右侧loading
    _rightImg = [UIImageView new];
    [self addSubview:_rightImg];
    _rightImg.sd_layout
    .leftSpaceToView(_speakBtn, 5)
    .centerYEqualToView(_leftImg)
    .widthRatioToView(_leftImg, 1)
    .heightRatioToView(_leftImg, 1);
    
    NSMutableArray *rightImgArr = [NSMutableArray array];
    for (int i = 0; i <6; i ++) {
        NSString *imgName = [NSString stringWithFormat:@"voice_loadingright_%d",i+1];
        [rightImgArr addObject:[UIImage imageNamed:imgName]];
    }
    _rightImg.animationImages = rightImgArr;
    _rightImg.animationDuration = 1.5;
    _rightImg.animationRepeatCount = 0;
}

#pragma mark - 点击说话
- (void)speakBtnClick{
    self.speakBtn.selected = !self.speakBtn.selected;
    if(self.speakBtn.selected){// 说话中
        self.tipLab.hidden = YES;
        self.speakBtn.sd_layout
        .topSpaceToView(_tipLab, 6.3*1.2)
        .widthIs(40*1.2)
        .heightIs(40*1.2);
        [_leftImg startAnimating];
        [_rightImg startAnimating];
        self.speakStatus(YES);
    }else{// 暂停中
        self.tipLab.hidden = NO;
        self.tipLab.text = @"点击继续说话";
        self.speakBtn.sd_layout
        .topSpaceToView(_tipLab, 0)
        .widthIs(40*1.2)
        .heightIs(46.3*1.2);
        [_leftImg stopAnimating];
        [_rightImg stopAnimating];
        self.speakStatus(NO);
    }
}
@end
