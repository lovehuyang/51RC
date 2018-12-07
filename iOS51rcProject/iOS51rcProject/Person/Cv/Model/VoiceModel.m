//
//  VoiceModel.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/4.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "VoiceModel.h"

@implementation VoiceModel

+ (NSMutableArray *)createVoiceModel:(NSInteger)type{
    
    NSMutableArray *dataArr = [NSMutableArray array];
    // 认证通过
    if (type == 1) {
        
        NSArray *voiceNameArr = @[@"voiceage",
                                  @"voicebirth",
                                  @"voicedegree",
                                  @"voiceschool",
                                  @"voicemajorname",
                                  @"voicejobtype",
                                  @"voicesalary",
                                  @"voicename"];
        
        NSArray *titleArr = @[@"你是男士还是女士？",
                              @"你的出生年、月是？",
                              @"你的最高学历是？",
                              @"毕业学校是？",
                              @"你所学专业名称是？",
                              @"你最期望的岗位是？",
                              @"你的期望月薪是？",
                              @"你的姓名是？"];
        
        for (int i = 0; i < titleArr.count; i ++) {
            NSString *path = [[NSBundle mainBundle] pathForResource:voiceNameArr[i] ofType:@"mp3"];
            VoiceModel *model = [[VoiceModel alloc]init];
            model.titleStr = titleArr[i];
            model.voicePath = path;
            model.recognationStr = @"";
            [dataArr addObject:model];
        }
        
    }else{// 未认证
        NSArray *voiceNameArr = @[@"voicemobile",
                                  @"voiceage",
                                  @"voicebirth",
                                  @"voicedegree",
                                  @"voiceschool",
                                  @"voicemajorname",
                                  @"voicejobtype",
                                  @"voicesalary",
                                  @"voicename"];
        
        NSArray *titleArr = @[@"你的手机号码是？",
                              @"你是男士还是女士？",
                              @"你的出生年、月是？",
                              @"你的最高学历是？",
                              @"毕业学校是？",
                              @"你所学专业名称是？",
                              @"你最期望的岗位是？",
                              @"你的期望月薪是？",
                              @"你的姓名是？"];
        for (int i = 0; i < titleArr.count; i ++) {
            NSString *path = [[NSBundle mainBundle] pathForResource:voiceNameArr[i] ofType:@"mp3"];
            VoiceModel *model = [[VoiceModel alloc]init];
            model.titleStr = titleArr[i];
            model.voicePath = path;
            model.recognationStr = @"";
            [dataArr addObject:model];
        }
    }
    return dataArr;
}

@end
