//
//  AttachmentModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AttachmentModel : NSObject
@property (nonatomic , copy) NSString *Id;
@property (nonatomic , copy) NSString *cvMainID;
@property (nonatomic , copy) NSString *FilePath;
@property (nonatomic , copy) NSString *FileName;
@property (nonatomic , copy) NSString *AddDate;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
