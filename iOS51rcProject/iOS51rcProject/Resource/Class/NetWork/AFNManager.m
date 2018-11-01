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

@interface AFNManager()<NSXMLParserDelegate>

@end

@implementation AFNManager

+(void)requestWithMethod:(RequestMethod)method ParamDict:(NSDictionary *)paramDict url:(NSString *)url successBlock:(SuccessBlock)successBlock failureBlock:(FailureBlock)failureBlock{
    
    // 判断是否有网络链接
    if(![[self alloc] isConnectionAvailable])
    {
        failureBlock(0,@"您已断开网络链接！");
        return;
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
    NSLog(@"%@",soapMsg);
    
    
    // 请求地址
    NSString * urlString = [NSString stringWithFormat:@"%@",WebURL];
    // 请求类
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFXMLParserResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/xml",nil];
    [manager.requestSerializer setValue:@"text/xml; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    [manager.requestSerializer setValue:[NSString stringWithFormat:@"%zd", soapMsg.length] forHTTPHeaderField:@"Content-Length"];

    // 设置HTTPBody
    [manager.requestSerializer setQueryStringSerializationWithBlock:^NSString *(NSURLRequest *request, NSDictionary *parameters, NSError *__autoreleasing *error) {
        return soapMsg;
    }];
    if(method == POST){
        [manager POST:urlString parameters:paramDict progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSXMLParser *parser = (NSXMLParser *)responseObject;
            [[self alloc] xmlParser:parser];
            DLog(@"");

        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
            failureBlock(error.code ,@"网络请求失败，请稍后重试");
        }];
        
    }else{
        
        [manager GET:urlString parameters:paramDict progress:^(NSProgress * _Nonnull downloadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // 统一处理请求数据
//            [self dealwithreturnDataWithRequestData:responseObject successBlock:successBlock faileBlock:failureBlock];
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            failureBlock(error.code,@"网络请求失败，请稍后重试");
        }];
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


#pragma mark - 解析xml数据
- (void)xmlParser:(NSXMLParser *)parser{
    parser.delegate = self;
    [parser parse];
}
//1.开始解析XML文档的时候
-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    NSLog(@"%s",__func__);
}

//2.开始解析某个元素
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict
{
    NSLog(@"开始解析%@---%@",elementName,attributeDict);
    //过滤根元素
    if ([elementName isEqualToString:@"Table"]) {
        
        return;
    }
    
    // attributeDict中存放的是XML文档元素中的内容，以字典的形式
    //字典转模型
    //    [self.videos addObject:[XMGVideo mj_objectWithKeyValues:attributeDict]];
}

//3.某个元素解析完毕
-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:@"Table"]) {
        
        return;
    }
    NSLog(@"结束解析%@",elementName);
}

//4.结束解析
-(void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"%s",__func__);
}


@end
