//
//  AlertView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/16.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlertView : UIView
@property (nonatomic,copy) void(^clickButtonBlock)(UIButton * button);

- (void)initWithTitle:(NSString *)title content:(NSString *)contentStr btnTitleArr :(NSArray *)btnTitleArr canDismiss:(BOOL )canDismiss;
- (void)show:(UIView *)view;
- (void)dissmiss;

@end
