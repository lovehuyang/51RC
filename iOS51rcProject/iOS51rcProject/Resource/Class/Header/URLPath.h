//
//  URLPath.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#ifndef URLPath_h
#define URLPath_h

#pragma mark - 个人用户

// 投诉
#define URL_SAVECOMPLAIN @"SaveComplaints"
// 验证码登录方式获取验证码
#define URL_GETPAMOBILEVERIFYCODELOGIN @"GetPaMobileVerifyCodeLogin"
// 验证码登录
#define URL_LOGINMOBILE @"LoginMobile"
// 账户密码登录
#define URL_LOGIN @"Login"
// 屏蔽设置页面
#define URL_HIDENCONDITIONS @"SelectPaMainByHideConditions"
// 添加屏蔽关键词
#define URL_UPDATEHIDNCONDITION @"UpdatePaMainByHideConditions"
// 删除关键词
#define URL_DELETEHIDECONDITIONS @"DeletePaMainByHideConditions"
// 删除申请的职位
#define URL_DELETEJOBAPPLY @"DeleteJobApply"
// 上传附件简历
#define URL_UPLOADCVANNEX @"UploadCvAnnex"
// 获取附件简历列表
#define URL_GETCVATTACHMENTLIST @"GetCvAttachmentList"



#pragma mark - 公司用户

// 获取公司最近发布的福利待遇信息
#define URL_GETJOBWELFAREBYCAMAINID @"GetJobWelfareByCamainID"
// 获取平均工资
#define URL_GETSALARYJOBSTRING @"genSalaryJobString"

#endif /* URLPath_h */
