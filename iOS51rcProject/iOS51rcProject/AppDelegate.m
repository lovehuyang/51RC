//
//  AppDelegate.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/5/31.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKConnector/ShareSDKConnector.h>
#import "WXApi.h"
#import "GuideViewController.h"
#import "CommonMacro.h"
#import "JobApplyViewController.h"
#import "InterviewViewController.h"
#import "ApplyInvitationViewController.h"
#import "CpViewViewController.h"
#import "WKNavigationController.h"
#import "YourFoodViewController.h"
#import "AttentionViewController.h"
#import "JobViewController.h"
#import "ApplyCvViewController.h"
#import "ChatListCpViewController.h"
#import "CvRecommendViewController.h"
#import "InterviewCpViewController.h"
#import "IQKeyboardManager.h"

@interface AppDelegate ()<JPUSHRegisterDelegate, UIAlertViewDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // 打开键盘事件响应
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].shouldResignOnTouchOutside = YES;
//    //将字典存入到document内
//    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES);
//    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:@"dictionary.db"];
//    NSFileManager *file = [NSFileManager defaultManager];
//    if (![file fileExistsAtPath:dbPath]) {
//        NSString *originDbPath = [[NSBundle mainBundle] pathForResource:@"dictionary.db" ofType:nil];
//        NSData *mainBundleFile = [NSData dataWithContentsOfFile:originDbPath];
//        [file createFileAtPath:dbPath contents:mainBundleFile attributes:nil];
//    }
    
    [MBProgressHUD initAnimationGif];
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        // 可以添加自定义categories
        // NSSet<UNNotificationCategory *> *categories for iOS10 or later
        // NSSet<UIUserNotificationCategory *> *categories for iOS8 and iOS9
    }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    [JPUSHService setupWithOption:launchOptions appKey:@"d7e69473284f92c20a3ef0cb"
                          channel:@"AppStore"
                 apsForProduction:0];
    
    [ShareSDK registerApp:@"2fb76b87ccc8"
          activePlatforms:@[
                            @(SSDKPlatformTypeWechat),
                            @(SSDKPlatformTypeSMS)]
                 onImport:^(SSDKPlatformType platformType) {
         switch (platformType) {
             case SSDKPlatformTypeWechat:
                 [ShareSDKConnector connectWeChat:[WXApi class]];
                 break;
             default:
                 break;
         }
     }
          onConfiguration:^(SSDKPlatformType platformType, NSMutableDictionary *appInfo) {
         switch (platformType) {
             case SSDKPlatformTypeWechat:
                 [appInfo SSDKSetupWeChatByAppId:@"wx06c592bc41506c42"
                    appSecret:@"fbec1762caec172c2e9250394ef3a5ad"];
                 break;
             default:
                 break;
         }
     }];
    
    //百度地图
    self.mapManager = [[BMKMapManager alloc] init];
    BOOL ret = [self.mapManager start:@"Ss6K1KKgF2WSOSSMGEdq8n6Z4uNjh0CW" generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    else {
        NSLog(@"manager start success!");
    }
    
    if ([[USER_DEFAULT objectForKey:@"provinceId"] length] == 0) {
        [USER_DEFAULT setValue:@"32" forKey:@"provinceId"];
        [USER_DEFAULT setValue:@"山东" forKey:@"province"];
        [USER_DEFAULT setValue:@"m.qlrc.com" forKey:@"subsite"];
        [USER_DEFAULT setValue:@"齐鲁人才网" forKey:@"subsitename"];
        [USER_DEFAULT setValue:@"0" forKey:@"positioned"];
    }
    //[USER_DEFAULT removeObjectForKey:@"caMainId"];
    //[USER_DEFAULT setObject:@"2" forKey:@"userType"];
    if ([[USER_DEFAULT objectForKey:@"userType"] length] == 0) {
        GuideViewController *guideCtrl = [[GuideViewController alloc] init];
        self.window.rootViewController = guideCtrl;
    }
    else if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"1"]) {
        if (!PERSONLOGIN) {
            UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
            self.window.rootViewController = loginCtrl;
        }
        else {
            UITabBarController *personCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"personView"];
            self.window.rootViewController = personCtrl;
        }
    }
    else if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        if (!COMPANYLOGIN) {
            UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
            self.window.rootViewController = loginCtrl;
        }
        else {
            UITabBarController *companyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"companyView"];
            [companyCtrl setSelectedIndex:4];
            self.window.rootViewController = companyCtrl;
        }
    }
    return YES;
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [application setApplicationIconBadgeNumber:0];
    /// Required - 注册 DeviceToken
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark- JPUSHRegisterDelegate

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    // Required
    NSDictionary * userInfo = notification.request.content.userInfo;
    [self doNotification:userInfo];
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    // Required
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    [self doNotification:userInfo];
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
    }
    completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    [self doNotification:userInfo];
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}

