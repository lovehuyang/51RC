//
//  PaInfoModifyViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/10.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol PaInfoModifyDelegate <NSObject>

- (void)paInfoModifySuccess;
@end

@interface PaInfoModifyViewController : WKViewController

@property (nonatomic, assign) id<PaInfoModifyDelegate> delegate;
@property (strong, nonatomic) NSDictionary *dataPa;
@property (strong, nonatomic) NSDictionary *dataCv;
@property (strong, nonatomic) IBOutlet UITextField *txtName;
@property (strong, nonatomic) IBOutlet UIButton *btnGender;
@property (strong, nonatomic) IBOutlet UIButton *btnBirth;
@property (strong, nonatomic) IBOutlet UIButton *btnLivePlace;
@property (strong, nonatomic) IBOutlet UIButton *btnAccountPlace;
@property (strong, nonatomic) IBOutlet UIButton *btnGrowPlace;
@property (strong, nonatomic) IBOutlet UITextField *txtMobile;
@property (strong, nonatomic) IBOutlet UITextField *txtEmail;
@end
