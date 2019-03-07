//
//  CpInvitTestModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpInvitTestModel : NSObject
@property (nonatomic ,copy) NSString *ID;
@property (nonatomic ,copy) NSString *CaMainID;
@property (nonatomic ,copy) NSString *PaMainID;
@property (nonatomic ,copy) NSString *AssessTypeID;
@property (nonatomic ,copy) NSString *EndDate;
@property (nonatomic ,copy) NSString *AddDate;
@property (nonatomic ,copy) NSString *RemindDate;
@property (nonatomic ,copy) NSString *CvMainID;
@property (nonatomic ,copy) NSString *AssessTypeName;
@property (nonatomic ,copy) NSString *CpName;
@property (nonatomic ,copy) NSString *isComplete;
@property (nonatomic ,copy) NSString *isAssessStatus;
@property (nonatomic ,copy) NSString *CpLogoUrl;
@property (nonatomic ,copy) NSString *AssessTestLogID;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
