//
//  BuyTopServiceSuccessAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/8.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BuyTopServiceSuccessAlert : UIView
@property (nonatomic , copy) NSString *orderName;
@property (nonatomic , copy)void (^clickBlock)(UIButton *btn);
- (void)show;
- (void)dissmiss;

@end
