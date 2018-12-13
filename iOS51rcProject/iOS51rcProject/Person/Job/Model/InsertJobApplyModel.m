//
//  InsertJobApplyModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/13.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "InsertJobApplyModel.h"

@implementation InsertJobApplyModel

+ (InsertJobApplyModel *)buideModel:(NSDictionary *)dic{
    return [[InsertJobApplyModel alloc]initWithDic:dic];
}

- (id)initWithDic:(NSDictionary *)dic {
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dic];
    }
    return self;
}
- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    //    if ([key isEqualToString:@"id"]) {
    //        self.Id = value;
    //    }
}
@end
