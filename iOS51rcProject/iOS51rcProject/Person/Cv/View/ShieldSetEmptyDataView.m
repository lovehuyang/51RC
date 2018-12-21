//
//  ShieldSetEmptyDataView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "ShieldSetEmptyDataView.h"
#import "AddShieldBtn.h"

@implementation ShieldSetEmptyDataView

- (instancetype)init{
    if (self = [super init]) {
        [self setupUI];
    }
    return self;
}

#pragma mark - 数据为空的页面
- (void)setupUI{
    UILabel *tipLab = [UILabel new];
    [self addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(self, 50)
    .rightSpaceToView(self, 50)
    .topSpaceToView(self, 60)
    .autoHeightRatio(0);
    [tipLab setTextAlignment:NSTextAlignmentCenter];
    tipLab.textColor = TEXTGRAYCOLOR;
    tipLab.font = DEFAULTFONT;
    tipLab.text = @"您目前还没有设置关键词哦~\n设置后，包含您关键词的企业\n就不能主动查看您的简历啦！";
    
    UIImageView *imgView = [UIImageView new];
    [self addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self, 50)
    .rightSpaceToView(self, 50)
    .topSpaceToView(tipLab, 20)
    .heightIs(120);
    [imgView setImage:[UIImage imageNamed:@"img_frog"]];
    
    AddShieldBtn *btn = [AddShieldBtn new];
    [self addSubview:btn];
    btn.sd_layout
    .leftEqualToView(imgView)
    .rightEqualToView(imgView)
    .heightIs(35)
    .topSpaceToView(imgView, 10);
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnClick{
    self.addEvent();
}
@end
