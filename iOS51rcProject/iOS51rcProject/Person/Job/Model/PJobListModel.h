//
//  PJobListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PJobListModel : NSObject

@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *IsTop;
@property (nonatomic , copy) NSString *LogoUrl;
@property (nonatomic , copy) NSString *JobName;
@property (nonatomic , copy) NSString *IsOnline;
@property (nonatomic , copy) NSString *dcSalaryID;
@property (nonatomic , copy) NSString *dcSalary;
@property (nonatomic , copy) NSString *dcSalaryMax;
@property (nonatomic , copy) NSString *cpName;
@property (nonatomic , copy) NSString *RefreshDate;
@property (nonatomic , copy) NSString *ExperienceName;
@property (nonatomic , copy) NSString *EducationName;
@property (nonatomic , copy) NSString *Region;

+ (PJobListModel *)buideModel:(NSDictionary *)dic;
@end
