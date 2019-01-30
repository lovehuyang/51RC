//
//  ExpiredJobListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  过期职位页面

#import "ExpiredJobListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "JobModifyViewController.h"
#import "ApplyCvViewController.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "JobViewController.h"
#import "WKNavigationController.h"
#import "CpJobListModel.h"
#import "ExpiredJobListCell.h"

@interface ExpiredJobListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, UITextFieldDelegate, WKPopViewDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *txtIssueEnd;
@property NSInteger selectedRowIndex;
@property NSInteger page;

@end

@implementation ExpiredJobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - TAB_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有过期的职位！"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    // 刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self getData];
    }];
    self.tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    // 加载更多
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
}
- (NSMutableArray *)arrData{
    if (!_arrData) {
        _arrData = [NSMutableArray array];
    }
    return _arrData;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)initData {
    self.page = 1;
    [self getData];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpJobList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", @"2", @"intJobStatus", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.arrData removeAllObjects];
        }
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
        for (NSDictionary *dict in arrayData) {
            CpJobListModel *model = [CpJobListModel buildModelWithDic:dict];
            [self.arrData addObject:model];
        }
    
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
    else if (request.tag == 2) {
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"职位发布成功"];
            [self.arrData removeObjectAtIndex:self.selectedRowIndex];
            [self.tableView reloadData];
            [self.delegate issueListReload];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view.window makeToast:@"已达到最大职位发布数量，无法继续发布"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"该用户已暂停，不能发布职位"];
        }
    }
    else if (request.tag == 3) {
        [self.view.window makeToast:@"职位删除成功"];
        if (self.arrData.count == 0) {
            [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
        }
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
    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[ExpiredJobListCell class] contentViewWidth:SCREEN_WIDTH];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CpJobListModel *model = [self.arrData objectAtIndex:indexPath.section];
    ExpiredJobListCell *cell = [[ExpiredJobListCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"expiredCell"];
    cell.model = model;
    __weak typeof(self)weakself = self;
    cell.expiredCellBlock  = ^(UIButton *btn, CpJobListModel *model) {
        if (btn.tag == 100) {// 应聘简历
            [weakself applyClick:model];
        }else if (btn.tag == 101){//删除
            [weakself deleteClick:model indexPath:indexPath];
        }else if (btn.tag == 102){// 修改计划
            [weakself issueClick:indexPath];
        }else if (btn.tag == 103){// 编辑职位
            [weakself modifyClick:model];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CpJobListModel *model = [self.arrData objectAtIndex:indexPath.section];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = model.ID;
    [self presentViewController:jobNav animated:YES completion:nil];
}

#pragma mark - 应聘简历点击
- (void)applyClick:(CpJobListModel *)model {
    NSString *applyCountStr = model.ApplyCount;
    if ([applyCountStr integerValue] ==0) {
        return;
    }
    ApplyCvViewController *applyCvCtrl = [[ApplyCvViewController alloc] init];
    applyCvCtrl.jobId = model.ID;
    [self.navigationController pushViewController:applyCvCtrl animated:YES];
}
#pragma mark - 编辑职位
- (void)modifyClick:(CpJobListModel *)model{
    JobModifyViewController *jobModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobModifyView"];
    jobModifyCtrl.jobId = model.ID;
    [self.navigationController pushViewController:jobModifyCtrl animated:YES];
}
#pragma mark - 删除
- (void)deleteClick:(CpJobListModel *)model indexPath:(NSIndexPath *)indexPath {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除该职位吗？" message:@"删除职位将一起删除该职位的应聘简历记录" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {

        [self.arrData removeObjectAtIndex:indexPath.section];
        [self.tableView reloadData];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", model.ID, @"JobID", nil] viewController:self];
        [request setTag:3];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
#pragma mark - 重新发布
- (void)issueClick:(NSIndexPath *)indexPath {
    self.selectedRowIndex = indexPath.section;
    UIView *viewIssuePop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 80)];
    WKLabel *lbIssue = [[WKLabel alloc] initWithFixedHeight:CGRectMake(30, 15, 200, 20) content:@"修改发布时间至" size:DEFAULTFONTSIZE color:GREENCOLOR];
    [viewIssuePop addSubview:lbIssue];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:2];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    self.txtIssueEnd = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbIssue), 0, 100, 50)];
    [self.txtIssueEnd setText:[Common stringFromDate:mDate formatType:@"yyyy-MM-dd"]];
    [self.txtIssueEnd setTextAlignment:NSTextAlignmentRight];
    [self.txtIssueEnd setTextColor:GREENCOLOR];
    [self.txtIssueEnd setFont:DEFAULTFONT];
    [self.txtIssueEnd setDelegate:self];
    [viewIssuePop addSubview:self.txtIssueEnd];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(self.txtIssueEnd) + 15, 17.5, 15, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowdown.png"]];
    [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
    [viewIssuePop addSubview:imgArrow];
    
    WKPopView *issuePop = [[WKPopView alloc] initWithCustomView:viewIssuePop];
    [issuePop setDelegate:self];
    [issuePop setTag:1];
    [issuePop showPopView:self];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
    [self.datePicker setDate:[Common dateFromString:self.txtIssueEnd.text] animated:YES];
    [self.datePicker setDatePickerMode:UIDatePickerModeDate];
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:date];
    NSInteger year = [components year];
    [self.datePicker setMinimumDate:date];
    [self.datePicker setMaximumDate:[Common dateFromString:[NSString stringWithFormat:@"%ld-12-31", (year + 1)]]];
    
    WKPopView *popView = [[WKPopView alloc] initWithCustomView:self.datePicker];
    [popView setTag:2];
    [popView setDelegate:self];
    [popView showPopView:self];
    return NO;
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    if (popView.tag == 1) {
        CpJobListModel *model = [self.arrData objectAtIndex:self.selectedRowIndex];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"IssueJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", model.ID, @"JobID", self.txtIssueEnd.text, @"IssueEnd", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    else if (popView.tag == 2) {
        NSString *stringIssueEnd = [Common stringFromDate:self.datePicker.date formatType:@"yyyy-MM-dd"];
        self.txtIssueEnd.text = stringIssueEnd;
    }
    [popView cancelClick];
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
