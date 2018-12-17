//
//  OneMinuteCVViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/26.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RCRootViewController.h"

// 页面类型
typedef enum _PageType {
    PageType_Login = 0,// 登录成功跳转
    PageType_CV = 1,// “简历”页面跳转
    PageType_JobInfo// 职位详情页面跳转
} PageType;

@interface OneMinuteCVViewController : RCRootViewController

@property (nonatomic , assign) PageType  pageType;
@property (nonatomic , copy) void (^completeOneCV)(NSString * tempStr);// 完成一分钟简历

@end
