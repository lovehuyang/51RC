//
//  CpAttentionModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CpAttentionModel.h"

@implementation CpAttentionModel
+ (CpAttentionModel *)buideModel:(NSDictionary *)dic{
    return [[CpAttentionModel alloc]initWithDic:dic];
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
