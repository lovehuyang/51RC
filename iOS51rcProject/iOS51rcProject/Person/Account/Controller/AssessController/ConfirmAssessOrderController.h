//
//  ConfirmAssessOrderController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RCRootViewController.h"
@class AssessIndexModel;
@interface ConfirmAssessOrderController : RCRootViewController
@property (nonatomic , strong) AssessIndexModel *assessModel;

// 回调支付结果
@property (nonatomic , copy)void (^sendbackAssessType)(BOOL paySuccess, AssessIndexModel *assessModel);
@end
