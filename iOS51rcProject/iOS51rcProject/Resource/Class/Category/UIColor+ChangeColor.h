//
//  UIColor+ChangeColor.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ChangeColor)

+ (UIColor *) colorWithHex: (NSInteger )hex;

+(UIColor *)colorWithHex:(NSInteger)hex andAlpha:(float)alpha;

@end
