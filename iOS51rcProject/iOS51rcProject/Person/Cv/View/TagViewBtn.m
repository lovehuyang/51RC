//
//  TagViewBtn.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "TagViewBtn.h"
#define IMAGEW 10
#define IMAGEH 10

@implementation TagViewBtn

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.titleLabel.font = DEFAULTFONT;
        self.backgroundColor = [UIColor clearColor];
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self setImage:[UIImage imageNamed:@"guanbi_orange"] forState:UIControlStateNormal];
    }
    return self;
}

//重写方法
-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    
    CGFloat imageY = self.frame.size.height/2 - IMAGEW/2;
    CGFloat imageW = IMAGEW;
    CGFloat imageH = IMAGEH;
    CGFloat imageX = contentRect.size.width - imageW - 5;
    return CGRectMake(imageX, imageY, imageW, imageH);
}

-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    
    CGFloat titleY = 0;
    CGFloat titleW = contentRect.size.width - IMAGEW;
    CGFloat titleH = contentRect.size.height;
    CGFloat titleX = 5;
    return CGRectMake(titleX, titleY, titleW, titleH);
}

@end
