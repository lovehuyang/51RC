//
//  RCAlertView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/11.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RCAlertView : UIView

@property (nonatomic , copy) void(^clickBlock)(UIButton *button);

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content leftBtn:(NSString *)leftBtnTitle rightBtn:(NSString *)rightBtnTitle;
- (void)show;
- (void)dissmiss;
@end
