//
//  YourFoodModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YourFoodModel : NSObject
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *JobID;
@property (nonatomic , copy) NSString *JobName;
@property (nonatomic , copy) NSString *IsOnline;
@property (nonatomic , copy) NSString *dcSalaryID;
@property (nonatomic , copy) NSString *Salary;
@property (nonatomic , copy) NSString *SalaryMax;
@property (nonatomic , copy) NSString *CpName;
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *Experience;
@property (nonatomic , copy) NSString *Education;
@property (nonatomic , copy) NSString *Region;

+ (YourFoodModel *)buideModel:(NSDictionary *)dic;
@end
