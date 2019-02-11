//
//  CpJobListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpJobListModel : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *ApplyCount;
@property (nonatomic , copy) NSString *ApplyNumber;
@property (nonatomic , copy) NSString *Demand;
@property (nonatomic , copy) NSString *DisplayNo;
@property (nonatomic , copy) NSString *EMailSendFreq;
@property (nonatomic , copy) NSString *EmployType;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *IsDelete;
@property (nonatomic , copy) NSString *IsOnline;
@property (nonatomic , copy) NSString *IssueDate;
@property (nonatomic , copy) NSString *IssueEnd;
@property (nonatomic , copy) NSString *LastEmailDate;
@property (nonatomic , copy) NSString *LastModifyDate;
@property (nonatomic , copy) NSString *LogoUrl;
@property (nonatomic , copy) NSString *MaxAge;
@property (nonatomic , copy) NSString *MinAge;
@property (nonatomic , copy) NSString *MinExperience;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *NeedNumber;
@property (nonatomic , copy) NSString *Promotion;
@property (nonatomic , copy) NSString *RefreshDate;
@property (nonatomic , copy) NSString *Responsibility;
@property (nonatomic , copy) NSString *SecondId;
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *ViewNumber;
@property (nonatomic , copy) NSString *Welfare1;
@property (nonatomic , copy) NSString *Welfare10;
@property (nonatomic , copy) NSString *Welfare11;
@property (nonatomic , copy) NSString *Welfare12;
@property (nonatomic , copy) NSString *Welfare13;
@property (nonatomic , copy) NSString *Welfare14;
@property (nonatomic , copy) NSString *Welfare15;
@property (nonatomic , copy) NSString *Welfare16;
@property (nonatomic , copy) NSString *Welfare17;
@property (nonatomic , copy) NSString *Welfare18;
@property (nonatomic , copy) NSString *Welfare19;
@property (nonatomic , copy) NSString *Welfare2;
@property (nonatomic , copy) NSString *Welfare3;
@property (nonatomic , copy) NSString *Welfare4;
@property (nonatomic , copy) NSString *Welfare5;
@property (nonatomic , copy) NSString *Welfare6;
@property (nonatomic , copy) NSString *Welfare7;
@property (nonatomic , copy) NSString *Welfare8;
@property (nonatomic , copy) NSString *Welfare9;
@property (nonatomic , copy) NSString *caMainID;
@property (nonatomic , copy) NSString *cpMainID;
@property (nonatomic , copy) NSString *dcEducationID;
@property (nonatomic , copy) NSString *dcJobTypeID;
@property (nonatomic , copy) NSString *dcRegionID;
@property (nonatomic , copy) NSString *dcSalaryID;
@property (nonatomic , copy) NSString *dcSalaryIdMax;
@property (nonatomic , copy) NSString *jobrefreshIng;

+ (id)buildModelWithDic:(NSDictionary *)dic;

@end
