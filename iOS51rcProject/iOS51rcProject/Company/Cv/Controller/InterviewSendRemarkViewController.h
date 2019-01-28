//
//  InterviewSendRemarkViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/18.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol InterviewSendRemarkViewDelegate <NSObject>

- (void)InterviewSendRemarkConfirm:(NSString *)remark;
@end

@interface InterviewSendRemarkViewController : WKViewController

@property (nonatomic, strong) NSString *remark;
@property (nonatomic, assign) id<InterviewSendRemarkViewDelegate> delegate;
@end
