//
//  ChatListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/15.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatListModel : NSObject

@property (nonatomic , copy) NSString *Gender;
@property (nonatomic , copy) NSString *LastSendDate;
@property (nonatomic , copy) NSString *Message;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *NoViewedNum;
@property (nonatomic , copy) NSString *OnlineStatus;
@property (nonatomic , copy) NSString *PhotoUrl;
@property (nonatomic , copy) NSString *SecondId;
@property (nonatomic , copy) NSString *caMainID;
@property (nonatomic , copy) NSString *cvMainID;
@property (nonatomic , copy) NSString *paMainId;

+ (id)buildModelWithDic:(NSDictionary *)dic;

@end
