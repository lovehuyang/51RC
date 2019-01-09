//
//  ConfirmOrderController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/7.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "RCRootViewController.h"
@class OrderListModel;

@interface ConfirmPaymentOrderController : RCRootViewController
@property (nonatomic , copy)void (^alipayResult)(BOOL success);
@property (nonatomic , strong)OrderListModel *model;

@end
