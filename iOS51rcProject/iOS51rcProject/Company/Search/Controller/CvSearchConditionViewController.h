//
//  CvSearchConditionViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface CvSearchConditionViewController : WKViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollBottom;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintViewBottom;
@property (strong, nonatomic) IBOutlet UIButton *btnMore;
@property (strong, nonatomic) IBOutlet UITextField *txtKeyword;
@property (strong, nonatomic) IBOutlet UITextField *txtJobPlaceExpect;
@property (strong, nonatomic) IBOutlet UITextField *txtJobTypeExpect;
@property (strong, nonatomic) IBOutlet UITextField *txtLivePlace;
@property (strong, nonatomic) IBOutlet UITextField *txtIndustryExpect;
@property (strong, nonatomic) IBOutlet UITextField *txtExperience;
@property (strong, nonatomic) IBOutlet UITextField *txtLowerNumber;
@property (strong, nonatomic) IBOutlet UITextField *txtIndustry;
@property (strong, nonatomic) IBOutlet UITextField *txtJobType;
@property (strong, nonatomic) IBOutlet UITextField *txtEmployType;
@property (strong, nonatomic) IBOutlet UITextField *txtSalaryExpect;
@property (strong, nonatomic) IBOutlet UITextField *txtCollege;
@property (strong, nonatomic) IBOutlet UITextField *txtDegree;
@property (strong, nonatomic) IBOutlet UITextField *txtMajor;
@property (strong, nonatomic) IBOutlet UITextField *txtGraduation;
@property (strong, nonatomic) IBOutlet UITextField *txtLanguage;
@property (strong, nonatomic) IBOutlet UITextField *txtMajorName;
@property (strong, nonatomic) IBOutlet UITextField *txtAccountPlace;
@property (strong, nonatomic) IBOutlet UITextField *txtAge;
@property (strong, nonatomic) IBOutlet UITextField *txtHeight;
@property (strong, nonatomic) IBOutlet UITextField *txtMobilePlace;
@property (strong, nonatomic) IBOutlet UITextField *txtGender;
@property (strong, nonatomic) IBOutlet UITextField *txtOnline;
@property (strong, nonatomic) IBOutlet UITextField *txtCvMainId;
@property (strong, nonatomic) IBOutlet UITextField *txtJob;
@property (strong, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) IBOutlet UIView *viewHistory;
@property (strong, nonatomic) IBOutlet UIButton *btnClear;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintHistoryHeight;
@end
