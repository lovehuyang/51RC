//
//  OneMinuteArray.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OneMinuteArray : NSArray

/**
 创建一分钟填写简历数据源

 @param type 1：通过验证；0未通过验证
 @return 返回数据源
 */
+ (NSArray *)createOneMinuteDataWithType:(NSInteger )type;
@end
