//
//  CvOperate.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/10.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum : NSInteger {
    CvOperateTypeChat,
    CvOperateTypeReplyPass,
    CvOperateTypeReplyDeny,
    CvOperateTypeReplyDenyReason,
    CvOperateTypeInterview,
    CvOperateTypeInvitation,
    CvOperateTypeFavorite,
    CvOperateTypeNone
} CvOperateType;

typedef enum : NSInteger {
    CvOperateNetChatPrivi,
    CvOperateNetReply,
    CvOperateNetReplyReason,
    CvOperateNetValidJob,
    CvOperateNetDownload,
    CvOperateNetFavorite,
    CvOperateNetInvitation,
    CvOperateNetInterview
} CvOperateNet;

@protocol CvOperateDelegate <NSObject>

@optional
- (void)cvOperateFinished;
@end

@interface CvOperate : NSObject

@property (nonatomic, strong) NSString *cvMainId;
@property (nonatomic, strong) NSString *paName;
@property (nonatomic, strong) NSString *jobId;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, assign) id<CvOperateDelegate> delegate;

- (instancetype)init:(NSString *)cvMainId paName:(NSString *)paName viewController:(UIViewController *)viewController;
- (void)replyCv:(NSString *)applyId replyType:(NSString *)replyType;
- (void)interview;
- (void)beginChat;
- (void)invitation;
- (void)favorite;
@end
