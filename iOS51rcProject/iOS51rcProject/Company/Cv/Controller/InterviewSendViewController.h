//
//  InterviewSendViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/12.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface InterviewSendViewController : WKViewController

@property (strong, nonatomic) NSString *cvMainId;
@property (strong, nonatomic) NSString *jobId;
@property (strong, nonatomic) NSString *paName;
@property (strong, nonatomic) NSMutableArray *arrayJob;
@property (strong, nonatomic) NSMutableArray *arrayTemplate;
@property (strong, nonatomic) NSDictionary *otherData;

@property (strong, nonatomic) IBOutlet UILabel *lbTips;
@property (strong, nonatomic) IBOutlet UITextField *txtTemplate;
@property (strong, nonatomic) IBOutlet UITextField *txtJob;
@property (strong, nonatomic) IBOutlet UITextField *txtTime;
@property (strong, nonatomic) IBOutlet UITextField *txtPlace;
@property (strong, nonatomic) IBOutlet UITextField *txtLinkman;
@property (strong, nonatomic) IBOutlet UITextField *txtTelephone;
@property (strong, nonatomic) IBOutlet UITextField *txtRemark;
@property (strong, nonatomic) IBOutlet UILabel *lbSmsTips;
@property (strong, nonatomic) IBOutlet UIButton *btnSms;
@end
