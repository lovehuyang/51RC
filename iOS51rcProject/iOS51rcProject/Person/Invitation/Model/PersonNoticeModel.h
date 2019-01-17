//
//  PersonNoticeModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/14.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PersonNoticeModel : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *ApplyReplyDate;
@property (nonatomic , copy) NSString *AttentionDate;
@property (nonatomic , copy) NSString *ChatCount;
@property (nonatomic , copy) NSString *CpInvitationCount;
@property (nonatomic , copy) NSString *CvViewLogCount;
@property (nonatomic , copy) NSString *IntentionDate;
@property (nonatomic , copy) NSString *InterviewCount;
@property (nonatomic , copy) NSString *InterviewDate;
@property (nonatomic , copy) NSString *JobAppliedCount;
@property (nonatomic , copy) NSString *MyAttentionCount;
@property (nonatomic , copy) NSString *ViewLogDate;
@property (nonatomic , copy) NSString *YourFoodCount;
@property (nonatomic , copy) NSString *YourFoodDate;
@property (nonatomic , copy) NSString *paMainId;

+ (PersonNoticeModel *)buideModel:(NSDictionary *)dic;

@end
