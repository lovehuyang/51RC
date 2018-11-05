#import "Common.h"
#import "CommonMacro.h"
#import <CommonCrypto/CommonDigest.h>
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <CoreText/CoreText.h>

@implementation Common

/**
 ISO时间转普通时间格式

 @param dateString ISO时间串
 @return 处理结果
 */
+ (NSDate *)dateFromString:(NSString *)dateString {
    if ([dateString length] == 10) {
        dateString = [NSString stringWithFormat:@"%@ 00:00:00", dateString];
    }
    if ([dateString length] == 16) {
        dateString = [NSString stringWithFormat:@"%@:00", dateString];
    }
    NSRange indexOfLength = [dateString rangeOfString:@"T" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
    }
    indexOfLength = [dateString rangeOfString:@"+" options:NSCaseInsensitiveSearch];
    if(indexOfLength.length > 0) {
        dateString = [dateString substringToIndex:19];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd HH:mm:ss"];
    NSDate *thisDate = [dateFormatter dateFromString:dateString];
    return thisDate;
}

+ (NSString *)stringFromDate:(NSDate *)date
                 formatType:(NSString *)formatType {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[NSString stringWithFormat:@"%@",formatType]];
    NSString *thisDate = [dateFormatter stringFromDate:date];
    return thisDate;
}

+ (NSString *)stringFromDateString:(NSString *)date
                       formatType:(NSString *)formatType {
    if ([date length] == 10) {
        date = [NSString stringWithFormat:@"%@ 00:00:00", date];
    }
    NSDate *newDate = [self dateFromString:date];
    return [self stringFromDate:newDate formatType:formatType];
}

//检查密码格式
+ (BOOL)checkPassword:(NSString *)password {
    NSString *passwordreg=@"^[a-zA-Z0-9\\-_\\.]+$";
    NSPredicate *passreg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordreg];
    BOOL ispassWordMatch = [passreg evaluateWithObject:password];
    if(!(ispassWordMatch)) {
        return false;
    }
    else {
        return true;
    }
}

//检查密码格式
+ (BOOL)checkCpPassword:(NSString *)password {
    NSString *passwordreg=@"^(?=.*[a-zA-Z])(?=.*\\d)[\\s\\S]{8,16}$";
    NSPredicate *passreg = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordreg];
    BOOL ispassWordMatch = [passreg evaluateWithObject:password];
    if(!(ispassWordMatch)) {
        return false;
    }
    else {
        return true;
    }
}

//验证邮箱
+ (BOOL)checkEmail:(NSString *)email {
    BOOL result = true;
    NSString * regex = @"^([a-zA-Z0-9_\\-\\.]+)@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})(\\]?)$";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    NSString *emailRegex = @"^[\\.\\-_].*$";
    NSPredicate *emailPred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isEmail=[emailPred evaluateWithObject:email];
    BOOL isMatch = [pred evaluateWithObject:email];
    if(!isMatch) {
        result = false;
    }
    if(isEmail) {
        result = false;
    }
    return result;
}

+ (BOOL)checkMobile:(NSString *)mobile {
    //手机号以13， 15，18开头，八个 \d 数字字符
    NSString *phoneRegex = @"^(13[0-9]|14[0-9]|15[0-9]|16[0-9]|17[0-9]|18[0-9]|19[0-9])\\d{8}$";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    BOOL result = [phoneTest evaluateWithObject:mobile];
    return result;
}

