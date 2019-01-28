//
//  SpeechViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/3.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "WKViewController.h"

@interface SpeechViewController : WKViewController
@property (nonatomic , assign) BOOL mobileVerify;// 手机号是否通过了验证
@property (nonatomic , copy) NSArray *dataArr;// 数据源

// 说话内容的结果回调
@property (nonatomic , copy) void(^speakContentBlock)(NSDictionary *dict);
// 重置上层页面请求参数
@property (nonatomic , copy) void (^speakRestParam)(NSString *key , NSString *value);

@end
