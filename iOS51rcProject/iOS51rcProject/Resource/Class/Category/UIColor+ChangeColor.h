//
//  UIColor+ChangeColor.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (ChangeColor)

+ (UIColor *) colorWithHex: (NSInteger )hex;

+ (UIColor *)colorWithHex:(NSInteger)hex andAlpha:(float)alpha;

@end
