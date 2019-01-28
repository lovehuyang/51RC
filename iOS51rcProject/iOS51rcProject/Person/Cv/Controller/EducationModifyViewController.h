//
//  EducationModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/11.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"
#import "WKButton.h"

@interface EducationModifyViewController : WKViewController
@property (strong, nonatomic) IBOutlet UIView *bgView;

@property (strong, nonatomic) IBOutlet UITextField *txtCollege;
@property (strong, nonatomic) IBOutlet UIButton *btnGraduation;
@property (strong, nonatomic) IBOutlet UIButton *btnDegree;
@property (strong, nonatomic) IBOutlet UIButton *btnEduType;
@property (strong, nonatomic) IBOutlet UIButton *btnMajor;
@property (strong, nonatomic) IBOutlet UIButton *btnMajorName;
@property (strong, nonatomic) IBOutlet UITextView *txtDetail;
@property (strong, nonatomic) IBOutlet WKButton *btnDelete;
@property (strong, nonatomic) NSString *cvMainId;
@property (strong, nonatomic) NSDictionary *dataEducation;
@end
