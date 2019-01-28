//
//  CpViewModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//  谁在关注我 数据模型

#import <Foundation/Foundation.h>

@interface CpViewModel : NSObject

@property (nonatomic , copy) NSString *Address;
@property (nonatomic , copy) NSString *Email;
@property (nonatomic , copy) NSString *EnCpMainID;
@property (nonatomic , copy) NSString *EnJobId;
@property (nonatomic , copy) NSString *Gender;
@property (nonatomic , copy) NSString *HasLicence ;
@property (nonatomic , copy) NSString *IsAgent;
@property (nonatomic , copy) NSString *IsMobileHide;
@property (nonatomic , copy) NSString *IsNameHide;
@property (nonatomic , copy) NSString *IsPhoneHide;
@property (nonatomic , copy) NSString *LogoUrl;
@property (nonatomic , copy) NSString *Membertype;
@property (nonatomic , copy) NSString *Mobile;
@property (nonatomic , copy) NSString *NeedNumber;
@property (nonatomic , copy) NSString *adddate;
@property (nonatomic , copy) NSString *caMainId;
@property (nonatomic , copy) NSString *caName;
@property (nonatomic , copy) NSString *cpID;
@property (nonatomic , copy) NSString *cpName;
@property (nonatomic , copy) NSString *cvMainId;
@property (nonatomic , copy) NSString *cvName;
@property (nonatomic , copy) NSString *dcRegionId;
@property (nonatomic , copy) NSString *dcSalaryID;
@property (nonatomic , copy) NSString *dcSalaryIDMax;
@property (nonatomic , copy) NSString *jobId;
@property (nonatomic , copy) NSString *jobName;

+ (CpViewModel *)buideModel:(NSDictionary *)dic;

@end