+ (NSString *) MD5:(NSString *)signString {
    const char *cStr = [signString UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return[NSString stringWithFormat:
           @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
           result[0], result[1], result[2], result[3],
           result[4], result[5], result[6], result[7],
           result[8], result[9], result[10], result[11],
           result[12], result[13], result[14], result[15]
           ];
}

+ (BOOL)isPureInt:(NSString*)string {
    NSScanner *scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

+ (BOOL)isPureChinese:(NSString *)string {
    for (int i = 0; i < [string length]; i++) {
        int a = [string characterAtIndex:i];
        if (a > 0x4e00 && a < 0x9fff) {
            
        }
        else {
            return NO;
        }
    }
    return YES;
}

+ (void)share:(NSString *)title
      content:(NSString *)content
          url:(NSString *)url
     imageUrl:(NSString *)imageUrl {
    NSArray* imageArray;
    if (imageUrl.length == 0) {
        imageArray = @[[UIImage imageNamed:@"img_defaultlogo.png"]];
    }
    else {
        imageArray = @[[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imageUrl]]]];
    }
    if (imageArray) {
        NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
        [shareParams SSDKSetupShareParamsByText:content
                                         images:imageArray
                                            url:[NSURL URLWithString:url]
                                          title:title
                                           type:SSDKContentTypeAuto];
        [shareParams SSDKEnableUseClientShare];
        
        //微信朋友圈平台
        [shareParams SSDKSetupWeChatParamsByText:title title:content url:[NSURL URLWithString:url] thumbImage:nil image:imageArray musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatTimeline];
        
        [ShareSDK showShareActionSheet:nil
                                 items:nil
                           shareParams:shareParams
                   onShareStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
                       switch (state) {
                           case SSDKResponseStateSuccess:
                           {
                               UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享成功"
                                                message:nil
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil];
                               [alertView show];
                               break;
                           }
                           case SSDKResponseStateFail:
                           {
                               UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"分享失败"
                                         message:[NSString stringWithFormat:@"%@",error]
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil, nil];
                               [alert show];
                               break;
                           }
                           default:
                               break;
                       }
                   }
        ];
    }
}

+ (NSArray *)getArrayFromXml:(GDataXMLDocument *)xmlContent
                   tableName:(NSString *)tableName {
    NSArray *xmlTable = [xmlContent nodesForXPath:[NSString stringWithFormat:@"//%@", tableName] error:nil];
    NSMutableArray *arrXml = [[NSMutableArray alloc] init];
    for (int i = 0; i < xmlTable.count; i++) {
        GDataXMLElement *oneXmlElement = [xmlTable objectAtIndex:i];
        NSArray *arrChild = [oneXmlElement children];
        NSMutableDictionary *dicOneXml = [[NSMutableDictionary alloc] init];
        for (int j=0; j<arrChild.count; j++) {
            [dicOneXml setObject:[arrChild[j] stringValue] forKey:[arrChild[j] name]];
        }
        [arrXml addObject:dicOneXml];
    }
    return arrXml;
}

+ (NSString *)getValueFromXml:(GDataXMLDocument *)xmlContent{

    GDataXMLElement *xmlEle = [xmlContent rootElement];
    
    NSArray *array = [xmlEle children];
    if (array.count > 0) {
        GDataXMLElement *ele = [array firstObject];
        DLog(@"%@",[ele stringValue]);
        return [ele stringValue];
    }else{
        return nil;
    }
    
//    for (int i =0; i < [array count]; i++) {
//        GDataXMLElement *ele = [array objectAtIndex:i];
//        DLog(@"%@",[ele stringValue]);
//        return [ele stringValue];
//    }
    return nil;
}

/**
 处理时间

 @param date ISO格式时间
 @return 处理结果
 */
+ (NSString *)stringFromRefreshDate:(NSString *)date {
    NSDate *d = [self dateFromString:date];
    
    return [self calculateTimeInterval:d];;
}


/**
 计算时间间隔

 @param timeDate 时间
 @return 时间间隔
 */
