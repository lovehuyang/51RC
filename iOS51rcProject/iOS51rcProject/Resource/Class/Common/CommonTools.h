//
//  CommonTools.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonTools : NSObject

+ (CGFloat)getStatusHight;
+ (CGFloat)getStatusAndNavHight;

+ (NSString *)getBDSASRParameter:(NSString *)param;

+ (NSDictionary *)translateJsonStrToDictionary:(NSString *)jsonStr;

@end
