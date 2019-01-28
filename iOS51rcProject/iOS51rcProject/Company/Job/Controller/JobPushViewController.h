//
//  JobPushViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/28.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol JobPushViewDelegate <NSObject>

- (void)JobPushViewConfirm:(NSString *)pushId push:(NSString *)push;
@end

@interface JobPushViewController : WKViewController

@property (nonatomic, assign) id<JobPushViewDelegate> delegate;
@property (nonatomic, strong) NSString *pushId;
@end

