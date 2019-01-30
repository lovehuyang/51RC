//
//  JobManagerViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "JobManagerViewController.h"
#import "SCNavTabBarController.h"
#import "IssueJobListViewController.h"
#import "ExpiredJobListViewController.h"
#import "JobModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "CpMainInfoModel.h"

@interface JobManagerViewController ()<IssueJobListViewDelegate, ExpiredJobListViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) IssueJobListViewController *issueJobListCtrl;
@property (nonatomic, strong) ExpiredJobListViewController *expiredJobListCtrl;
@property NSInteger maxJobNumber;
@property NSInteger currentJobNumber;
@end

@implementation JobManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"职位管理";
    
    UIButton *btnCreate = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    [btnCreate.widthAnchor constraintEqualToConstant:25].active = YES;
    [btnCreate.heightAnchor constraintEqualToConstant:25].active = YES;
    [btnCreate setImage:[UIImage imageNamed:@"cp_jobadd.png"] forState:UIControlStateNormal];
    [btnCreate.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnCreate addTarget:self action:@selector(createClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnCreate];
    
    self.issueJobListCtrl = [[IssueJobListViewController alloc] init];
    [self.issueJobListCtrl setDelegate:self];
    self.issueJobListCtrl.title = @"发布中职位";
    
    self.expiredJobListCtrl = [[ExpiredJobListViewController alloc] init];
    [self.expiredJobListCtrl setDelegate:self];
    self.expiredJobListCtrl.title = @"过期职位";
    
    SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
    navTabCtrl.subViewControllers = @[self.issueJobListCtrl, self.expiredJobListCtrl];
    navTabCtrl.scrollEnabled = YES;
    navTabCtrl.isCompany = YES;
    [navTabCtrl addParentController:self];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getCpInfo];
}

- (void)createClick {
    if (self.maxJobNumber - self.currentJobNumber > 0) {
        JobModifyViewController *jobModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobModifyView"];
        [self.navigationController pushViewController:jobModifyCtrl animated:YES];
    }
    else {
        NSInteger memberType = [[USER_DEFAULT objectForKey:@"cpMemberType"] integerValue];
        if (memberType == 1) {
            [self.view.window makeToast:[NSString stringWithFormat:@"您最多只能发布%ld个职位，要发布更多职位，请到电脑端完成企业认证", self.maxJobNumber]];
        }
        else if (memberType == 2) {
            [self.view.window makeToast:[NSString stringWithFormat:@"您最多只能发布%ld个职位，要发布更多职位，请申请VIP会员", self.maxJobNumber]];
        }
        else if (memberType == 3) {
            [self.view.window makeToast:[NSString stringWithFormat:@"您最多只能发布%ld个职位，要发布更多职位，请购买简历数", self.maxJobNumber]];
        }
    }
}

- (void)refreshClick {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UpdateRefreshDateByRefresh" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)issueListReload {
    [self getCpInfo];
    [self.issueJobListCtrl initData];
}

- (void)expiredListReload {
    [self getCpInfo];
    [self.expiredJobListCtrl initData];
}

- (void)getCpInfo {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCpMain = [Common getArrayFromXml:requestData tableName:@"TableCp"];
        NSDictionary *companyData = [arrayCpMain objectAtIndex:0];
        CpMainInfoModel *model = [CpMainInfoModel buildModelWithDic:companyData];
        [USER_DEFAULT setObject:model.MemberType forKey:@"cpMemberType"];
        self.maxJobNumber = [model.MaxJobNumber integerValue];
        self.currentJobNumber = [model.JobNumber integerValue];
        
        if ([model.IsJobRefreshOldCompany isEqualToString:@"1"]) {
            UIButton *btnRefresh = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
            [btnRefresh.widthAnchor constraintEqualToConstant:25].active = YES;
            [btnRefresh.heightAnchor constraintEqualToConstant:25].active = YES;
            [btnRefresh setImage:[UIImage imageNamed:@"cp_jobrefreshall.png"] forState:UIControlStateNormal];
            [btnRefresh.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [btnRefresh addTarget:self action:@selector(refreshClick) forControlEvents:UIControlEventTouchUpInside];
            self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnRefresh];
        }
    }
    else if (request.tag == 2) {
        [self.view.window makeToast:@"职位刷新成功"];
        [self issueListReload];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
