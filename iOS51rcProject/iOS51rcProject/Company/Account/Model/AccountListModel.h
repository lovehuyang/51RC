//
//  AccountListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AccountListModel : NSObject
@property (nonatomic , copy) NSString *AccountType;
@property (nonatomic , copy) NSString *Dept;
@property (nonatomic , copy) NSString *EMail;
@property (nonatomic , copy) NSString *EmailSentType;
@property (nonatomic , copy) NSString *Gender;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *IsDelete;
@property (nonatomic , copy) NSString *IsMobileHide;
@property (nonatomic , copy) NSString *IsNameHide;
@property (nonatomic , copy) NSString *IsPause;
@property (nonatomic , copy) NSString *IsPhoneHide;
@property (nonatomic , copy) NSString *IsReceiveSms;
@property (nonatomic , copy) NSString *LastModifyDate;
@property (nonatomic , copy) NSString *Mobile;
@property (nonatomic , copy) NSString *MobileVerifyDate;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *Password;
@property (nonatomic , copy) NSString *RegDate;
@property (nonatomic , copy) NSString *Telephone;
@property (nonatomic , copy) NSString *Title;
@property (nonatomic , copy) NSString *UserName;
@property (nonatomic , copy) NSString *UserNameLower;
@property (nonatomic , copy) NSString *cpMainID;
@property (nonatomic , copy) NSString *wechat;

+ (id)buildModelWithDic:(NSDictionary *)dic;

@end
