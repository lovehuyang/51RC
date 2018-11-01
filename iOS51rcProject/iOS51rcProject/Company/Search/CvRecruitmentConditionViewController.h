//
//  CvRecruitmentConditionViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface CvRecruitmentConditionViewController : WKViewController

@property (strong, nonatomic) IBOutlet UITextField *txtRegion;
@property (strong, nonatomic) IBOutlet UITextField *txtPlace;
@property (strong, nonatomic) IBOutlet UITextField *txtJobType;
@property (strong, nonatomic) IBOutlet UIButton *btnSearch;
@property (strong, nonatomic) IBOutlet UITextField *txtKeyword;
@end
