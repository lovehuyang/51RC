//
//  CpModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface CpModifyViewController : WKViewController

@property (strong, nonatomic) IBOutlet UILabel *lbCompanyName;
@property (strong, nonatomic) IBOutlet UITextField *txtCompanyName;
@property (strong, nonatomic) IBOutlet UITextField *txtIndustry;
@property (strong, nonatomic) IBOutlet UITextField *txtCompanyKind;
@property (strong, nonatomic) IBOutlet UITextField *txtCompanySize;
@property (strong, nonatomic) IBOutlet UITextField *txtZipCode;
@property (strong, nonatomic) IBOutlet UITextField *txtHomepage;
@property (strong, nonatomic) IBOutlet UITextField *txtRegion;
@property (strong, nonatomic) IBOutlet UITextField *txtBrief;
@property (strong, nonatomic) IBOutlet UIButton *btnSave;
@property Boolean forceModify;
@end
