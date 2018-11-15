//
//  AddShieldBtn.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AddShieldBtn.h"

@implementation AddShieldBtn

- (instancetype)init{
    if (self = [super init]) {
        self.layer.cornerRadius = 5;
        self.backgroundColor = NAVBARCOLOR;
        [self setTitle:@"+添加关键词" forState:UIControlStateNormal];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    }
    return self;
}

@end
