//
//  CpAttentionModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CpAttentionModel : NSObject

@property (nonatomic , copy) NSString *AddDate;
@property (nonatomic , copy) NSString *CompanySizeName;
@property (nonatomic , copy) NSString *CpMainID;
@property (nonatomic , copy) NSString *CpSecondID;
@property (nonatomic , copy) NSString *DcCompanyKindID;
@property (nonatomic , copy) NSString *DcCompanyKindName;
@property (nonatomic , copy) NSString *ID;
@property (nonatomic , copy) NSString *Industry;
@property (nonatomic , copy) NSString *LogoUrl;
@property (nonatomic , copy) NSString *Name;
@property (nonatomic , copy) NSString *PaMainID;
@property (nonatomic , copy) NSString *SortDate;

+ (CpAttentionModel *)buideModel:(NSDictionary *)dic;
@end
