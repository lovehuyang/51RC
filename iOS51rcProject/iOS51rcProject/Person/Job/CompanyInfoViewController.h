//
//  CompanyInfoViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/26.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol CompanyInfoViewDelegate <NSObject>

- (void)jobClickFromCompany:(NSString *)jobId;
@end

@interface CompanyInfoViewController : WKViewController

@property (nonatomic, assign) id<CompanyInfoViewDelegate> delegate;
@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSArray *arrEnvironment;
- (void)setTitleButton:(UIButton *)btnAttention btnShare:(UIButton *)btnShare;
- (void)changeAttention;
@end
