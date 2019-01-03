//
//  PJobListModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "PJobListModel.h"

@implementation PJobListModel
+ (PJobListModel *)buideModel:(NSDictionary *)dic{
    return [[PJobListModel alloc]initWithDic:dic];
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
