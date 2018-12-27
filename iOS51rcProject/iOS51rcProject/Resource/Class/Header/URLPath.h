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

// 获取用户基本信息
#define URL_GETPAMAIN @"GetPaMain"
// 投诉
#define URL_SAVECOMPLAIN @"SaveComplaints"
// 验证码登录方式获取验证码
#define URL_GETPAMOBILEVERIFYCODELOGIN @"GetPaMobileVerifyCodeLogin"
// 获取验证码
#define URL_GETPAMOBILEVERIFYCODE @"GetPaMobileVerifyCode"
// 一分钟完成简历页面获取验证码
#define URL_GETMOBILECERCODE @"GetMobileCerCode"
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
// 删除附件简历
#define URL_DELETECVATTACHMENT @"deleteCvAttachment"
// 一分钟填写简历
#define URL_SAVEONEMINUTE20180613NEW @"SaveOneMinute20180613New"
// 获取手机号码归属地
#define URL_GETIPMOBILEPLACE @"GetIpMobilePlace"
// 根据语音获取职位类别
#define URL_GETCVVOICEJOBTYPE @"GetCvVoiceJobType"
// 推荐职位立即申请接口
#define URL_INSERTJOBAPPLY @"InsertJobApply"



#pragma mark - 公司用户

// 获取公司最近发布的福利待遇信息
#define URL_GETJOBWELFAREBYCAMAINID @"GetJobWelfareByCamainID"
// 获取平均工资
#define URL_GETSALARYJOBSTRING @"genSalaryJobString"

#endif /* URLPath_h */
