//
//  CommonMacro.h
//  SCNavTabBarController
//
//  Created by ShiCang on 14-4-23.
//  Copyright (c) 2014年 SCNavTabBarController. All rights reserved.
//

#ifndef ___CommonMacro_h
#define ___CommonMacro_h


#pragma mark - **** Common Macro ****
#pragma mark -

#import "AppDelegate.h"

#define APP_DELEGATE_INSTANCE                       ((AppDelegate*)([UIApplication sharedApplication].delegate))
#define USER_DEFAULT                                [NSUserDefaults standardUserDefaults]
#define MAIN_STORY_BOARD(Name)                      [UIStoryboard storyboardWithName:Name bundle:nil]
#define NS_NOTIFICATION_CENTER                      [NSNotificationCenter defaultCenter]


#pragma mark - 机型判断
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define IS_OS_5_OR_LATER                            SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"5.0")
#define IS_OS_6_OR_LATER                            SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0")
#define IS_OS_7_OR_LATER                            SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")

#define IS_WIDESCREEN_4                            (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)480) < __DBL_EPSILON__)
#define IS_WIDESCREEN_5                            (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)568) < __DBL_EPSILON__)
#define IS_WIDESCREEN_6                            (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)667) < __DBL_EPSILON__)
#define IS_WIDESCREEN_6Plus                        (fabs((double)[[UIScreen mainScreen] bounds].size.height - (double)736) < __DBL_EPSILON__)
#define IS_IPHONE                                  ([[[UIDevice currentDevice] model] isEqualToString: @"iPhone"] || [[[UIDevice currentDevice] model] isEqualToString: @"iPhone Simulator"])
#define IS_IPOD                                    ([[[UIDevice currentDevice] model] isEqualToString: @"iPod touch"])
#define IS_IPHONE_4                                (IS_IPHONE && IS_WIDESCREEN_4)
#define IS_IPHONE_5                                (IS_IPHONE && IS_WIDESCREEN_5)
#define IS_IPHONE_6                                (IS_IPHONE && IS_WIDESCREEN_6)
#define IS_IPHONE_6Plus                            (IS_IPHONE && IS_WIDESCREEN_6Plus)

#pragma mark - 屏幕尺寸
#define SCREEN_WIDTH                    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT                   ([UIScreen mainScreen].bounds.size.height)

#pragma mark - 字体相关
#define FONT(s)                         [UIFont systemFontOfSize:s]
#define SMALLERFONTSIZE                 IS_IPHONE_6Plus ? 12 : 10
#define SMALLERFONT                     FONT(SMALLERFONTSIZE)
#define DEFAULTFONTSIZE                 IS_IPHONE_6Plus ? 14 : 12
#define DEFAULTFONT                     FONT(DEFAULTFONTSIZE)
#define BIGGERFONTSIZE                  IS_IPHONE_6Plus ? 16 : 14
#define BIGGERFONT                      FONT(BIGGERFONTSIZE)
#define BIGGESTFONTSIZE                 IS_IPHONE_6Plus ? 18 : 16
#define BIGGESTFONT                     FONT(BIGGESTFONTSIZE)

#define DOT_COORDINATE                  0.0f
#define STATUS_BAR_HEIGHT               (SCREEN_HEIGHT == 812.0 ? 44.0f : 20.0f)
#define BAR_ITEM_WIDTH_HEIGHT           30.0f
#define NAVIGATION_BAR_HEIGHT           (SCREEN_HEIGHT == 812.0 ? 68.0f : 44.0f)
#define SCNAV_BAR_HEIGHT                44.0f
#define TAB_BAR_HEIGHT                  49.0f
#define KEYBOARD_HEIGHT                 300.0f
#define TABLE_VIEW_ROW_HEIGHT           NAVIGATION_BAR_HEIGHT
#define CONTENT_VIEW_HEIGHT_NO_TAB_BAR  (SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT)
#define CONTENT_VIEW_HEIGHT_TAB_BAR     (CONTENT_VIEW_HEIGHT_NO_TAB_BAR - TAB_BAR_HEIGHT)

