//
//  UIColor+ChangeColor.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "UIColor+ChangeColor.h"

@implementation UIColor (ChangeColor)

+(UIColor *)colorWithHex:(NSInteger)hex
{
    return [UIColor colorWithHex:hex andAlpha:1.0];
}
+(UIColor *)colorWithHex:(NSInteger)hex andAlpha:(float)alpha
{
    return [UIColor colorWithRed:((float)((hex & 0xFF0000) >> 16))/255 green:((float)((hex & 0xFF00) >> 8))/255 blue:((float)(hex & 0xFF))/255 alpha:alpha];
}


@end
