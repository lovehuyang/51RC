//
//  WKButton.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/6.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKButton : UIButton

- (id)initImageButtonWithFrame:(CGRect)frame image:(NSString *)image title:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color bgColor:(UIColor *)bgColor;
- (id)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color bgColor:(UIColor *)bgColor;
@end
