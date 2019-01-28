//
//  ApplyInvitationCpViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "ApplyInvitationCpViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "CvDetailViewController.h"
#import "WKNavigationController.h"
#import "CvOperate.h"

@interface ApplyInvitationCpViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) CvOperate *operate;
@property NSInteger page;

@end

@implementation ApplyInvitationCpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有发送过应聘邀请！"];
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpInviteList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table1"];
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
    else {
        self.arrData = [[NSMutableArray alloc] init];
        self.page = 1;
        [self getData];
    }
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 15, SCREEN_WIDTH, 20) content:[[data objectForKey:@"paName"] stringByReplacingOccurrencesOfString:@"$$##" withString:@""] size:BIGGERFONTSIZE color:nil];
    [cell.contentView addSubview:lbName];
    
    WKLabel *lbMatch = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 95, VIEW_Y(lbName), 80, 20) content:[NSString stringWithFormat:@"匹配度%@%%", [data objectForKey:@"cvMatch"]] size:DEFAULTFONTSIZE color:nil];
    [lbMatch setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbMatch];
    
    NSString *apply = @"未应聘";
    UIColor *applyColor = [UIColor blackColor];
    UIColor *applyBgColor = SEPARATECOLOR;
    if ([[data objectForKey:@"HasJobApply"] boolValue]) {
        apply = @"已应聘";
        applyColor = [UIColor whiteColor];
        applyBgColor = GREENCOLOR;
    }
    WKLabel *lbApply = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, VIEW_BY(lbMatch) + 20, 60, 20) content:apply size:SMALLERFONTSIZE color:applyColor];
    [lbApply setTextAlignment:NSTextAlignmentCenter];
    [lbApply setBackgroundColor:applyBgColor];
    [cell.contentView addSubview:lbApply];
    
    NSString *workYears = @"";
    if ([[data objectForKey:@"RelatedWorkYears"] isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([[data objectForKey:@"RelatedWorkYears"] isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([[data objectForKey:@"RelatedWorkYears"] length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", [data objectForKey:@"RelatedWorkYears"]];
    }
    WKLabel *lbPaInfo = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbMatch) + 10, SCREEN_WIDTH - VIEW_X(lbName) * 2, 20) content:[NSString stringWithFormat:@"%@ | %@岁 | %@ | %@工作经验 | %@", ([[data objectForKey:@"Gender"] boolValue] ? @"女" : @"男"), [data objectForKey:@"Age"], [data objectForKey:@"DegreeName"], workYears, [data objectForKey:@"LivePlaceName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbPaInfo];
    
    WKLabel *lbJobTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbPaInfo) + 10, 200, 20) content:@"面试职位：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbJobTitle];
    
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbJobTitle), VIEW_Y(lbJobTitle), SCREEN_WIDTH - VIEW_BX(lbJobTitle) - VIEW_X(lbName), 20) content:[NSString stringWithFormat:@"%@（%@）", [data objectForKey:@"JobName"], [data objectForKey:@"JobRegionName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbJob];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbJob) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    UIButton *btnDelete = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), SCREEN_WIDTH / 2, 40)];
    [btnDelete setTag:indexPath.section];
    [btnDelete setTitle:@"删除" forState:UIControlStateNormal];
    [btnDelete setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnDelete.titleLabel setFont:DEFAULTFONT];
    [btnDelete.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnDelete addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnDelete];
    
    UIButton *btnInterview = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnDelete), VIEW_Y(btnDelete), VIEW_W(btnDelete), VIEW_H(btnDelete))];
    [btnInterview setTag:indexPath.section];
    [btnInterview setTitle:@"面试通知" forState:UIControlStateNormal];
    [btnInterview setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnInterview.titleLabel setFont:DEFAULTFONT];
    [btnInterview.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [btnInterview addTarget:self action:@selector(interviewClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnInterview];
    
    UIView *viewSeparateMiddle = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnDelete), VIEW_Y(btnDelete), 1, VIEW_H(btnDelete))];
    [viewSeparateMiddle setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparateMiddle];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnDelete))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    CvDetailViewController *cvDetailCtrl = [[CvDetailViewController alloc] init];
    cvDetailCtrl.cvMainId = [data objectForKey:@"cvMainID"];
    [self.navigationController pushViewController:cvDetailCtrl animated:YES];
}

- (void)deleteClick:(UIButton *)button {
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"确定要删除该应聘邀请吗？" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSDictionary *data = [self.arrData objectAtIndex:button.tag];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteCpIntention" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [data objectForKey:@"ID"], @"intIntentionID", CPMAINID, @"cpMainID", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertDelete animated:YES completion:nil];
}

- (void)interviewClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    self.operate = [[CvOperate alloc] init:[data objectForKey:@"cvMainID"] paName:[[data objectForKey:@"paName"] stringByReplacingOccurrencesOfString:@"$$##" withString:@""] viewController:self];
    [self.operate setJobId:[data objectForKey:@"JobID"]];
    [self.operate interview];
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
