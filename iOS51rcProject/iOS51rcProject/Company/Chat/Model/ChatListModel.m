//
//  ChatListModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/15.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ChatListModel.h"

@implementation ChatListModel

+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[ChatListModel alloc] initWithDic:dic];
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
