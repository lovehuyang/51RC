//
//  CvManagerViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/2.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  简历管理页面

#import "CvManagerViewController.h"
#import "ApplyCvViewController.h"
#import "DownloadCvViewController.h"
#import "FavoriteCvViewController.h"
#import "SCNavTabBarController.h"

@interface CvManagerViewController ()

@end

@implementation CvManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"简历管理";
    ApplyCvViewController *applyCvCtrl = [[ApplyCvViewController alloc] init];
    applyCvCtrl.title = @"应聘的简历";
    
    DownloadCvViewController *downloadCvCtrl = [[DownloadCvViewController alloc] init];
    downloadCvCtrl.title = @"下载的简历";
    
    FavoriteCvViewController *favoriteCvCtrl = [[FavoriteCvViewController alloc] init];
    favoriteCvCtrl.title = @"收藏的简历";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[applyCvCtrl, downloadCvCtrl, favoriteCvCtrl];
    navTabCtrl.scrollEnabled = YES;
    navTabCtrl.isCompany = YES;
    [navTabCtrl addParentController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
