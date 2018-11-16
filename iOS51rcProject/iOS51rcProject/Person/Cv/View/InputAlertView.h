//
//  InputAlertView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/16.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputAlertView : UIView

@property (nonatomic,copy) void(^clickButtonBlock)(UIButton * button,NSString *inputText);

- (void)initWithTitle:(NSString *)title content:(NSString *)contentStr btnTitleArr :(NSArray *)btnTitleArr canDismiss:(BOOL )canDismiss;
- (void)show:(UIView *)view;
- (void)dissmiss;

@end
