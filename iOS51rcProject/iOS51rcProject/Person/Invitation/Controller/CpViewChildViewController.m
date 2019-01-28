//
//  CpViewChildViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CpViewChildViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "JobViewController.h"
#import "WKNavigationController.h"
#import "CpViewModel.h"

@interface CpViewChildViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property NSInteger page;
@end

@implementation CpViewChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * (self.onlyOne ? 1 : 2)) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n多申请职位可以增加就业机会哦~"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCpView" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.page], @"page", self.cvMainId, @"cvMainId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    for (NSDictionary *dict in arrayData) {
        CpViewModel *model = [CpViewModel buideModel:dict];
        [self.arrData addObject:model];
    }
    [self.tableView reloadData];
    if (arrayData.count < 20) {
        if (self.page == 1) {
            [self.tableView.mj_footer removeFromSuperview];
            if (arrayData.count == 0) {
                [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
            }
        }
        else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CpViewModel *model = [self.arrData objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:model.LogoUrl] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [cell.contentView addSubview:imgLogo];
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30;
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo), maxWidth, 25) content:model.cpName size:BIGGERFONTSIZE color:nil];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), 200, 25) content:[NSString stringWithFormat:@"查看时间：%@", [Common stringFromDateString:model.adddate formatType:@"MM-dd HH:mm"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentCenter];
    [cell.contentView addSubview:lbDate];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDate) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    CpViewModel *model = [self.arrData objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.companyId = model.cpID;
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