+ (NSString *)calculateTimeInterval:(NSDate *)timeDate{
    
    //八小时时区
    NSTimeZone *zone = [NSTimeZone systemTimeZone];
    NSInteger interval = [zone secondsFromGMTForDate:timeDate];
    NSDate *mydate = [timeDate dateByAddingTimeInterval:interval];
    NSDate *nowDate = [[NSDate date]dateByAddingTimeInterval:interval];
    //两个时间间隔
    NSTimeInterval timeInterval = [mydate timeIntervalSinceDate:nowDate];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *timeState = nil;
    if (timeInterval<300) {
        timeState = [NSString stringWithFormat:@"刚刚"];
    }else if ((temp = timeInterval/60)<10){
        timeState = @"5分钟";
    }else if ((temp = timeInterval/60)<30){
        timeState = @"10分钟";
    }else if ((temp = timeInterval/60)<60){
        timeState = @"30分钟";
    }else if ((temp = timeInterval/60)<120){
        timeState = @"1小时";
    }else if ((temp = timeInterval/60)<180){
        timeState = @"2小时";
    }else if ((180<=(temp = timeInterval/60)) && [[self compareDate:timeDate] isEqualToString:@"今天"]){
        timeState = @"今天";
    }else if ((180<=(temp = timeInterval/60)) && [[self compareDate:timeDate] isEqualToString:@"昨天"]){
        timeState = @"昨天";
    }else{
        timeState = [self compareDate:timeDate];
    }
    
    return timeState;
}

#pragma mark - 获取今天是几号
+ (NSString *)compareDate:(NSDate *)date{
    
    NSTimeInterval secondsPerDay = 24 * 60 * 60;
    NSDate *today = [[NSDate alloc] init];
    NSDate *tomorrow, *yesterday;
    
    tomorrow = [today dateByAddingTimeInterval: secondsPerDay];
    yesterday = [today dateByAddingTimeInterval: -secondsPerDay];
    
    // 10 first characters of description is the calendar date:
    NSString * todayString = [[today description] substringToIndex:10];
    NSString * yesterdayString = [[yesterday description] substringToIndex:10];
    NSString * tomorrowString = [[tomorrow description] substringToIndex:10];
    
    NSString * dateString = [[date description] substringToIndex:10];
    
    if ([dateString isEqualToString:todayString])
    {
        return @"今天";
    } else if ([dateString isEqualToString:yesterdayString])
    {
        return @"昨天";
    }else if ([dateString isEqualToString:tomorrowString])
    {
        return @"明天";
    }
    else
    {
        return dateString;
    }
}
+ (NSArray *)getTextLines:(NSString *)text font:(UIFont *)font rect:(CGRect)rect {
    CTFontRef myFont = CTFontCreateWithName((__bridge CFStringRef)([font fontName]), [font pointSize], NULL);
    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:text];
    [attStr addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)myFont range:NSMakeRange(0, attStr.length)];
    
    CTFramesetterRef frameSetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)attStr);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0,0,rect.size.width,100000));
    
    CTFrameRef frame = CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, 0), path, NULL);
    
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    NSMutableArray *linesArray = [[NSMutableArray alloc]init];
    
    for (id line in lines)
    {
        CTLineRef lineRef = (__bridge CTLineRef)line;
        CFRange lineRange = CTLineGetStringRange(lineRef);
        NSRange range = NSMakeRange(lineRange.location, lineRange.length);
        NSString *lineString = [text substringWithRange:range];
        [linesArray addObject:lineString];
    }
    return linesArray;
}

+ (float)getLastLineWidth:(UILabel *)label {
    NSString *text = [label text];
    UIFont   *font = [label font];
    CGRect    rect = [label frame];
    NSArray *linesArray = [self getTextLines:text font:font rect:rect];
    NSString *lastLineText = [linesArray objectAtIndex:linesArray.count - 1];
    CGSize sizeLastLine = LABEL_SIZE(lastLineText, rect.size.width, 20, font.pointSize);
    return sizeLastLine.width;
}

+ (void)changeFontSize:(UIView *)parentView {
    for (UIView *view in parentView.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [(UILabel *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UITextField class]]) {
            [(UITextField *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UITextView class]]) {
            [(UITextView *)view setFont:DEFAULTFONT];
        }
        else if ([view isKindOfClass:[UIButton class]]) {
            [[(UIButton *)view titleLabel] setFont:DEFAULTFONT];
        }
        [self changeFontSize:view];
    }
}

