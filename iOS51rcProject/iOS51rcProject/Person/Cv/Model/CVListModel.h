//
//  CVListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/26.
//  Copyright © 2018年 Jerry. All rights reserved.
//  简历列表的model

#import <Foundation/Foundation.h>

@interface CVListModel : NSObject
@property (nonatomic ,copy )NSString *ID;
@property (nonatomic ,copy )NSString *IsNameHidden;
@property (nonatomic ,copy )NSString *IscvHidden;
@property (nonatomic ,copy )NSString *Name;
@property (nonatomic ,copy )NSString *Valid;
@property (nonatomic ,copy )NSString *VerifyResult;
@property (nonatomic ,copy )NSString *VerifyResultEng;
@property (nonatomic ,copy )NSString *ViewNumber;
@property (nonatomic ,copy )NSString *cvLevel;
@property (nonatomic ,copy )NSString *cvLevelEng;
@property (nonatomic ,copy )NSString *cvType;
@property (nonatomic ,copy )NSString *isOpen;
@property (nonatomic ,copy )NSString *paMainID;

@property (nonatomic ,assign) BOOL isSlected;// 是否被选中（自己添加的字段）

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
