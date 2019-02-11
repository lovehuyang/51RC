//
//  DownloadCVModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/11.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "DownloadCVModel.h"

@implementation DownloadCVModel
+ (id)buildModelWithDic:(NSDictionary *)dic{
    
    return [[DownloadCVModel alloc] initWithDic:dic];
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
