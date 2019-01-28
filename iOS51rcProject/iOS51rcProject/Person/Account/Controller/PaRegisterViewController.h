//
//  PaRegisterViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/6.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@interface PaRegisterViewController : WKViewController

@property (strong, nonatomic) IBOutlet UITextField *txtUsername;
@property (strong, nonatomic) IBOutlet UITextField *txtPassword;
@property (strong, nonatomic) IBOutlet UITextField *txtMobileCer;
@property (strong, nonatomic) IBOutlet UIButton *btnMobileCer;
@property (strong, nonatomic) IBOutlet UIButton *btnAgree;
@property (strong, nonatomic) IBOutlet UIButton *btnOneMinute;
@end
