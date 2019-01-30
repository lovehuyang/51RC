//
//  IssueJobListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  发布中职位页面

#import "IssueJobListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "JobModifyViewController.h"
#import "ApplyCvViewController.h"
#import "WKPopView.h"
#import "WKButton.h"
#import "UIView+Toast.h"
#import "OrderApplyViewController.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "CpJobListModel.h"
#import "IssueJobListCell.h"

@interface IssueJobListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, UITextFieldDelegate, WKPopViewDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UIView *viewRefreshPop;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UITextField *txtIssueEnd;
@property NSInteger selectedRowIndex;
@property NSInteger page;

@end

@implementation IssueJobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - TAB_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n您现在可以点击右上角的+发布职位"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
        [self getData];
    }];
    self.tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpJobList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", @"1", @"intJobStatus", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.tableView.mj_footer endRefreshing];
    [self.tableView.mj_header endRefreshing];
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
            [self initData];
        }
        else if ([result isEqualToString:@"-1"]) {
            [self.view.window makeToast:@"已达到最大职位发布数量，无法继续发布"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"该用户已暂停，不能发布职位"];
        }
    }
    else if (request.tag == 3) {
        [self.view.window makeToast:@"职位中止成功"];
        [self.arrData removeObjectAtIndex:self.selectedRowIndex];
        [self.tableView reloadData];
        [self.delegate expiredListReload];
    }
    else if (request.tag == 4) {
        CpJobListModel *model = [self.arrData objectAtIndex:self.selectedRowIndex];
        WKLabel *lbName = [[WKLabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35) content:[NSString stringWithFormat:@"刷新：%@", model.Name] size:DEFAULTFONTSIZE color:nil];
        [lbName setTextAlignment:NSTextAlignmentCenter];
        [self.viewRefreshPop addSubview:lbName];
        
        WKLabel *lbTips = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbName), SCREEN_WIDTH, VIEW_H(lbName)) content:[NSString stringWithFormat:@"本次需：1个职位刷新数（可用%@个）", result] size:DEFAULTFONTSIZE color:nil];
        NSMutableAttributedString *tipsString = [[NSMutableAttributedString alloc] initWithString:lbTips.text];
        [tipsString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(4, 1)];
        [lbTips setAttributedText:tipsString];
        [lbTips setTextAlignment:NSTextAlignmentCenter];
        [self.viewRefreshPop addSubview:lbTips];
        
        if ([result isEqualToString:@"0"]) {
            WKLabel *lbWarning = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTips), SCREEN_WIDTH, VIEW_H(lbName)) content:@"职位刷新数不足，请购买职位刷新数" size:DEFAULTFONTSIZE color:[UIColor redColor]];
            [lbWarning setTextAlignment:NSTextAlignmentCenter];
            [self.viewRefreshPop addSubview:lbWarning];
        }
        WKPopView *refreshPop = [[WKPopView alloc] initWithCustomView:self.viewRefreshPop];
        [refreshPop setDelegate:self];
        [refreshPop setTag:([result isEqualToString:@"0"] ? 3 : 4)];
        [refreshPop showPopView:self];
    }
    else if (request.tag == 5) {
        [self.view.window makeToast:@"职位刷新成功"];
        [self initData];
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

    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[IssueJobListCell class] contentViewWidth:SCREEN_WIDTH];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CpJobListModel *model = [self.arrData objectAtIndex:indexPath.section];
    IssueJobListCell *cell = [[IssueJobListCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"issueCell"];
    cell.model = model;
    __weak typeof(self)weakself = self;
    cell.issueCellBlock = ^(UIButton *btn, CpJobListModel *model) {
        if (btn.tag == 100) {// 应聘简历
            [weakself applyClick:model];
        }else if (btn.tag == 101){//刷新
            [weakself refreshClick:model indexPath:indexPath];
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
//    CvManagerViewController *cvManagerCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cvManagerView"];
//    cvManagerCtrl.jobId = [data objectForKey:@"ID"];
//    [self.navigationController pushViewController:cvManagerCtrl animated:YES];
    ApplyCvViewController *applyCvCtrl = [[ApplyCvViewController alloc] init];
    applyCvCtrl.jobId = model.ID;
    [self.navigationController pushViewController:applyCvCtrl animated:YES];
}
#pragma mark - 编辑职位
- (void)modifyClick:(CpJobListModel *)model {
    JobModifyViewController *jobModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobModifyView"];
    jobModifyCtrl.jobId = model.ID;
    [self.navigationController pushViewController:jobModifyCtrl animated:YES];
}
#pragma mark - 修改计划
- (void)issueClick:(NSIndexPath *)indexPath {
    self.selectedRowIndex = indexPath.section;
    UIView *viewIssuePop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    UIButton *btnIssue = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    [btnIssue setTag:9999];
    [btnIssue setTitle:@"1" forState:UIControlStateNormal];
    [btnIssue setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnIssue addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewIssuePop addSubview:btnIssue];
    
    UIImageView *imgIssue = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, 20, 20)];
    [imgIssue setImage:[UIImage imageNamed:@"img_cpcheck1.png"]];
    [btnIssue addSubview:imgIssue];
    
    WKLabel *lbIssue = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgIssue) + 10, VIEW_Y(imgIssue), 200, VIEW_H(imgIssue)) content:@"修改发布时间至" size:DEFAULTFONTSIZE color:GREENCOLOR];
    [btnIssue addSubview:lbIssue];
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:2];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:[NSDate date] options:0];
    
    self.txtIssueEnd = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbIssue), 0, 150, 50)];
    [self.txtIssueEnd setText:[Common stringFromDate:mDate formatType:@"yyyy-MM-dd 23:59"]];
    [self.txtIssueEnd setTextAlignment:NSTextAlignmentRight];
    [self.txtIssueEnd setTextColor:GREENCOLOR];
    [self.txtIssueEnd setFont:DEFAULTFONT];
    [self.txtIssueEnd setDelegate:self];
    [btnIssue addSubview:self.txtIssueEnd];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(self.txtIssueEnd) + 15, 17.5, 15, 15)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowdown.png"]];
    [imgArrow setContentMode:UIViewContentModeScaleAspectFit];
    [btnIssue addSubview:imgArrow];
    
    UIButton *btnStop = [[UIButton alloc] initWithFrame:CGRectMake(0, 50, SCREEN_WIDTH, 50)];
    [btnStop setTag:9998];
    [btnStop setTitle:@"0" forState:UIControlStateNormal];
    [btnStop setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnStop addTarget:self action:@selector(optionClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewIssuePop addSubview:btnStop];
    
    UIImageView *imgStop = [[UIImageView alloc] initWithFrame:CGRectMake(30, 15, 20, 20)];
    [imgStop setImage:[UIImage imageNamed:@"img_cpcheck2.png"]];
    [btnStop addSubview:imgStop];
    
    WKLabel *lbStop = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgStop) + 10, VIEW_Y(imgStop), 200, VIEW_H(imgStop)) content:@"中止发布，移动到“过期职位”" size:DEFAULTFONTSIZE color:nil];
    [btnStop addSubview:lbStop];
    WKPopView *issuePop = [[WKPopView alloc] initWithCustomView:viewIssuePop];
    [issuePop setDelegate:self];
    [issuePop setTag:1];
    [issuePop showPopView:self];
}
#pragma mark - 刷新
- (void)refreshClick:(CpJobListModel *)model indexPath:(NSIndexPath *)indexPath{
    if (self.viewRefreshPop == nil) {
        self.viewRefreshPop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 130)];
    }
    else {
        for (UIView *view in self.viewRefreshPop.subviews) {
            [view removeFromSuperview];
        }
    }
    self.selectedRowIndex = indexPath.section;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpRefreshNumber" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", model.ID, @"JobID", CPMAINID, @"cpMainID", nil] viewController:self];
    [request setTag:4];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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
        UIButton *btnIssue = [[popView viewWithTag:POPVIEWCONTENTTAG] viewWithTag:9999];
        if ([btnIssue.titleLabel.text isEqualToString:@"1"]) {
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"IssueJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", model.ID, @"JobID", [self.txtIssueEnd.text substringToIndex:10], @"IssueEnd", nil] viewController:self];
            [request setTag:2];
            [request setDelegate:self];
            [request startAsynchronous];
            self.runningRequest = request;
        }
        else {
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"StopJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", model.ID, @"JobID", nil] viewController:self];
            [request setTag:3];
            [request setDelegate:self];
            [request startAsynchronous];
            self.runningRequest = request;
        }
    }
    else if (popView.tag == 2) {
        NSString *stringIssueEnd = [Common stringFromDate:self.datePicker.date formatType:@"yyyy-MM-dd 23:59"];
        self.txtIssueEnd.text = stringIssueEnd;
    }
    else if (popView.tag == 3) { //无刷新数
        OrderApplyViewController *orderApplyCtrl = [[OrderApplyViewController alloc] init];
        orderApplyCtrl.urlString = [NSString stringWithFormat:@"http://%@/company/order/applyad?adtype=15", [USER_DEFAULT valueForKey:@"subsite"]];
        [self.navigationController pushViewController:orderApplyCtrl animated:YES];
    }
    else if (popView.tag == 4) { //有刷新数
        NSDictionary *jobData = [self.arrData objectAtIndex:self.selectedRowIndex];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"RefreshJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", [jobData objectForKey:@"ID"], @"JobID", nil] viewController:self];
        [request setTag:5];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    [popView cancelClick];
}

