//
//  CompanyDetailViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/29.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompanyDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSArray *arrEnvironment;
- (void)adjustHeight:(float)height;
@end
