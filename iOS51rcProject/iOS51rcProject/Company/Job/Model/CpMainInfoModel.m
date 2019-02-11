//
//  CpMainInfoModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CpMainInfoModel.h"

@implementation CpMainInfoModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[CpMainInfoModel alloc] initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
//    if ([key isEqualToString:@"id"]) {
//
//    }
}

@end
