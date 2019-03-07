//
//  AssessPayAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessPayAlert : UIView
@property (nonatomic,copy) void(^clickAssessPayBlock)();

@property (nonatomic , copy) NSString *title;
@property (nonatomic , copy) NSString *content;
@property (nonatomic , copy) NSString *btnStr;

- (void)show;

@end