- (void)optionClick:(UIButton *)button {
    UIView *viewIssuePop = button.superview;
    UIButton *btnIssue = [viewIssuePop viewWithTag:9999];
    UIButton *btnStop = [viewIssuePop viewWithTag:9998];
    UIImageView *imgIssue;
    UIImageView *imgStop;
    UILabel *lbIssue;
    UILabel *lbStop;
    
    for (UIView *view in btnIssue.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgIssue = (UIImageView *)view;
        }
        else if ([view isKindOfClass:[WKLabel class]]) {
            lbIssue = (WKLabel *)view;
            break;
        }
    }
    
    for (UIView *view in btnStop.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgStop = (UIImageView *)view;
        }
        else if ([view isKindOfClass:[WKLabel class]]) {
            lbStop = (WKLabel *)view;
            break;
        }
    }
    if (button.tag == 9999) {
        [imgIssue setImage:[UIImage imageNamed:@"img_cpcheck1.png"]];
        [imgStop setImage:[UIImage imageNamed:@"img_cpcheck2.png"]];
        [lbIssue setTextColor:GREENCOLOR];
        [lbStop setTextColor:[UIColor blackColor]];
        [btnIssue setTitle:@"1" forState:UIControlStateNormal];
        [btnStop setTitle:@"0" forState:UIControlStateNormal];
        [self.txtIssueEnd setTextColor:GREENCOLOR];
    }
    else {
        [imgIssue setImage:[UIImage imageNamed:@"img_cpcheck2.png"]];
        [imgStop setImage:[UIImage imageNamed:@"img_cpcheck1.png"]];
        [lbIssue setTextColor:[UIColor blackColor]];
        [lbStop setTextColor:GREENCOLOR];
        [btnIssue setTitle:@"0" forState:UIControlStateNormal];
        [btnStop setTitle:@"1" forState:UIControlStateNormal];
        [self.txtIssueEnd setTextColor:[UIColor blackColor]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
