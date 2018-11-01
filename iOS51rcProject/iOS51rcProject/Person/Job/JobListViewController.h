//
//  JobListViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/30.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol JobListViewDelegate <NSObject>

- (void)jobClick:(NSString *)jobId;
@end

@interface JobListViewController : WKViewController

@property (nonatomic, strong) NSString *companyId;
@property (nonatomic, assign) id<JobListViewDelegate> delegate;
- (void)adjustHeight:(float)height;
@end
