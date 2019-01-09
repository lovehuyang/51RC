//
//  OrderListModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "OrderListModel.h"

@implementation OrderListModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[OrderListModel alloc] initWithDic:dic];
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
