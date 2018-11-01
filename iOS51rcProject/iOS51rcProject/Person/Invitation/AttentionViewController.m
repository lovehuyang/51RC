//
//  AttentionViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "AttentionViewController.h"
#import "CpAttentionViewController.h"
#import "JobAttentionViewController.h"
#import "SCNavTabBarController.h"

@interface AttentionViewController ()

@end

@implementation AttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CpAttentionViewController *cpAttentionCtrl = [[CpAttentionViewController alloc] init];
    cpAttentionCtrl.title = @"关注的企业";
    
    JobAttentionViewController *jobAttentionCtrl = [[JobAttentionViewController alloc] init];
    jobAttentionCtrl.title = @"收藏的职位";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[cpAttentionCtrl, jobAttentionCtrl];
    navTabCtrl.scrollEnabled = YES;
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
