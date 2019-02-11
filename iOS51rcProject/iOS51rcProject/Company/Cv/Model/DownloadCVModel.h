//
//  DownloadCVModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/11.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DownloadCVModel : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *Age;
@property (nonatomic , copy) NSString *BirthDay;
@property (nonatomic , copy) NSString *College;
@property (nonatomic , copy) NSString *Degree;
@property (nonatomic , copy) NSString *DegreeName;
@property (nonatomic , copy) NSString *EduType;
@property (nonatomic , copy) NSString *Experience;
@property (nonatomic , copy) NSString *Gender;
@property (nonatomic , copy) NSString *Graduation;
@property (nonatomic , copy) NSString *HasPhoto;
@property (nonatomic , copy) NSString *HasWeiXin;
@property (nonatomic , copy) NSString *IP;
@property (nonatomic , copy) NSString *IsNameHidden;
@property (nonatomic , copy) NSString *IsOnline;
@property (nonatomic , copy) NSString *LivePlace;
@property (nonatomic , copy) NSString *LivePlaceName;
@property (nonatomic , copy) NSString *MajorName;
@property (nonatomic , copy) NSString *MobileVerifyDate;
@property (nonatomic , copy) NSString *PaPhoto;
@property (nonatomic , copy) NSString *RelatedWorkYears;
@property (nonatomic , copy) NSString *RemainQuota;
@property (nonatomic , copy) NSString *SecondId;
@property (nonatomic , copy) NSString *Speciality;
@property (nonatomic , copy) NSString *TitleID;
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *caOrderID;
@property (nonatomic , copy) NSString *cvEducationID;
@property (nonatomic , copy) NSString *cvMainID;
@property (nonatomic , copy) NSString *dcSalaryID;
@property (nonatomic , copy) NSString *dcSalaryName;
@property (nonatomic , copy) NSString *paMainID;
@property (nonatomic , copy) NSString *paName;
+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
