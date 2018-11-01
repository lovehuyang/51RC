//
//  PersonViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/1.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKTabBarController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"

@interface WKTabBarController ()<UITabBarControllerDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *userType;
@end

@implementation WKTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.userType = [USER_DEFAULT objectForKey:@"userType"];
    if ([self.userType isEqualToString:@"1"]) {
        [self.tabBar setTintColor:NAVBARCOLOR];
    }
    else {
        [self.tabBar setTintColor:CPNAVBARCOLOR];
        if (COMPANYLOGIN) {
            [self getCpBadge:YES];
            self.delegate = self;
            [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(noViewRepeat) userInfo:nil repeats:YES];
        }
    }
}

- (void)noViewRepeat {
    [self getCpBadge:NO];
}

- (void)getCpBadge:(BOOL)sync {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpNoViewInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    if (sync) {
        [request startSynchronous];
    }
    else {
        [request startAsynchronous];
    }
    self.runningRequest = request;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSInteger index = tabBarController.selectedIndex;
    if (index == 4) {
        return;
    }
    [[self.tabBar.items objectAtIndex:tabBarController.selectedIndex] setBadgeValue:nil];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrData = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrData.count == 0) {
            return;
        }
        NSDictionary *viewData = [arrData objectAtIndex:0];
        NSString *applyCvCount = [viewData objectForKey:@"ApplyCvCount"];
        if (![applyCvCount isEqualToString:@"0"]) {
            [[self.tabBar.items objectAtIndex:1] setBadgeValue:applyCvCount];
        }
        NSString *chatCount = [viewData objectForKey:@"ChatCount"];
        if (![chatCount isEqualToString:@"0"]) {
            [[self.tabBar.items objectAtIndex:2] setBadgeValue:chatCount];
        }
        NSString *recommendCvCount = [viewData objectForKey:@"RecommendCvCount"];
        if (![recommendCvCount isEqualToString:@"0"]) {
            [[self.tabBar.items objectAtIndex:3] setBadgeValue:recommendCvCount];
        }
        NSString *interviewReplyCount = [viewData objectForKey:@"InterviewReplyCount"];
        if (![interviewReplyCount isEqualToString:@"0"]) {
            [[self.tabBar.items objectAtIndex:4] setBadgeValue:interviewReplyCount];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
