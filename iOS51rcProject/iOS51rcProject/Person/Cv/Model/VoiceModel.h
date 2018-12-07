//
//  VoiceModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/4.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoiceModel : NSObject
@property (nonatomic , copy) NSString *titleStr;
@property (nonatomic , copy) NSString *voicePath;
@property (nonatomic , copy) NSString *recognationStr;// 语音识别结果


/**
 创建语音数据模型

 @param type 1：手机通过审核 0：手机未通过审核
 @return 数据模型
 */
+ (NSMutableArray *)createVoiceModel:(NSInteger)type;
@end
