//
//  CpMobileVerifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/19.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CpMobileVerifyViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UIButton *btnOpen;
@property (strong, nonatomic) IBOutlet UIButton *btnCode;
@property (strong, nonatomic) IBOutlet UITextField *txtCode;
@property (strong, nonatomic) IBOutlet UILabel *lbTips;
@property (strong, nonatomic) NSString *mobile;
@end
