//
//  SpeakBtn.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/4.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "SpeakBtn.h"

#define TITLE_HEIGHT 20

@implementation SpeakBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = SMALLERFONT;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return self;
}

//重写方法
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGFloat imageY = TITLE_HEIGHT;
    CGFloat imageW = contentRect.size.height - TITLE_HEIGHT;
    CGFloat imageH = imageW;
    CGFloat imageX = contentRect.size.width/2 - imageW/2;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGFloat titleY = 0;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = TITLE_HEIGHT;
    CGFloat titleX = 0;
    return CGRectMake(titleX, titleY, titleW, titleH);
}
@end
