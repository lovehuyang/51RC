//
//  NSString+CutProvince.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RCString)
+ (NSString *)cutProvince:(NSString *)regionStr;
+ (NSArray *)getHideConditions:(NSString *)hideConditions;
+ (NSString *)juedeString:(NSString *)judeStr;
@end
