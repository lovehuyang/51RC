//
//  LongVoiceInputController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRootViewController.h"
@interface LongVoiceInputController :RCRootViewController

@property (nonatomic , copy) NSString *detail;// 填写的内容
@property (nonatomic , copy) NSString *tipStr;// 提示文字

@property (nonatomic , copy) void (^detailContent)(NSString *inputStr);
@end
