//
//  OrderListModel.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderListModel : NSObject
@property (nonatomic , copy) NSString *CvName;
@property (nonatomic , copy) NSString *DiscountMoney;
@property (nonatomic , copy) NSString *OrderMoney;
@property (nonatomic , copy) NSString *addDate;
@property (nonatomic , copy) NSString *beginDate;
@property (nonatomic , copy) NSString *cvOrderName;
@property (nonatomic , copy) NSString *cvTopStatus;
@property (nonatomic , copy) NSString *endDate;
@property (nonatomic , copy) NSString *orderService;
@property (nonatomic , copy) NSString *orderType;
@property (nonatomic , copy) NSString *paOrderDiscountID;
@property (nonatomic , copy) NSString *payMethod;
@property (nonatomic , copy) NSString *payOrderNum;
@property (nonatomic , copy) NSString *receiveDate;

+ (id)buildModelWithDic:(NSDictionary *)dic;

@end
