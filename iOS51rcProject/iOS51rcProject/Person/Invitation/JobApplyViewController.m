//
//  JobApplyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/16.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobApplyViewController.h"
#import "JobApplyChildViewController.h"
#import "SCNavTabBarController.h"

@interface JobApplyViewController ()

@end

@implementation JobApplyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    JobApplyChildViewController *childCtrl1 = [[JobApplyChildViewController alloc] init];
    childCtrl1.replyStatus = 0;
    childCtrl1.title = @"全部";
    
    JobApplyChildViewController *childCtrl2 = [[JobApplyChildViewController alloc] init];
    childCtrl2.replyStatus = 1;
    childCtrl2.title = @"未查看";
    
    JobApplyChildViewController *childCtrl3 = [[JobApplyChildViewController alloc] init];
    childCtrl3.replyStatus = 2;
    childCtrl3.title = @"待答复";
    
    JobApplyChildViewController *childCtrl4 = [[JobApplyChildViewController alloc] init];
    childCtrl4.replyStatus = 3;
    childCtrl4.title = @"符合要求";
    
    JobApplyChildViewController *childCtrl5 = [[JobApplyChildViewController alloc] init];
    childCtrl5.replyStatus = 4;
    childCtrl5.title = @"不合适";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[childCtrl1, childCtrl2, childCtrl3, childCtrl4, childCtrl5];
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
