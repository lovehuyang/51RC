//
//  OnMinuteSingleCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OneMinuteModel;

@interface OnMinuteSingleCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(id)data indexPath:(NSIndexPath *)indexPath viewController:(UIViewController *)vc;

// 点击cell的事件
@property (nonatomic , copy) void (^cellDidSelect)(UITextField *textField);
// 点击获取验证码的事件
@property (nonatomic , copy) void (^getMobileVerifyCode)();

@end
