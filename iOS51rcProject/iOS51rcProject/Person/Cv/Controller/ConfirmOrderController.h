//
//  ConfirmOrderController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RCRootViewController.h"
@class CVTopPackageModel;

@interface ConfirmOrderController : RCRootViewController
@property (nonatomic , strong) CVTopPackageModel *model;
@property (nonatomic , copy) NSString *cvMainId;// 需要置顶的简历id
@property (nonatomic , copy) NSString *orderType;// 同orderService（置顶套餐类型id）

@property (nonatomic , copy)void (^sendbackOrderName)(BOOL paySuccess, NSString *orderName);
@end
