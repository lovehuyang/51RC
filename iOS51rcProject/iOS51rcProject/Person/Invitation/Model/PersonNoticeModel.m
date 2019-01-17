//
//  PersonNoticeModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/14.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "PersonNoticeModel.h"

@implementation PersonNoticeModel
+ (PersonNoticeModel *)buideModel:(NSDictionary *)dic{
    return [[PersonNoticeModel alloc]initWithDic:dic];
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
