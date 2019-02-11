//
//  ApplyCvListModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ApplyCvListModel.h"

@implementation ApplyCvListModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[ApplyCvListModel alloc] initWithDic:dic];
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
