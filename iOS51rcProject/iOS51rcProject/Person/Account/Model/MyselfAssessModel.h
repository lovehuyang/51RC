//
//  MyselfAssessModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyselfAssessModel : NSObject
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *PaMainID;
@property (nonatomic , copy) NSString *AssessTypeID;
@property (nonatomic , copy) NSString *BeginTime;
@property (nonatomic , copy) NSString *EndTime;
@property (nonatomic , copy) NSString *TextResult;
@property (nonatomic , copy) NSString *RemainSeconds;
@property (nonatomic , copy) NSString *LeaveTimes;
@property (nonatomic , copy) NSString *IsOpen;
@property (nonatomic , copy) NSString *Status;
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *AssessTypeName;
@property (nonatomic , copy) NSString *price;
@property (nonatomic , copy) NSString *ReTestDay;
@property (nonatomic , copy) NSString *NeedTime;
@property (nonatomic , copy) NSString *RowNum;
@property (nonatomic , copy) NSString *isComplete;
@property (nonatomic , copy) NSString *isGenerate;
@property (nonatomic , copy) NSString *isPay;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
