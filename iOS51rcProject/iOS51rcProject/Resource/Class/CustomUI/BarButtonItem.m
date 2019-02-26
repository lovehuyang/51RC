//
//  BarButtonItem.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/15.
//  Copyright © 2019年 Jerry. All rights reserved.
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
