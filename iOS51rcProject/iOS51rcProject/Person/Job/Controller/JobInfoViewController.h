//
//  JobInfoViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/26.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"
#import "JobViewController.h"

@interface JobInfoViewController : WKViewController

@property (nonatomic, strong) NSDictionary *jobData;
@property (nonatomic, strong) NSDictionary *companyData;
- (void)getData:(NSString *)jobId;
- (void)setTitleButton:(UIButton *)btnAttention btnShare:(UIButton *)btnShare;
- (void)changeAttention;
@end
