//
//  CpRegisterViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/9/20.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@interface CpRegisterViewController : WKViewController


@property (strong, nonatomic) IBOutlet UIButton *btnProvince;
@property (strong, nonatomic) IBOutlet UITextField *txtCompanyName;
@property (strong, nonatomic) IBOutlet UITextField *txtLinkman;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtCode;
@property (strong, nonatomic) IBOutlet UITextField *txtZip;
@property (strong, nonatomic) IBOutlet UITextField *txtPhone;
@property (strong, nonatomic) IBOutlet UITextField *txtExt;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnCode;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@end
