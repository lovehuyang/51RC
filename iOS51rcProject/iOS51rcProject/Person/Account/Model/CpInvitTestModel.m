//
//  CpInvitTestModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CpInvitTestModel.h"

@implementation CpInvitTestModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[CpInvitTestModel alloc] initWithDic:dic];
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