+ (NSArray *)querySql:(NSString *)sql dataBase:(FMDatabase *)dataBase {
    Boolean blnCpSalary = NO;
    if ([[sql lowercaseString] rangeOfString:@"dcsalarycp"].location != NSNotFound) {
        blnCpSalary = YES;
        sql = [sql stringByReplacingOccurrencesOfString:@"dcSalaryCp" withString:@"dcSalary"];
    }
    if (dataBase == nil) {
        NSString* dbPath = [[NSBundle mainBundle] pathForResource:@"dictionary.db" ofType:@""];
        dataBase = [FMDatabase databaseWithPath:dbPath];
        [dataBase open];
    }
    FMResultSet *resultSet = [dataBase executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    while ([resultSet next]) {
        [array addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[resultSet stringForColumn:@"_id"], @"id", [resultSet stringForColumn:(blnCpSalary ? @"descriptioncp" : @"description")], @"value", nil]];
    }
    return array;
}

+ (NSString *)getPaPhotoUrl:(NSString *)fileName paMainId:(NSString *)paMainId {
    NSString *path = [NSString stringWithFormat:@"%d",([paMainId intValue] / 100000 + 1) * 100000];
    NSInteger lastLength = 9 - path.length;
    for (int i = 0; i < lastLength; i++) {
        path = [NSString stringWithFormat:@"0%@",path];
    }
    path = [NSString stringWithFormat:@"L%@",path];
    path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@", path, fileName];
    return path;
}

+ (NSArray *)arrayWelfare {
    return [[NSArray alloc] initWithObjects:@"社会保险", @"商业保险", @"公积金", @"年终奖", @"奖金提成", @"全勤奖", @"节日福利", @"双休", @"8小时工作制", @"带薪年假", @"公费培训", @"公费旅游", @"健康体检", @"通讯补贴", @"提供住宿", @"餐补/工作餐", @"住房补贴", @"交通补贴", @"班车接送", nil];
}

+ (NSArray *)arrayWelfareId {
    return [[NSArray alloc] initWithObjects:@"1", @"19", @"2", @"4", @"13", @"14", @"11", @"3", @"9", @"5", @"12", @"6", @"16", @"17", @"10", @"7", @"18", @"8", @"15", nil];
}

+ (NSString *)getWelfare:(NSArray *)arrayWelfareIdSelected {
    NSMutableArray *arrayWelfareSelected = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < self.arrayWelfareId.count; index++) {
        NSInteger welfareId = [[self.arrayWelfareId objectAtIndex:index] integerValue];
        if ([[arrayWelfareIdSelected objectAtIndex:(welfareId - 1)] isEqualToString:@"1"]) {
            [arrayWelfareSelected addObject:[self.arrayWelfare objectAtIndex:index]];
        }
    }
    return [arrayWelfareSelected componentsJoinedByString:@"+"];
}

+ (NSArray *)arrayPush {
    return [[NSArray alloc] initWithObjects:@"周一", @"周二", @"周三", @"周四", @"周五", @"周六", @"周日", nil];
}

+ (NSString *)getPushIdWithBin:(NSString *)pushId {
    pushId = [self toBinarySystemWithDecimalSystem:pushId];
    for (NSInteger i = 7 - pushId.length; i > 0; i--) {
        pushId = [NSString stringWithFormat:@"0%@", pushId];
    }
    return pushId;
}

+ (NSString *)getPush:(NSString *)pushId {
    NSMutableArray *arrayPushSelected = [[NSMutableArray alloc] init];
    for (NSInteger index = 0; index < 7; index++) {
        NSRange range = NSMakeRange(index, 1);
        if ([[pushId substringWithRange:range] isEqualToString:@"1"]) {
            [arrayPushSelected addObject:[self.arrayPush objectAtIndex:index]];
        }
    }
    return [arrayPushSelected componentsJoinedByString:@"+"];
}

+ (NSString *)toBinarySystemWithDecimalSystem:(NSString *)decimal {
    int num = [decimal intValue];
    int remainder = 0;      //余数
    int divisor = 0;        //除数
    NSString * prepare = @"";
    while (true) {
        remainder = num % 2;
        divisor = num / 2;
        num = divisor;
        prepare = [prepare stringByAppendingFormat:@"%d",remainder];
        if (divisor == 0) {
            break;
        }
    }
    NSString * result = @"";
    for (NSInteger i = prepare.length - 1; i >= 0; i --) {
        result = [result stringByAppendingFormat:@"%@", [prepare substringWithRange:NSMakeRange(i , 1)]];
    }
    return result;
}

