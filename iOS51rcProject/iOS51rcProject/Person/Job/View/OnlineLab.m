//
//  OnlineLab.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "OnlineLab.h"

@implementation OnlineLab

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.text = @"在线";
        self.textColor = [UIColor whiteColor];
        self.backgroundColor = UIColorFromHex(0x16A777);
        self.layer.cornerRadius = self.frame.size.height/2;
        self.layer.masksToBounds = YES;
        self.font = [UIFont systemFontOfSize:SMALLERFONTSIZE - 2];
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

@end
