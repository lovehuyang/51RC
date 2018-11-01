//
//  JobModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface JobModifyViewController : WKViewController

@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) IBOutlet UIView *viewTemplate;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintsJobTypeTop;
@property (strong, nonatomic) IBOutlet UITextField *txtJobName;
@property (strong, nonatomic) IBOutlet UITextField *txtTemplate;
@property (strong, nonatomic) IBOutlet UITextField *txtJobType;
@property (strong, nonatomic) IBOutlet UITextField *txtJobTypeMinor;
@property (strong, nonatomic) IBOutlet UITextField *txtNeedNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtEmployType;
@property (strong, nonatomic) IBOutlet UITextField *txtRegion;
@property (strong, nonatomic) IBOutlet UITextField *txtIssueEnd;
@property (strong, nonatomic) IBOutlet UITextField *txtDegree;
@property (strong, nonatomic) IBOutlet UITextField *txtWorkYears;
@property (strong, nonatomic) IBOutlet UITextField *txtAge;
@property (strong, nonatomic) IBOutlet UITextField *txtResponsibility;
@property (strong, nonatomic) IBOutlet UITextField *txtDemand;
@property (strong, nonatomic) IBOutlet UITextField *txtSalary;
@property (strong, nonatomic) IBOutlet UITextField *txtNegotiable;
@property (strong, nonatomic) IBOutlet UITextField *txtWelfare;
@property (strong, nonatomic) IBOutlet UITextField *txtTags;
@property (strong, nonatomic) IBOutlet UITextField *txtPush;
@end
