//
//  JobViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@interface JobViewController : WKViewController

@property (strong, nonatomic) IBOutlet UIView *viewTitle;
@property (strong, nonatomic) IBOutlet UIView *viewTitileBackground;
@property (strong, nonatomic) IBOutlet UIButton *btnJob;
@property (strong, nonatomic) IBOutlet UIButton *btnCompany;
@property (strong, nonatomic) IBOutlet UIButton *btnShare;
@property (strong, nonatomic) IBOutlet UIButton *btnAttention;

@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) NSString *companyId;
- (void)companyClickWithAnimated:(BOOL)animated;
- (void)jobClickWithJobId:(NSString *)jobId;
@end
