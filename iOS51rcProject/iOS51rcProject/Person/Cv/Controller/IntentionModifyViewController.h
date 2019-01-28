//
//  IntentionModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/10.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol IntentionModifyDelegate <NSObject>

- (void)intentionModifySuccess;
@end

@interface IntentionModifyViewController : WKViewController

@property (nonatomic, assign) id<IntentionModifyDelegate> delegate;
@property (strong, nonatomic) NSDictionary *dataPa;
@property (strong, nonatomic) NSDictionary *dataCv;
@property (strong, nonatomic) NSDictionary *dataJobIntention;
@property (strong, nonatomic) IBOutlet UIButton *btnCareerStatus;
@property (strong, nonatomic) IBOutlet UIButton *btnWorkYears;
@property (strong, nonatomic) IBOutlet UIButton *btnEmployType;
@property (strong, nonatomic) IBOutlet UIButton *btnSalary;
@property (strong, nonatomic) IBOutlet UIButton *btnJobPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnJobType;
@property (strong, nonatomic) IBOutlet UIButton *btnIndustry;
@end
