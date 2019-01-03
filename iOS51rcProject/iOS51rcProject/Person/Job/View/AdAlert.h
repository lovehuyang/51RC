//
//  AdAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//  广告弹窗

#import <UIKit/UIKit.h>

@interface AdAlert : UIViewController

-(instancetype)initWithData:(NSDictionary *)data;
- (void)show:(UIViewController *)vc;

@end
