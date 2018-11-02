//
//  NavBar.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/2.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NavBar : UIView
- (instancetype)initWithTitle:(NSString *)title leftItem:(NSString *)imgName ;
@property (nonatomic , copy)void (^leftItemEvent)();
@end
