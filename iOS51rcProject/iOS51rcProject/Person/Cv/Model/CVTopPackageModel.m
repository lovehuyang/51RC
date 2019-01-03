//
//  CVTopPackageModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CVTopPackageModel.h"

@implementation CVTopPackageModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[CVTopPackageModel alloc] initWithDic:dic];
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
//        self.Id = value;
//    }
}
@end
