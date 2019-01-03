//
//  CVTicketModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CVTicketModel : NSObject
/*
 disType标识是否领取：0未领取  1已领取
 discountType：1拼手气代金券   2固定额度代金券
 */
@property (nonatomic , copy)NSString *disEndDate;
@property (nonatomic , copy)NSString *disStartDate;
@property (nonatomic , copy)NSString *disType;
@property (nonatomic , copy)NSString *discountMoney;
@property (nonatomic , copy)NSString *disRule;
@property (nonatomic , copy)NSString *discountType;
+ (id)buildModelWithDic:(NSDictionary *)dic;
@end
