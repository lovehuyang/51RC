//
//  CpJobListModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CpJobListModel.h"

@implementation CpJobListModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[CpJobListModel alloc] initWithDic:dic];
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
