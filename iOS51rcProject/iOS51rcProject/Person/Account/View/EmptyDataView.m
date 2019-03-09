//
//  EmptyDataView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/7.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "EmptyDataView.h"

@interface EmptyDataView()
@property (nonatomic , strong) UILabel *tipLab;
@end

@implementation EmptyDataView

- (instancetype)initWithTip:(NSString *)tipStr{
    if (self = [super init]) {
        self.userInteractionEnabled = YES;
        UIImageView *imgView = [UIImageView new];
        [self addSubview:imgView];
        imgView.sd_layout
        .centerXEqualToView(self)
        .centerYEqualToView(self)
        .widthIs(120)
        .autoHeightRatio(0.61);
        imgView.image = [UIImage imageNamed:@"pic_cvview_frog2"];
        
        self.tipLab = [UILabel new];
        [self addSubview:self.tipLab];
        self.tipLab.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(imgView, 10)
        .autoHeightRatio(0);
        self.tipLab.textAlignment = NSTextAlignmentCenter;
        self.tipLab.font = DEFAULTFONT;
        self.tipLab.text = tipStr;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
        [self addGestureRecognizer:tap];
        
    }
    return self;
}

- (void)tapEvent{
    self.emptyDataTouch();
}
@end