#define UIColorFromRGB(rgbValue)        [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0f green:((float)((rgbValue & 0xFF00) >> 8))/255.0f blue:((float)(rgbValue & 0xFF))/255.0f alpha:1.0f]//RGB颜色
#define UIColorFromHex(hex) [UIColor colorWithHex:hex]// 十六进制颜色
#define UIColorWithRGBA(r,g,b,a)        [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define NAVBARCOLOR                     UIColorWithRGBA(255, 80, 0, 1)
#define CPNAVBARCOLOR                   UIColorWithRGBA(101, 39, 197, 1)
#define TEXTGRAYCOLOR                   UIColorWithRGBA(96, 96, 96, 1)
#define SEPARATECOLOR                   UIColorWithRGBA(243, 243, 243, 1)
#define GREENCOLOR                      UIColorWithRGBA(1, 184, 35, 1)
#define IFISNIL(v)                      (v = (v != nil) ? v : @"")
#define IFISNILFORNUMBER(v)             (v = (v != nil) ? v : [NSNumber numberWithInt:0])
#define IFISSTR(v)                      (v = ([v isKindOfClass:[NSString class]]) ? v : [NSString stringWithFormat:@"%@",v])



#pragma mark - **** Constants ****
#pragma mark -
#define SCNavTabbarBundleName           @"SCNavTabBar.bundle"

#define SCNavTabbarSourceName(file)     [SCNavTabbarBundleName stringByAppendingPathComponent:file]
#define LABEL_SIZE(c,w,h,f)             ([c boundingRectWithSize:CGSizeMake(w,h) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:f]} context:nil].size)

//得到视图的left top的X,Y坐标点
#define VIEW_TX(view)                   (view.frame.origin.x)
#define VIEW_TY(view)                   (view.frame.origin.y)

//得到视图的right bottom的X,Y坐标点
#define VIEW_BX(view)                   (view.frame.origin.x + view.frame.size.width)
#define VIEW_BY(view)                   (view.frame.origin.y + view.frame.size.height)

//得到视图的尺寸:宽度、高度
#define VIEW_W(view)                    (view.frame.size.width)
#define VIEW_H(view)                    (view.frame.size.height)

//得到视图的X,Y坐标点
#define VIEW_X(view)                    (view.frame.origin.x)
#define VIEW_Y(view)                    (view.frame.origin.y)

#define LOADINGTAG                      999
#define POPVIEWTAG                      998
#define POPVIEWCONTENTTAG               995
#define POPBACKGROUNDVIEWTAG            997
#define NODATAVIEWTAG                   996


#define PAMAINID                        ([[USER_DEFAULT valueForKey:@"paMainId"] length] == 0 ? @"0" : [USER_DEFAULT valueForKey:@"paMainId"])
#define PERSONLOGIN                     ![PAMAINID isEqualToString:@"0"]

#define CAMAINID                        ([[USER_DEFAULT valueForKey:@"caMainId"] length] == 0 ? @"0" : [USER_DEFAULT valueForKey:@"caMainId"])
#define CPMAINID                        ([[USER_DEFAULT valueForKey:@"cpMainId"] length] == 0 ? @"0" : [USER_DEFAULT valueForKey:@"cpMainId"])
#define CAMAINCODE                        ([[USER_DEFAULT valueForKey:@"caMainCode"] length] == 0 ? @"0" : [USER_DEFAULT valueForKey:@"caMainCode"])
#define COMPANYLOGIN                    ![CAMAINID isEqualToString:@"0"]
#endif

#define WeakSelfRC(type)  __weak typeof(type) weak##type = type;// 弱引用
#define StrongSelfRC(type)  __strong typeof(type) type = weak##type;// 强引用

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
