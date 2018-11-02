//
//  PaLoginViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/5.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@interface PaLoginViewController : WKViewController

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UIButton *passwordBtn;// 密码输入框的眼睛按钮
@property (strong, nonatomic) IBOutlet UIButton *btnPassword;
@property (strong, nonatomic) IBOutlet UIButton *btnOneMinute;
@property (strong, nonatomic) IBOutlet UIButton *btnRegister;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintOneMinuteWidth;
@end
