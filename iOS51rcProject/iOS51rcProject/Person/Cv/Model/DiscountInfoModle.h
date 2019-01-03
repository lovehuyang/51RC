//
//  DiscountInfoModle.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DiscountInfoModle : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *DiscountType;
@property (nonatomic , copy) NSString *EndDate;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *Money;
@property (nonatomic , copy) NSString *paMainID;

@property (nonatomic , assign) BOOL isSelceted;// 选中（自己添加的字段）
+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
