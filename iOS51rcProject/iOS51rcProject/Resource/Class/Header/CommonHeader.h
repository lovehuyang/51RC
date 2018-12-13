//
//  CommonHeader.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#ifndef CommonHeader_h
#define CommonHeader_h

#define HEIGHT_STATUS [CommonTools getStatusHight]
#define HEIGHT_STATUS_NAV [CommonTools getStatusAndNavHight]

#define PROPERTY_COPY(str) @property (nonatomic , copy)NSString *str

#define NOTIFICATION_GETCVLIST @"GetCvList"// 个人用户 - 获取简历列表
#define NOTIFICATION_GETJOBLISTBYSEARCH @"GetJobListBySearch"// 登录成功→一分钟简历完成→首页获取匹配的职位
#define NOTIFICATION_ONEMINUTEGETVERIFYCODE @"OneMinuteGetVerifyCode"// 一分钟填写简历页面获取验证码 
#define NOTIFICATION_PALOGINSUCCESS @"paLoginSuccess"// 个人用户登陆成功

// 百度语音相关参数
#define BD_APP_ID [CommonTools getBDSASRParameter:@"APP_ID"]
#define BD_SECRET_KEY [CommonTools getBDSASRParameter:@"SECRET_KEY"]
#define BD_API_KEY [CommonTools getBDSASRParameter:@"API_KEY"]

#endif /* CommonHeader_h */
