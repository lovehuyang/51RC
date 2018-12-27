//
//  PullDownMenu.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/13.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PullDownMenu : UIView
- (instancetype)initWithFrame:(CGRect)frame controller:(UIViewController *)controller Title:(NSArray *)titleArr replyRate:(NSString *)replyRate;

@property (nonatomic , copy) NSArray *titleArr;
@property (nonatomic , copy) NSString *replyRate;
@property (nonatomic , copy)NSString *titleStr;

@property (nonatomic , copy) void (^menuClick)(NSString *title);

@end
