//
//  CommonTools.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CommonTools.h"

@implementation CommonTools

#pragma mark - 获取状态栏的高度

/**
 获取状态栏的高度
 
 @return 状态栏高度
 */
+ (CGFloat)getStatusHight{
    
    CGRect StatusRect = [[UIApplication sharedApplication]statusBarFrame];
    return StatusRect.size.height;
}

/**
 获取状态栏和导航栏的高度
 
 @return 状态栏和导航栏的高度
 */
+ (CGFloat)getStatusAndNavHight{
    
    return  [self getStatusHight] + 44;
}

/**
 读取百度语音配置参数
 
 @return 参数值
 */
+ (NSString *)getBDSASRParameter:(NSString *)param{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"BDSASRParameter" ofType:@"plist"];
    NSDictionary *paramDict = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    return paramDict[param];
}


/**
 把json字符串转成字典

 @param jsonStr json字符串
 @return 字典
 */
+ (NSDictionary *)translateJsonStrToDictionary:(NSString *)jsonStr{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return resultDict;
}
@end
