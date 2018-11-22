//
//  AFNManager.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AFNManager.h"
#import <AFNetworking.h>
#import "Reachability.h"
#import "Common.h"
#import "GDataXMLNode.h"
#import "Common.h"

@interface AFNManager()<NSXMLParserDelegate>

@end

@implementation AFNManager

+(NSURLSessionDataTask *)requestWithMethod:(RequestMethod)method ParamDict:(NSDictionary *)paramDict url:(NSString *)url tableName:(NSString *)tableName successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    
    // 判断是否有网络链接
    if(![[self alloc] isConnectionAvailable])
    {
        failureBlock(0,@"您已断开网络链接！");
        return nil;
    }
    
    NSString *WebURL = @"http://webservice.51rc.com/app3/appwebservice.asmx";
    NSString *nameSpace = @"http://www.51rc.com/";
    NSString *soapParam = @"";
    for (id key in paramDict) {
        soapParam = [NSString stringWithFormat:@"%@<%@>%@</%@>\n",soapParam,key,[paramDict objectForKey:key],key];
    }
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "%@"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", url, nameSpace, soapParam, url
                         ];

    // 请求地址
    NSString * urlString = [NSString stringWithFormat:@"%@",WebURL];
    // 请求类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",nil];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%zd", soapMsg.length] forHTTPHeaderField:@"Content-Length"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    // 设置HTTPBody
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMsg;
    }];
    if(method == POST){
        NSURLSessionDataTask *task = [manager POST:urlString parameters:paramDict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *xmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
            NSArray *arrayPaMain = [Common getArrayFromXml:xmlDoc tableName:tableName];
            if (arrayPaMain.count > 0) {
                successBlock(arrayPaMain, arrayPaMain[0]);
            }else{
                NSString *value = [Common getValueFromXml:xmlDoc];
                successBlock(arrayPaMain, value);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error.code ,@"网络请求失败，请重试");
        }];
        return task;
        
    }else{
        
        NSURLSessionDataTask *task =[manager GET:urlString parameters:paramDict progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *xmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
            NSArray *arrayPaMain = [Common getArrayFromXml:xmlDoc tableName:tableName];
            successBlock(arrayPaMain, arrayPaMain[0]);
            
            DLog(@"");
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureBlock(error.code,@"网络请求失败，请稍后重试");
        }];
        
        return task;
    }
}
+(NSURLSessionDataTask *)requestCpWithMethod:(RequestMethod)method ParamDict:(NSDictionary *)paramDict url:(NSString *)url tableName:(NSString *)tableName successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    
    
    // 判断是否有网络链接
    if(![[self alloc] isConnectionAvailable])
    {
        failureBlock(0,@"您已断开网络链接！");
        return nil;
    }
    
    NSString *WebURL = @"http://webservice.51rc.com/app3/appwebservicecp.asmx";
    NSString *nameSpace = @"http://www.51rc.com/";
    NSString *soapParam = @"";
    for (id key in paramDict) {
        soapParam = [NSString stringWithFormat:@"%@<%@>%@</%@>\n",soapParam,key,[paramDict objectForKey:key],key];
    }
    NSString *soapMsg = [NSString stringWithFormat:
                         @"<?xml version=\"1.0\" encoding=\"utf-8\"?>\n"
                         "<soap:Envelope xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:xsd=\"http://www.w3.org/2001/XMLSchema\" xmlns:soap=\"http://schemas.xmlsoap.org/soap/envelope/\">\n"
                         "<soap:Body>\n"
                         "<%@ xmlns=\"%@\">\n"
                         "%@"
                         "</%@>\n"
                         "</soap:Body>\n"
                         "</soap:Envelope>\n", url, nameSpace, soapParam, url
                         ];
    
    // 请求地址
    NSString * urlString = [NSString stringWithFormat:@"%@",WebURL];
    // 请求类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",nil];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%zd", soapMsg.length] forHTTPHeaderField:@"Content-Length"];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    // 设置HTTPBody
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMsg;
    }];
    if(method == POST){
        NSURLSessionDataTask *task = [manager POST:urlString parameters:paramDict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *xmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
            NSArray *arrayPaMain = [Common getArrayFromXml:xmlDoc tableName:tableName];
            if (arrayPaMain.count > 0) {
                successBlock(arrayPaMain, arrayPaMain[0]);
            }else{
                NSString *value = [Common getValueFromXml:xmlDoc];
                successBlock(arrayPaMain, value);
            }
            
            DLog(@"");
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error.code ,@"网络请求失败，请重试");
        }];
        return task;
        
    }else{
        
        NSURLSessionDataTask *task =[manager GET:urlString parameters:paramDict progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSString *xmlStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSError *error = nil;
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:xmlStr options:0 error:&error];
            NSArray *arrayPaMain = [Common getArrayFromXml:xmlDoc tableName:tableName];
            successBlock(arrayPaMain, arrayPaMain[0]);
            
            DLog(@"");
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureBlock(error.code,@"网络请求失败，请稍后重试");
        }];
        
        return task;
    }
}
/**
 *  网络判断
 *
 *  @return 是否可以联网
 */
- (BOOL)isConnectionAvailable{
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.baidu.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:                      //无网络(无法判断内外网)
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:                  //WIFI
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:                  //流量
            isExistenceNetwork = YES;
            break;
    }
    
    return isExistenceNetwork;
}
@end
