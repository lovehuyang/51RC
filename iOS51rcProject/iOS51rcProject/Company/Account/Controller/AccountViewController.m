//
//  AccountViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/2.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "AccountViewController.h"
#import "AccountListViewController.h"
#import "AccountQuotaViewController.h"
#import "SCNavTabBarController.h"

@interface AccountViewController ()

@end

@implementation AccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"用户管理";
    AccountListViewController *listCtrl = [[AccountListViewController alloc] init];
    listCtrl.title = @"用户设置";
    
    AccountQuotaViewController *quotaCtrl = [[AccountQuotaViewController alloc] init];
    quotaCtrl.title = @"配额管理";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[listCtrl, quotaCtrl];
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
