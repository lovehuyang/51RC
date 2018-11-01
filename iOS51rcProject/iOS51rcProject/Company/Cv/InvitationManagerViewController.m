//
//  InvitationManagerViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/23.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "InvitationManagerViewController.h"
#import "InterviewCpViewController.h"
#import "ApplyInvitationCpViewController.h"
#import "SCNavTabBarController.h"

@interface InvitationManagerViewController ()

@end

@implementation InvitationManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    InterviewCpViewController *interViewCpCtrl = [[InterviewCpViewController alloc] init];
    interViewCpCtrl.title = @"面试通知";
    
    ApplyInvitationCpViewController *applyInvitationCpCtrl = [[ApplyInvitationCpViewController alloc] init];
    applyInvitationCpCtrl.title = @"应聘邀请";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[interViewCpCtrl, applyInvitationCpCtrl];
    navTabCtrl.scrollEnabled = YES;
    navTabCtrl.isCompany = YES;
    [navTabCtrl addParentController:self];
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

