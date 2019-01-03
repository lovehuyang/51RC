//
//  CVTopPackageModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVTopPackageModel : NSObject

@property (nonatomic , copy)NSString *discount;
@property (nonatomic , copy)NSString *nowPrice;
@property (nonatomic , copy)NSString *orderName;
@property (nonatomic , copy)NSString *orderService;
@property (nonatomic , copy)NSString *rawPrice;

+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
