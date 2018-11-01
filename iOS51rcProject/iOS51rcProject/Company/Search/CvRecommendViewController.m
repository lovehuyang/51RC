//
//  CvRecommendViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/23.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CvRecommendViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "WKCvTableViewCell.h"
#import "CvDetailViewController.h"

@interface CvRecommendViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property NSInteger page;
@end

@implementation CvRecommendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"推荐简历";
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - TAB_BAR_HEIGHT - STATUS_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有推荐的简历！"];
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpCvRecommend" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    [self.arrData addObjectsFromArray:arrayData];
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
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [viewTitle setBackgroundColor:SEPARATECOLOR];
    return viewTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    WKCvTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[WKCvTableViewCell alloc] initWithListType:3 reuseIdentifier:@"cell" viewController:self];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell fillCvInfo:[NSString stringWithFormat:@"推荐职位：%@", [data objectForKey:@"MatchJobName"]] gender:[data objectForKey:@"Gender"] name:[data objectForKey:@"JobName"] relatedWorkYears:[data objectForKey:@"RelatedWorkYears"] age:[data objectForKey:@"Age"] degree:[data objectForKey:@"DegreeName"] livePlace:[data objectForKey:@"LivePlaceName"] loginDate:[data objectForKey:@"JobRecommendDate"] mobileVerifyDate:[data objectForKey:@"MobileVerifyDate"] paPhoto:@"" online:@"" paMainId:[data objectForKey:@"paMainId"] cvMainId:[data objectForKey:@"ID"]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    CvDetailViewController *cvDetailCtrl = [[CvDetailViewController alloc] init];
    cvDetailCtrl.cvMainId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:cvDetailCtrl animated:YES];
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
