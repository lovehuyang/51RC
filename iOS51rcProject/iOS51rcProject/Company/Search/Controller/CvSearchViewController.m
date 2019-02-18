//
//  CvSearchViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/2.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CvSearchViewController.h"
#import "SCNavTabBarController.h"
#import "CvRecommendViewController.h"
#import "CvSearchConditionViewController.h"
#import "CvRecruitmentConditionViewController.h"

@interface CvSearchViewController ()

@end

@implementation CvSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"简历搜索";
    CvRecommendViewController *cvRecommendCtrl = [[CvRecommendViewController alloc] init];
    cvRecommendCtrl.title = @"推荐简历";
    
    CvSearchConditionViewController *cvSearchConditionCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cvSearchConditionView"];
    cvSearchConditionCtrl.title = @"搜索简历";
    
//    CvRecruitmentConditionViewController *cvRecruitmentConditionCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cvRecruitmentConditionView"];
//    cvRecruitmentConditionCtrl.title = @"招聘会简历";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[cvRecommendCtrl, cvSearchConditionCtrl];
    navTabCtrl.scrollEnabled = YES;
    navTabCtrl.isCompany = YES;
    [navTabCtrl addParentController:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