- (void)doNotification:(NSDictionary *)userInfo {
    // 取得 APNs 标准信息内容
    NSDictionary *aps = [userInfo valueForKey:@"aps"];
    NSString *content = [aps valueForKey:@"alert"]; //推送显示的内容
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提醒" message:content delegate:self cancelButtonTitle:@"知道啦" otherButtonTitles:@"点击查看", nil];
    [alertView show];
    [USER_DEFAULT setObject:userInfo forKey:@"pushUserInfo"];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        if ([USER_DEFAULT objectForKey:@"pushUserInfo"] == nil) {
            return;
        }
        NSDictionary *userInfo = [USER_DEFAULT objectForKey:@"pushUserInfo"];
        NSString *pushType = [userInfo objectForKey:@"PushType"];
        NSString *detailId = [userInfo objectForKey:@"DetailID"];
        
        UITabBarController *tabbarController = (UITabBarController *)self.window.rootViewController;
        WKNavigationController *navigationController = tabbarController.selectedViewController;
        
        if ([pushType isEqualToString:@"1"]) {
            JobApplyViewController *jobApplyCtrl = [[JobApplyViewController alloc] init];
            jobApplyCtrl.title = @"申请的职位";
            [navigationController pushViewController:jobApplyCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"2"]) {
            InterviewViewController *interviewCtrl = [[InterviewViewController alloc] init];
            interviewCtrl.title = @"面试通知";
            [navigationController pushViewController:interviewCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"3"]) {
            ApplyInvitationViewController *invitationCtrl = [[ApplyInvitationViewController alloc] init];
            invitationCtrl.title = @"应聘邀请";
            [navigationController pushViewController:invitationCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"4"]) {
            CpViewViewController *cpViewCtrl = [[CpViewViewController alloc] init];
            cpViewCtrl.title = @"谁在关注我";
            [navigationController pushViewController:cpViewCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"5"]) {
            UIViewController *pushCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"chatListView"];
            [navigationController pushViewController:pushCtrl animated:true];
        }
        else if ([pushType isEqualToString:@"6"]) {
            AttentionViewController *attentionViewCtrl = [[AttentionViewController alloc] init];
            attentionViewCtrl.title = @"我的关注";
            [navigationController pushViewController:attentionViewCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"7"]) {
            YourFoodViewController *yourFoodCtrl = [[YourFoodViewController alloc] init];
            yourFoodCtrl.title = @"你的菜儿";
            [navigationController pushViewController:yourFoodCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"8"]) {
            WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
            JobViewController *jobCtrl = jobNav.viewControllers[0];
            jobCtrl.jobId = detailId;
            [navigationController presentViewController:jobNav animated:YES completion:nil];
        }
        else if ([pushType isEqualToString:@"9"] || [pushType isEqualToString:@"10"]) {
            ApplyCvViewController *applyCvCtrl = [[ApplyCvViewController alloc] init];
            [navigationController pushViewController:applyCvCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"11"]) {
            ChatListCpViewController *chatListCpCtrl = [[ChatListCpViewController alloc] init];
            [navigationController pushViewController:chatListCpCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"12"]) {
            CvRecommendViewController *cvRecommendCtrl = [[CvRecommendViewController alloc] init];
            [navigationController pushViewController:cvRecommendCtrl animated:YES];
        }
        else if ([pushType isEqualToString:@"13"]) {
            InterviewCpViewController *interviewCpCtrl = [[InterviewCpViewController alloc] init];
            [navigationController pushViewController:interviewCpCtrl animated:YES];
        }
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"iOS51rcProject"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
