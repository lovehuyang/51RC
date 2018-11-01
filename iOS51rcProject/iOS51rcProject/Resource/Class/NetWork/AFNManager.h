//
//  AFNManager.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 请求方式
 
 - POST: POST
 - GET: GET
 - DELETE: DELETE
 - UPLOAD: UPLOAD
 */
typedef NS_ENUM(NSInteger ,RequestMethod) {
    POST ,
    GET,
    DELETE,
    UPLOAD,
};

/**
 请求成功的回调
 
 @param requestData 请求shuju
 @param dataDict 数据
 */
typedef void(^SuccessBlock) (id requestData, NSDictionary *dataDict);

/**
 请求失败的block
 
 @param errCode 错误代码
 @param msg 错误信息
 */
typedef void(^FailureBlock) (NSInteger errCode , NSString *msg);
@interface AFNManager : NSObject

/**
 网络请求统一接口
 
 @param method 请求方式
 @param paramDict 参数字典
 @param url 请求地址
 @param successBlock 成功回调
 @param failureBlock 失败的回调
 */
+(void)requestWithMethod:(RequestMethod)method ParamDict:(NSDictionary *)paramDict url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock;

@end
