//
//  AssessIndexModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AssessIndexModel : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *AddMan;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *ImgUrl;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *NeedTime;
@property (nonatomic , copy) NSString *Notice;
@property (nonatomic , copy) NSString *Price;
@property (nonatomic , copy) NSString *ReTestDay;
@property (nonatomic , copy) NSString *ResultType;
@property (nonatomic , copy) NSString *SortNo;
@property (nonatomic , copy) NSString *Summary;
@property (nonatomic , copy) NSString *UseCount;
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *indexImageUrl;
@property (nonatomic , copy) NSString *isComplete;
@property (nonatomic , copy) NSString *isCvLevel;
@property (nonatomic , copy) NSString *isPay;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
