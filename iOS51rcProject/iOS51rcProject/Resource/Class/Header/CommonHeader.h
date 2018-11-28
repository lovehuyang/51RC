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

#define NOTIFICATION_GETCVLIST @"GetCvList"// 个人用户 - 点击“简历”tabbar刷新页面数据
#define NOTIFICATION_ONEMINUTEGETVERIFYCODE @"OneMinuteGetVerifyCode"// 一分钟填写简历页面获取验证码
#endif /* CommonHeader_h */
