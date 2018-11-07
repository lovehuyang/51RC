//
//  NSString+CutProvince.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/7.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "NSString+CutProvince.h"
#import "Common.h"

@implementation NSString (CutProvince)
+ (NSString *)cutProvince:(NSString *)regionStr{
    NSArray *provinceArr = [Common getProvince];
    NSString *provinceStr = nil;
    for (NSDictionary *provinceDict in provinceArr) {
        NSString *valueStr = [provinceDict objectForKey:@"value"];
        if ([valueStr containsString:regionStr] || [regionStr containsString:valueStr]) {
            provinceStr = [provinceDict objectForKey:@"value"];
            break;
        }
    }
    NSArray *seperateArr = [regionStr componentsSeparatedByString:provinceStr];
    
    return [seperateArr lastObject];
}
@end
