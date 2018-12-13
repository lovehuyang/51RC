//
//  InsertJobApplyModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/13.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InsertJobApplyModel : NSObject
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , assign) BOOL isSeleted;// 默认选中
@property (nonatomic , copy) NSString *cpName;// 公司名
@property (nonatomic , copy) NSString *JobName;// 职位名
@property (nonatomic , copy) NSString *dcSalaryID;// 期望薪资id
@property (nonatomic , copy) NSString *dcSalary;// 最低薪资
@property (nonatomic , copy) NSString *dcSalaryMax;// 最高薪资
@property (nonatomic , copy) NSString *RefreshDate;// 刷新时间
@property (nonatomic , copy) NSString *ExperienceName;// 工作经验
@property (nonatomic , copy) NSString *EducationName;// 学历
@property (nonatomic , copy) NSString *Region;// 地区

+ (InsertJobApplyModel *)buideModel:(NSDictionary *)dic;
@end
