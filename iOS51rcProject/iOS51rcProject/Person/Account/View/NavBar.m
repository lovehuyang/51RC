//
//  NavBar.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/2.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "NavBar.h"

@implementation NavBar

- (instancetype)initWithTitle:(NSString *)title leftItem:(NSString *)imgName{

    if (self = [super init]) {
        self.backgroundColor = NAVBARCOLOR;
        [self setupSubViews:title leftItem:imgName];
    }
    return self;
}

- (void)setupSubViews:(NSString *)title leftItem:(NSString *)imgName{
    if (imgName.length) {
        UIButton *leftBtn = [UIButton new];
        [self addSubview:leftBtn];
        leftBtn.sd_layout
        .leftSpaceToView(self, 5)
        .bottomEqualToView(self)
        .widthIs(30)
        .heightIs(44);
        [leftBtn setImage:[UIImage imageNamed:imgName] forState:UIControlStateNormal];
        [leftBtn addTarget:self action:@selector(leftItemClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    if (!title.length) {
        return;
    }
    UILabel *titleLab = [UILabel new];
    [self addSubview:titleLab];
    titleLab.sd_layout
    .centerXEqualToView(self)
    .heightIs(44)
    .bottomEqualToView(self)
    .widthIs(80);
    titleLab.text = title;
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = [UIColor whiteColor];
}

- (void)leftItemClick{
    self.leftItemEvent();
}
@end
