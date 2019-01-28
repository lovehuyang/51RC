//
//  InterViewCpViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "InterviewCpViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "InterviewCpDetailViewController.h"

@interface InterviewCpViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property NSInteger page;

@end

@implementation InterviewCpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"面试通知";
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有发送过面试通知！"];
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpInterviewList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
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
    NSString *status = @"未答复";
    UIColor *statusColor = [UIColor blackColor];
    UIColor *statusBgColor = UIColorWithRGBA(202, 202, 202, 1);
    if ([[data objectForKey:@"Reply"] integerValue] == 1) {
        status = @"赴约";
        statusColor = [UIColor whiteColor];
        statusBgColor = UIColorWithRGBA(0, 180, 0, 1);
    }
    else if ([[data objectForKey:@"Reply"] integerValue] == 2) {
        status = @"不赴约";
        statusColor = [UIColor whiteColor];
        statusBgColor = UIColorWithRGBA(243, 82, 78, 1);
    }
    WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, VIEW_Y(lbName), 60, 20) content:status size:SMALLERFONTSIZE color:statusColor];
    [lbStatus setTextAlignment:NSTextAlignmentCenter];
    [lbStatus setBackgroundColor:statusBgColor];
    [cell.contentView addSubview:lbStatus];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbStatus) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
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
    WKLabel *lbPaInfo = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(viewSeparate) + 10, SCREEN_WIDTH - VIEW_X(lbName) * 2, 20) content:[NSString stringWithFormat:@"%@ | %@岁 | %@ | %@工作经验 | %@", ([[data objectForKey:@"Gender"] boolValue] ? @"女" : @"男"), [data objectForKey:@"Age"], [data objectForKey:@"DegreeName"], workYears, [data objectForKey:@"LivePlaceName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbPaInfo];
    
    WKLabel *lbInterviewDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbPaInfo) + 10, 200, 20) content:@"面试时间：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbInterviewDateTitle];
    
    WKLabel *lbInterviewDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbInterviewDateTitle), VIEW_Y(lbInterviewDateTitle), SCREEN_WIDTH - VIEW_BX(lbInterviewDateTitle) - VIEW_X(lbName), 20) content:[data objectForKey:@"InterviewDate"] size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbInterviewDate];
    
    WKLabel *lbInterviewJobTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbInterviewDate) + 10, 200, 20) content:@"面试职位：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbInterviewJobTitle];
    
    WKLabel *lbInterviewJob = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbInterviewJobTitle), VIEW_Y(lbInterviewJobTitle), SCREEN_WIDTH - VIEW_BX(lbInterviewJobTitle) - VIEW_X(lbName), 20) content:[NSString stringWithFormat:@"%@（%@）", [data objectForKey:@"JobName"], [data objectForKey:@"JobRegionName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [cell.contentView addSubview:lbInterviewJob];
    
    if ([[data objectForKey:@"SmsMsg"] length] > 0) {
        WKLabel *lbMsg = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, VIEW_Y(lbInterviewJob), SCREEN_WIDTH, VIEW_H(lbInterviewJob)) content:@"已短信通知" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        CGRect frameMsg = lbMsg.frame;
        frameMsg.origin.x = SCREEN_WIDTH - frameMsg.size.width - 15;
        [lbMsg setFrame:frameMsg];
        [cell.contentView addSubview:lbMsg];
    }
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbInterviewJob) + 10)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    InterviewCpDetailViewController *interviewCpDetailCtrl = [[InterviewCpDetailViewController alloc] init];
    interviewCpDetailCtrl.interViewId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:interviewCpDetailCtrl animated:YES];
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
