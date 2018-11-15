//
//  BarButtonItem.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "BarButtonItem.h"

@implementation BarButtonItem
- (instancetype)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action{
    if (self = [super initWithTitle:title style:style target:target action:action]) {
        [self setTintColor:[UIColor whiteColor]];
    }
    return self;
}
@end
