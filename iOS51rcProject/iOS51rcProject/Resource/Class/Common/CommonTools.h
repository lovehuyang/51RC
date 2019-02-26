//
//  CommonTools.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonTools : NSObject

+ (CGFloat)getStatusHight;

+ (CGFloat)getStatusAndNavHight;

+ (NSString *)getBDSASRParameter:(NSString *)param;

+ (NSDictionary *)translateJsonStrToDictionary:(NSString *)jsonStr;

+ (BOOL)cvIsFull:(NSString *)cvlevel;

+ (NSString *)changeDateWithDateString:(NSString *)date;

+ (NSString *)shareContent:(NSString *)JobPlaceName;
@end
