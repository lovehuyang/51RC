//
//  ApplyCvListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ApplyCvListModel : NSObject
@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *Age;
@property (nonatomic , copy) NSString *ApplyMessage;
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
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *IsNameHidden;
@property (nonatomic , copy) NSString *IsOnline;
@property (nonatomic , copy) NSString *IsViewed;
@property (nonatomic , copy) NSString *JobID;
@property (nonatomic , copy) NSString *JobName;
@property (nonatomic , copy) NSString *JobRegion;
@property (nonatomic , copy) NSString *JobRegionName;
@property (nonatomic , copy) NSString *LivePlace;
@property (nonatomic , copy) NSString *LivePlaceName;
@property (nonatomic , copy) NSString *MajorName;
@property (nonatomic , copy) NSString *MobileVerifyDate;
@property (nonatomic , copy) NSString *PaPhoto;
@property (nonatomic , copy) NSString *RelatedWorkYears;
@property (nonatomic , copy) NSString *Reply;
@property (nonatomic , copy) NSString *ReplyDate;
@property (nonatomic , copy) NSString *SecondId ;
@property (nonatomic , copy) NSString *Speciality;
@property (nonatomic , copy) NSString *TitleID;
@property (nonatomic , copy) NSString *Valid;
@property (nonatomic , copy) NSString *cvEducationID;
@property (nonatomic , copy) NSString *cvMainID;
@property (nonatomic , copy) NSString *cvMatch;
@property (nonatomic , copy) NSString *paMainID;
@property (nonatomic , copy) NSString *paName;
@property (nonatomic , copy) NSString *RemindDate;

+ (id)buildModelWithDic:(NSDictionary *)dic;

@end
