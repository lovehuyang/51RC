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
    
    self.arrData = [[NSMutableArray alloc] init];
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
    float widthForLable = SCREEN_WIDTH - 80;
    WKLabel *lbName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 10, widthForLable, 20) content:[data objectForKey:@"Name"] size:BIGGERFONTSIZE color:nil spacing:10];
    [cell.contentView addSubview:lbName];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbName) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"截止时间：%@", [Common stringFromDateString:[data objectForKey:@"IssueEnd"] formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:10];
    [cell.contentView addSubview:lbDate];
    
    WKLabel *lbRefresh = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbDate) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"累计应聘数：%@", [data objectForKey:@"ApplyNumber"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:10];
    [cell.contentView addSubview:lbRefresh];
    
    UIButton *btnApply = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, 0, 90, VIEW_BY(lbRefresh))];
    [btnApply setTag:indexPath.section];
    [btnApply addTarget:self action:@selector(applyClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnApply];
    
    UIView *viewMiddle = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_Y(lbName), 1, VIEW_BY(lbRefresh) - VIEW_Y(lbName))];
    [viewMiddle setBackgroundColor:SEPARATECOLOR];
    [btnApply addSubview:viewMiddle];
    
    // 应聘简历的数量
    NSString *applyCountStr = [data objectForKey:@"ApplyCount"];
    WKLabel *lbApplyCount = [[WKLabel alloc] initWithFrame:CGRectMake(15, VIEW_Y(viewMiddle) + 15, 60, 20) content:[data objectForKey:@"ApplyCount"] size:BIGGESTFONTSIZE color:[applyCountStr integerValue] == 0 ?TEXTGRAYCOLOR: GREENCOLOR];
    [lbApplyCount setTextAlignment:NSTextAlignmentCenter];
    [btnApply addSubview:lbApplyCount];
    
    WKLabel *lbApply = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(lbApplyCount), VIEW_BY(lbApplyCount), VIEW_W(lbApplyCount), 20) content:@"应聘简历" size:DEFAULTFONTSIZE color:nil];
    [lbApply setTextAlignment:NSTextAlignmentCenter];
    [btnApply addSubview:lbApply];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbRefresh) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    WKButton *btnRefresh = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), SCREEN_WIDTH / 3, 30) image:@"cp_jobdelete.png" title:@"删除" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnRefresh addTarget:self action:@selector(deleteClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRefresh setTag:indexPath.section];
    [cell.contentView addSubview:btnRefresh];
    
    WKButton *btnIssue = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnRefresh), VIEW_Y(btnRefresh), VIEW_W(btnRefresh), VIEW_H(btnRefresh)) image:@"cp_jobissue.png" title:@"重新发布" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnIssue addTarget:self action:@selector(issueClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnIssue setTag:indexPath.section];
    [cell.contentView addSubview:btnIssue];
    
    WKButton *btnModify = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnIssue), VIEW_Y(btnRefresh), VIEW_W(btnRefresh), VIEW_H(btnRefresh)) image:@"cp_jobmodify.png" title:@"编辑职位" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnModify addTarget:self action:@selector(modifyClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnModify setTag:indexPath.section];
    [cell.contentView addSubview:btnModify];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnModify))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = [data objectForKey:@"ID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

#pragma mark - 应聘简历点击
- (void)applyClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    NSString *applyCountStr = [data objectForKey:@"ApplyCount"];
    if ([applyCountStr integerValue] ==0) {
        return;
    }
    ApplyCvViewController *applyCvCtrl = [[ApplyCvViewController alloc] init];
    applyCvCtrl.jobId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:applyCvCtrl animated:YES];
}

- (void)modifyClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    JobModifyViewController *jobModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobModifyView"];
    jobModifyCtrl.jobId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:jobModifyCtrl animated:YES];
}

- (void)deleteClick:(UIButton *)button {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"确定要删除该职位吗？" message:@"删除职位将一起删除该职位的应聘简历记录" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        NSDictionary *data = [self.arrData objectAtIndex:button.tag];
        [self.arrData removeObjectAtIndex:button.tag];
        [self.tableView reloadData];
        
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [data objectForKey:@"ID"], @"JobID", nil] viewController:self];
        [request setTag:3];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)issueClick:(UIButton *)button {
    self.selectedRowIndex = button.tag;
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
        NSDictionary *jobData = [self.arrData objectAtIndex:self.selectedRowIndex];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"IssueJob" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", [jobData objectForKey:@"ID"], @"JobID", self.txtIssueEnd.text, @"IssueEnd", nil] viewController:self];
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
