//
//  DiscountInfoModle.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "DiscountInfoModle.h"

@implementation DiscountInfoModle
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[DiscountInfoModle alloc] initWithDic:dic];
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
