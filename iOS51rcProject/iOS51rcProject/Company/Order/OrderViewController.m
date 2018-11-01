//
//  OrderViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/2.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "OrderViewController.h"
#import "OrderStatusViewController.h"
#import "OrderListViewController.h"
#import "FeeStandardViewController.h"
#import "PayMethodViewController.h"
#import "SCNavTabBarController.h"

@interface OrderViewController ()<SCNavTabBarControllerDelegate>

@property (nonatomic, strong) OrderListViewController *listCtrl;
@end

@implementation OrderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"会员服务";
    OrderStatusViewController *statusCtrl = [[OrderStatusViewController alloc] init];
    statusCtrl.title = @"会员状态";
    
    FeeStandardViewController *feeStandardCtrl = [[FeeStandardViewController alloc] init];
    feeStandardCtrl.title = @"资费标准";
    
    self.listCtrl = [[OrderListViewController alloc] init];
    self.listCtrl.title = @"我的订单";
    
    PayMethodViewController *paymethodCtrl = [[PayMethodViewController alloc] init];
    paymethodCtrl.title = @"付费方式";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    [navTabCtrl setDelegate:self];
    navTabCtrl.subViewControllers = @[statusCtrl, feeStandardCtrl, self.listCtrl, paymethodCtrl];
    navTabCtrl.scrollEnabled = YES;
    navTabCtrl.isCompany = YES;
    [navTabCtrl addParentController:self];
}

- (void) anotherTabPressed:(UIButton *)button {
    NSLog(@"%ld", button.tag);
    if (button.tag == 2) {
        [self.listCtrl.webView reload];
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
