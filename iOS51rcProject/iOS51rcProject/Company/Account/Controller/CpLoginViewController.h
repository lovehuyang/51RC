//
//  CpLoginViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/29.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@interface CpLoginViewController : WKViewController

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnLogin;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@end
