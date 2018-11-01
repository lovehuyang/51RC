//
//  UserInfo.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserInfo : NSObject
@property (nonatomic , copy) NSString *AccountPlace; // 3201;
@property (nonatomic , copy) NSString *AccountRegion;//"\U6d4e\U5357\U5e02";
@property (nonatomic , copy) NSString *AddDate; //"2015-10-25T08:57:00+08:00";
@property (nonatomic , copy) NSString *Age;// 28;
@property (nonatomic , copy) NSString *BirthDay;// 199001;
@property (nonatomic , copy) NSString *BlockCount; // 0;
@property (nonatomic , copy) NSString *CareerStatus ;// "\U76ee\U524d\U5728\U804c\Uff0c\U6b63\U5728\U5bfb\U627e\U66f4\U597d\U673a\U4f1a";
@property (nonatomic , copy) NSString *Email;// "lovehuyang90@163.com";
@property (nonatomic , copy) NSString *Gender;// false;
@property (nonatomic , copy) NSString *GrowPlace;// 3201;
@property (nonatomic , copy) NSString *GrowRegion;// "\U6d4e\U5357\U5e02";
@property (nonatomic , copy) NSString *HasPhoto;// 1;
@property (nonatomic , copy) NSString *HideConditions;// "<\U5b9d\U667a\U7f51\U7edc>";
@property (nonatomic , copy) NSString *ID;// 26395818;
@property (nonatomic , copy) NSString *IsDefaultPassword;// false;
@property (nonatomic , copy) NSString *IsReceiveSms;// false;
@property (nonatomic , copy) NSString *IsUseYourFood;// true;
@property (nonatomic , copy) NSString *LastLoginDate;// "2018-11-01T08:41:38.24+08:00";
@property (nonatomic , copy) NSString *LastLoginIP;// "60.215.144.163";
@property (nonatomic , copy) NSString *LastModifyDate;// "2018-10-27T22:43:00+08:00";
@property (nonatomic , copy) NSString *LivePlace;// 3201;
@property (nonatomic , copy) NSString *LiveRegion;// "\U6d4e\U5357\U5e02";
@property (nonatomic , copy) NSString *Mobile;// 15665889905;
@property (nonatomic , copy) NSString *MobileCount;// 2;
@property (nonatomic , copy) NSString *MobileVerifyDate;// "2017-06-27T17:04:00+08:00";
@property (nonatomic , copy) NSString *Name;// "\U80e1\U9c81\U9633";
@property (nonatomic , copy) NSString *Password;// "$2a$10$toW35RcNkBwXc9gZ6E0GzOR63pzFS2TcorlLRswhXCMHxfhoSlbji";
@property (nonatomic , copy) NSString *PerfectDate;// "2015-11-03T00:00:00+08:00";
@property (nonatomic , copy) NSString *PhotoProcessed;// "26395818_20180907173042.jpg";
@property (nonatomic , copy) NSString *PrevLoginDate;// "2018-10-31T08:18:00+08:00";
@property (nonatomic , copy) NSString *RegisterFrom;// 3;
@property (nonatomic , copy) NSString *RegisterIP;// IOS;
@property (nonatomic , copy) NSString *RegisterMode;//0;
@property (nonatomic , copy) NSString *RegisterType;//1;
@property (nonatomic , copy) NSString *TodayLoginNum;// 1;
@property (nonatomic , copy) NSString *TotalLoginNum;//100;
@property (nonatomic , copy) NSString *UserName;// "lovehuyang90@163.com";
@property (nonatomic , copy) NSString *UserNameLower;// "lovehuyang90@163.com";
@property (nonatomic , copy) NSString *VerifyCount;// 5;
@property (nonatomic , copy) NSString *WechatBind;// 1;
@property (nonatomic , copy) NSString *dcCareerStatus;// 2;
@property (nonatomic , copy) NSString *dcProvinceID;// 32;
@property (nonatomic , copy) NSString *dcSubSiteID;//32;

+ (UserInfo *)buideModel:(NSDictionary *)dic;
/*
 AccountPlace = 3201;
 AccountRegion = "\U6d4e\U5357\U5e02";
 AddDate = "2015-10-25T08:57:00+08:00";
 Age = 28;
 BirthDay = 199001;
 BlockCount = 0;
 CareerStatus = "\U76ee\U524d\U5728\U804c\Uff0c\U6b63\U5728\U5bfb\U627e\U66f4\U597d\U673a\U4f1a";
 Email = "lovehuyang90@163.com";
 Gender = false;
 GrowPlace = 3201;
 GrowRegion = "\U6d4e\U5357\U5e02";
 HasPhoto = 1;
 HideConditions = "<\U5b9d\U667a\U7f51\U7edc>";
 ID = 26395818;
 IsDefaultPassword = false;
 IsReceiveSms = false;
 IsUseYourFood = true;
 LastLoginDate = "2018-11-01T08:41:38.24+08:00";
 LastLoginIP = "60.215.144.163";
 LastModifyDate = "2018-10-27T22:43:00+08:00";
 LivePlace = 3201;
 LiveRegion = "\U6d4e\U5357\U5e02";
 Mobile = 15665889905;
 MobileCount = 2;
 MobileVerifyDate = "2017-06-27T17:04:00+08:00";
 Name = "\U80e1\U9c81\U9633";
 Password = "$2a$10$toW35RcNkBwXc9gZ6E0GzOR63pzFS2TcorlLRswhXCMHxfhoSlbji";
 PerfectDate = "2015-11-03T00:00:00+08:00";
 PhotoProcessed = "26395818_20180907173042.jpg";
 PrevLoginDate = "2018-10-31T08:18:00+08:00";
 RegisterFrom = 3;
 RegisterIP = IOS;
 RegisterMode = 0;
 RegisterType = 1;
 TodayLoginNum = 1;
 TotalLoginNum = 100;
 UserName = "lovehuyang90@163.com";
 UserNameLower = "lovehuyang90@163.com";
 VerifyCount = 5;
 WechatBind = 1;
 dcCareerStatus = 2;
 dcProvinceID = 32;
 dcSubSiteID = 32;
 
 */
@end