+ (NSString *)toDecimalSystemWithBinarySystem:(NSString *)binary {
    int ll = 0 ;
    int temp = 0 ;
    for (int i = 0; i < binary.length; i ++) {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    return result;
}

+ (NSString *)getSalary:(NSString *)salaryId salaryMin:(NSString *)salaryMin salaryMax:(NSString *)salaryMax negotiable:(NSString *)negotiable {
    NSString *salary = [NSString stringWithFormat:@"%@-%@", salaryMin, salaryMax];
    if ([salaryId isEqualToString:@"100"]) {
        salary = @"面议";
    }
    else {
        if ([salaryId isEqualToString:@"16"]) {
            salary = [NSString stringWithFormat:@"%@以上", salaryMin];
        }
        if ([negotiable boolValue]) {
            salary = [NSString stringWithFormat:@"%@（可面议）", salary];
        }
    }
    return salary;
}

+ (NSString *)enMobile:(NSString *)mobile {
    mobile = [self toHex:[mobile integerValue]];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"1" withString:@"u"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"2" withString:@"m"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"3" withString:@"z"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"4" withString:@"s"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"5" withString:@"n"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"6" withString:@"x"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"7" withString:@"g"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"8" withString:@"v"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"9" withString:@"j"];
    mobile = [mobile stringByReplacingOccurrencesOfString:@"0" withString:@"t"];
    NSArray *arrInsert = @[@"y", @"l", @"9", @"8", @"h", @"p", @"o", @"5", @"k", @"6", @"1", @"w", @"0", @"2", @"r", @"4", @"7", @"i", @"3", @"q"];
    NSMutableString *enMobile = [[NSMutableString alloc] initWithString:mobile];
    for (NSInteger i = mobile.length; i < 40; i++) {
        int a = arc4random() % (arrInsert.count - 1);
        int b = arc4random() % (enMobile.length - 1);
        [enMobile insertString:arrInsert[a] atIndex:b];
    }
    return enMobile;
}

//将十进制转化为十六进制
+ (NSString *)toHex:(NSInteger)tmpid {
    NSString *nLetterValue;
    NSString *str = @"";
    uint16_t ttmpig;
    for (int i = 0; i < 9; i++) {
        ttmpig = tmpid % 16;
        tmpid = tmpid / 16;
        switch (ttmpig)
        {
            case 10:
                nLetterValue = @"a";
                break;
            case 11:
                nLetterValue = @"b";
                break;
            case 12:
                nLetterValue = @"c";
                break;
            case 13:
                nLetterValue = @"d";
                break;
            case 14:
                nLetterValue = @"e";
                break;
            case 15:
                nLetterValue = @"f";
                break;
            default:
                nLetterValue = [NSString stringWithFormat:@"%u", ttmpig];
        }
        str = [nLetterValue stringByAppendingString:str];
        if (tmpid == 0) {
            break;
        }
    }
    return str;
}

/**
 验证码登录时接口返回的错误码信息

 @param result 返回值
 @return 处理结果
 */
+ (NSString *)verifyCodeLoginResult:(NSInteger)result{
    switch (result) {
        case -11:
            return @"网络链接错误，请稍候重试！";
            break;
        case -99:
            return @"请输入正确的手机号！";
            break;
        case -98:
            return @"请输入已认证的手机号！";
            break;
        case -3:
            return @"该手机号发送短信验证码次数过多！";
            break;
        case -2:
            return @"该ip今天发送短信验证码次数过多！";
            break;
        case -1:
            return @"您的手机号已被列入黑名单，请尝试其他方式登录！";
        case -4:
            return @"您输入手机号获取验证码太频繁，请稍候再试！";
        case -5:
            return @"您在180s内获取过验证码，请稍候重试！";
        case -97:
            return @"获取验证码失败，请稍候重试！";
        case 1:
            return @"获取验证码成功！";
        default:
            return @"未知错误";
            break;
    }
}
@end
