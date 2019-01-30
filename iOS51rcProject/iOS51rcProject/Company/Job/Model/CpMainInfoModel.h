//
//  CpMainInfoModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/28.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpMainInfoModel : NSObject
@property (nonatomic , copy) NSString *Address;
@property (nonatomic , copy) NSString *AutoReplyConfirm;
@property (nonatomic , copy) NSString *Balance;
@property (nonatomic , copy) NSString *BalanceDate;
@property (nonatomic , copy) NSString *BlockCount;
@property (nonatomic , copy) NSString *Brief;
@property (nonatomic , copy) NSString *CommentNumber;
@property (nonatomic , copy) NSString *CompanyKind;
@property (nonatomic , copy) NSString *CompanySize;
@property (nonatomic , copy) NSString *ConsultantDate;
@property (nonatomic , copy) NSString *ConsultantID;
@property (nonatomic , copy) NSString *DailyGiftQuota;
@property (nonatomic , copy) NSString *Description;
@property (nonatomic , copy) NSString *H5Mode;
@property (nonatomic , copy) NSString *HasLicence;
@property (nonatomic , copy) NSString *HasLogo ;
@property (nonatomic , copy) NSString *HasVisual;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *Industry;
@property (nonatomic , copy) NSString *InterViewNumber;
@property (nonatomic , copy) NSString *IsAgent;
@property (nonatomic , copy) NSString *IsDefaultPassword;
@property (nonatomic , copy) NSString *IsDelete;
@property (nonatomic , copy) NSString *IsJobRefreshOldCompany;
@property (nonatomic , copy) NSString *IsLimitLogin;
@property (nonatomic , copy) NSString *IsProtect;
@property (nonatomic , copy) NSString *Islock;
@property (nonatomic , copy) NSString *JobNumber;
@property (nonatomic , copy) NSString *LastLoginDate;
@property (nonatomic , copy) NSString *LastLoginIP;
@property (nonatomic , copy) NSString *LastModifyDate;
@property (nonatomic , copy) NSString *Lat;
@property (nonatomic , copy) NSString *Lng;
@property (nonatomic , copy) NSString *LoginCount;
@property (nonatomic , copy) NSString *LogoFile;
@property (nonatomic , copy) NSString *MaxJobNumber;
@property (nonatomic , copy) NSString *MaxUserNumber;
@property (nonatomic , copy) NSString *MemberType;
@property (nonatomic , copy) NSString *Mobile;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *PerfectDate;
@property (nonatomic , copy) NSString *RealName;
@property (nonatomic , copy) NSString *RefreshDate;
@property (nonatomic , copy) NSString *RegCapital;
@property (nonatomic , copy) NSString *RegDate;
@property (nonatomic , copy) NSString *Region;
@property (nonatomic , copy) NSString *RegisterIP;
@property (nonatomic , copy) NSString *RegisterMode;
@property (nonatomic , copy) NSString *RemainCoin;
@property (nonatomic , copy) NSString *RemainPoint;
@property (nonatomic , copy) NSString *ReplyRate;
@property (nonatomic , copy) NSString *ResumeQuota;
@property (nonatomic , copy) NSString *SecondId;
@property (nonatomic , copy) NSString *UnlimitedDate;
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *VerifyCount;
@property (nonatomic , copy) NSString *VerifyResult;
@property (nonatomic , copy) NSString *ViewNumber;
@property (nonatomic , copy) NSString *Zip;
@property (nonatomic , copy) NSString *dcCompanyKindID;
@property (nonatomic , copy) NSString *dcCompanySizeID;
@property (nonatomic , copy) NSString *dcIndustryID;
@property (nonatomic , copy) NSString *dcProvinceID;
@property (nonatomic , copy) NSString *dcRegionID;
@property (nonatomic , copy) NSString *dcSubSiteID;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
