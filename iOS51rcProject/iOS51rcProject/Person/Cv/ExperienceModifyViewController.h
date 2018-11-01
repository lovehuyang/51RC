//
//  ExperienceModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/13.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"
#import "WKButton.h"

@interface ExperienceModifyViewController : WKViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollWidth;
@property (strong, nonatomic) IBOutlet UITextField *txtCompanyName;
@property (strong, nonatomic) IBOutlet UIButton *btnIndustry;
@property (strong, nonatomic) IBOutlet UIButton *btnCompanySize;
@property (strong, nonatomic) IBOutlet UITextField *txtJobName;
@property (strong, nonatomic) IBOutlet UIButton *btnJobType;
@property (strong, nonatomic) IBOutlet UIButton *btnLowerNumber;
@property (strong, nonatomic) IBOutlet UIButton *btnBeginDate;
@property (strong, nonatomic) IBOutlet UIButton *btnEndDate;
@property (strong, nonatomic) IBOutlet UITextView *txtDetail;
@property (strong, nonatomic) IBOutlet WKButton *btnDelete;
@property (strong, nonatomic) NSString *cvMainId;
@property (strong, nonatomic) NSDictionary *dataExperience;
@end
