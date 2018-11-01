//
//  OneMinuteViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKButton.h"

@interface OneMinuteViewController : UIViewController

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintScrollWidth;
@property (strong, nonatomic) IBOutlet WKButton *btnLogin;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UITextField *txtGender;
@property (strong, nonatomic) IBOutlet UITextField *txtBirth;
@property (strong, nonatomic) IBOutlet UITextField *txtCollege;
@property (strong, nonatomic) IBOutlet UITextField *txtDegree;
@property (strong, nonatomic) IBOutlet UITextField *txtMajorName;
@property (strong, nonatomic) IBOutlet UITextField *txtMajor;
@property (strong, nonatomic) IBOutlet UITextField *txtJobPlace;
@property (strong, nonatomic) IBOutlet UITextField *txtSalary;
@property (strong, nonatomic) IBOutlet UITextField *txtJobType;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtVerifyCode;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnVerifyCode;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@end
