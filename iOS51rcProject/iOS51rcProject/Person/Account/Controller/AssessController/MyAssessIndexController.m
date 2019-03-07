//
//  MyAssessIndexController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyAssessIndexController.h"
#import "SCNavTabBarController.h"
#import "CompanyInvitationController.h"
#import "MyselfAssessIndexController.h"


@interface MyAssessIndexController ()

@end

@implementation MyAssessIndexController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"我的测评";
    
    MyselfAssessIndexController *jobAttentionCtrl = [[MyselfAssessIndexController alloc] init];
    jobAttentionCtrl.title = @"自我测评";
    
    CompanyInvitationController *cpAttentionCtrl = [[CompanyInvitationController alloc] init];
    cpAttentionCtrl.title = @"企业邀请";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[jobAttentionCtrl, cpAttentionCtrl];
    navTabCtrl.scrollEnabled = YES;
    [navTabCtrl addParentController:self];
    
    
    UIButton *btn = [UIButton new];
    btn.frame = CGRectMake(0, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - 44, SCREEN_WIDTH, 44);
    [self.view addSubview:btn];
    btn.backgroundColor = [UIColor lightGrayColor];
    [btn setTitle:@"我要测评" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = DEFAULTFONT;
    [btn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}
- (void)btnClick{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
