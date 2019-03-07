//
//  AssessPaySuccessAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessPaySuccessAlert : UIView
@property (nonatomic , copy) NSString *orderName;
@property (nonatomic , copy)void (^clickBlock)(NSString *event);
- (void)show;
- (void)dissmiss;
@end
