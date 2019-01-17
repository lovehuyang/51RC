//
//  CommonTools.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/1.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CommonTools.h"

@implementation CommonTools

#pragma mark - 获取状态栏的高度

/**
 获取状态栏的高度
 
 @return 状态栏高度
 */
+ (CGFloat)getStatusHight{
    
    CGRect StatusRect = [[UIApplication sharedApplication]statusBarFrame];
    return StatusRect.size.height;
}

/**
 获取状态栏和导航栏的高度
 
 @return 状态栏和导航栏的高度
 */
+ (CGFloat)getStatusAndNavHight{
    
    return  [self getStatusHight] + 44;
}

/**
 读取百度语音配置参数
 
 @return 参数值
 */
+ (NSString *)getBDSASRParameter:(NSString *)param{
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"BDSASRParameter" ofType:@"plist"];
    NSDictionary *paramDict = [[NSDictionary alloc]initWithContentsOfFile:plistPath];
    return paramDict[param];
}


/**
 把json字符串转成字典

 @param jsonStr json字符串
 @return 字典
 */
+ (NSDictionary *)translateJsonStrToDictionary:(NSString *)jsonStr{
    NSData *jsonData = [jsonStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    return resultDict;
}

#pragma mark - 判断是不是完整简历
// 简历等级，显示在简历列表等位置(1存在简历，2基本信息，3教育背景，4工作经历，5工作能力，6求职意向，7语言能力，8培训经历，9项目经历，10证书附件)前3个1 第6个是1表示完整

/**
 判断是不是完整简历

 @param cvlevel 简历等级的字符串
 @return yes完整简历，no不完整简历
 */
+ (BOOL)cvIsFull:(NSString *)cvlevel{
    if (cvlevel.length < 6 || cvlevel == nil) {
        return NO;
    }
    //11100122
    BOOL tempBool = YES;
    for(int i =0; i < [cvlevel length]; i++){
        NSString *tempStr = [cvlevel substringWithRange:NSMakeRange(i, 1)];
        if (i == 0 || i == 1 || i == 2 || i == 5) {
            tempBool = tempBool && [tempStr isEqualToString:@"1"];
        }
    }
    return tempBool;
}

#pragma mark - 时间转换

/**
 时间格式转化
 
 @param date 时间字符串
 @return 转换完的形式
 */
+ (NSString *)changeDateWithDateString:(NSString *)date{
    if ([date containsString:@"."]) {
        return [CommonTools changeDateWithDateString1:date];
    }else{
        return [CommonTools changeDateWithDateString2:date];
    }
}

/**
 时间格式转换
 
 @param date date的形式 2019-01-07T09:43:58.233+08:00
 @return 转换结果 2019-01-04 17:54
 */
+ (NSString *)changeDateWithDateString1:(NSString *)date{
    //2019-01-07T09:43:58.233+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}

/**
 时间格式转换
 
 @param date date的形式2019-01-04T17:54:00+08:00
 @return 转换结果 2019-01-04 17:54
 */
+ (NSString *)changeDateWithDateString2:(NSString *)date{
    //2019-01-04T17:54:00+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}


/**
 随机获取分享内容

 @param JobPlaceName 期望工作地点
 @return 分享内容
 */
+ (NSString *)shareContent:(NSString *)JobPlaceName{
    
    NSMutableArray *shareContentArr = [NSMutableArray array];
    // 获取网站名称
    NSString *webSiteName =  [USER_DEFAULT objectForKey:@"subsitename"];
    NSString *shareContentStr1 = [NSString stringWithFormat:@"亲，用过%@找工作么？新增一大波招聘信息，快来看。",webSiteName];
    NSString *shareContentStr2 = [NSString stringWithFormat:@"听说朋友圈里有人在找工作？推荐%@。",webSiteName];
    [shareContentArr addObject:shareContentStr1];
    [shareContentArr addObject:shareContentStr2];
    
   
    if (JobPlaceName != nil && JobPlaceName.length > 0) {
        NSString *shareContentSre3 = [NSString stringWithFormat:@"%@找工作的你，快来%@，好多高薪岗位在招聘。",JobPlaceName,webSiteName];
        [shareContentArr addObject:shareContentSre3];
    }
    
    int index = arc4random() % shareContentArr.count ;
    
    return [shareContentArr objectAtIndex:index];
    
    /*
     1.亲，用过webSiteName找工作么？新增一大波招聘信息，快来看。
     2.听说朋友圈里有人在找工作？推荐webSiteName。
     3.city找工作的你，快来webSiteName，好多高薪岗位在招聘。
     webSiteName：XX人才网，如：齐鲁人才网
     city：从简历列表页面传递过来的城市名，取得jobPlaceName这个字段的值
     */
    
}
@end
