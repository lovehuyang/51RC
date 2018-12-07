//
//  NSString+CutProvince.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/7.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RCString)
+ (NSString *)cutProvince:(NSString *)regionStr;
+ (NSArray *)getHideConditions:(NSString *)hideConditions;
+ (NSString *)juedeString:(NSString *)judeStr;
@end
