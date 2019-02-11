//
//  ApplyCvViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/1.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  应聘的简历页面

#import "ApplyCvViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "CvDetailViewController.h"
#import "WKNavigationController.h"
#import "UIImageView+WebCache.h"
#import "WKPopView.h"
#import "CvOperate.h"
#import "PullDownMenu.h"
#import "ApplyCvListModel.h"
#import "ApplyCvListCell.h"

static const CGFloat Menu_H =  35;// 菜单栏的高度//35

@interface ApplyCvViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, WKPopViewDelegate, CvOperateDelegate>
{
    BOOL hideMenu;// 默认隐藏下拉菜单
}
@property (nonatomic , strong) PullDownMenu *pulldownMenu;// 头部显示答复率的容器
@property (nonatomic , strong) UITableView *menuTableview;// 下拉菜单
@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSDictionary *cpData;
@property (nonatomic, strong) WKPopView *replyPop;
@property (nonatomic, strong) CvOperate *operate;
@property (nonatomic, strong) NSMutableArray *jobListIdArr;//
@property (nonatomic, strong) NSMutableArray *jobListNameArr;//
@property NSInteger page;

@end

@implementation ApplyCvViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"应聘的简历";
    hideMenu = YES;
    [SVProgressHUD show];
    
    if (self.jobId == nil) {
        self.jobId = @"0";
        self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, Menu_H, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - TAB_BAR_HEIGHT - Menu_H) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有应聘的简历！"];
        [self getCpJobList];
    }
    else {
        self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n当前没有应聘的简历！"];
    }
    
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page =1;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
}

#pragma mark - 懒加载
- (UITableView *)menuTableview{
    if (!_menuTableview) {
        _menuTableview = [[UITableView alloc]initWithFrame:CGRectMake(0, Menu_H, SCREEN_WIDTH, VIEW_H(self.view) - VIEW_H(self.pulldownMenu)) style:UITableViewStylePlain];
        _menuTableview.delegate = self;
        _menuTableview.dataSource = self;
        UIView *footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300)];
        _menuTableview.backgroundColor = UIColorWithRGBA(1, 1, 1, 0.5);
        _menuTableview.tableFooterView = footView;
        _menuTableview.hidden = hideMenu;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(menuTapGesture)];
        [footView addGestureRecognizer:tapGesture];
    }
    return _menuTableview;
}
- (NSMutableArray *)jobListIdArr{
    if (!_jobListIdArr) {
        _jobListIdArr = [NSMutableArray array];
    }
    return _jobListIdArr;
}
- (NSMutableArray *)jobListNameArr{
    if (!_jobListNameArr) {
        _jobListNameArr = [NSMutableArray array];
    }
    return _jobListNameArr;
}
- (NSMutableArray *)arrData{
    if (!_arrData) {
        _arrData = [NSMutableArray array];
    }
    return _arrData;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.page = 1;
    [self getCpData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpApplyCv" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", self.jobId, @"jobId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)getCpData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [SVProgressHUD dismiss];
        if (self.page == 1) {
            [self.arrData removeAllObjects];
        }
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table1"];
        for (NSDictionary *dict in arrayData) {
            ApplyCvListModel *model = [ApplyCvListModel buildModelWithDic:dict];
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
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        // 回复率
        self.pulldownMenu.replyRate = [self.cpData objectForKey:@"ReplyRate"];
        [self.tableView reloadData];
    }
    else if (request.tag == 2) {
        NSArray *arrayCp = [Common getArrayFromXml:requestData tableName:@"TableCp"];
        self.cpData = [arrayCp objectAtIndex:0];
        [self getData];
    }
}

- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    }
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [viewTitle setBackgroundColor:SEPARATECOLOR];
    return viewTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.menuTableview) {
        return self.jobListNameArr.count;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(tableView == self.menuTableview){
        return 1;
    }
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.menuTableview) {
        return 35;
    }
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[ApplyCvListCell class] contentViewWidth:SCREEN_WIDTH];
//    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
//    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 下拉菜单的cell
    if (tableView == self.menuTableview) {
        UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.textLabel.text = self.jobListNameArr[indexPath.row];
        cell.textLabel.font = DEFAULTFONT;
        cell.backgroundColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    // 简历的cell
    ApplyCvListModel *model = [self.arrData objectAtIndex:indexPath.section];
    ApplyCvListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ApplyCvListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    cell.model = model;
    __weak typeof(self)weakself = self;
    cell.chatBlock = ^(ApplyCvListModel *model) {
        UIButton *tempBtn = [UIButton new];
        tempBtn.tag = indexPath.section;
        [weakself chatClick:tempBtn];
        
    };
    cell.replyBlock = ^(ApplyCvListModel *model) {
        UIButton *tempBtn = [UIButton new];
        tempBtn.tag = indexPath.section;
        [weakself replyClick:tempBtn];
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.menuTableview) {
        self.jobId = self.jobListIdArr[indexPath.row];
        self.pulldownMenu.titleStr = self.jobListNameArr[indexPath.row];
        [self.tableView.mj_header beginRefreshing];
        hideMenu = YES;
        [self setMenuTabViewStatus];
        
        return;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ApplyCvListModel *model = [self.arrData objectAtIndex:indexPath.section];
    CvDetailViewController *cvDetailCtrl = [[CvDetailViewController alloc] init];
    cvDetailCtrl.cvMainId = model.cvMainID;
    cvDetailCtrl.jobId = model.JobID;
    [self.navigationController pushViewController:cvDetailCtrl animated:YES];
}

#pragma mark - 答复
- (void)replyClick:(UIButton *)button {
    ApplyCvListModel *model = [self.arrData objectAtIndex:button.tag];
    UIView *viewContent = [[UIView alloc] init];
    NSString *content = [NSString stringWithFormat:@"答复求职者%@求职申请，积极答复就会赠送10积分呦~", model.paName];
    WKLabel *lbContent = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 20, SCREEN_WIDTH - 30, 1) content:content size:DEFAULTFONTSIZE color:nil spacing:10];
    NSMutableAttributedString *contentString = [[NSMutableAttributedString alloc] initWithString:content];
    [contentString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(5, [model.paName length])];
    [contentString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(content.length - 6, 2)];
    [contentString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, content.length)];
    [lbContent setAttributedText:contentString];
    [viewContent addSubview:lbContent];
    
    UIButton *btnPass = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(lbContent), VIEW_BY(lbContent) + 20, (SCREEN_WIDTH / 2) - 15 - 10, 50)];
    [btnPass setTitle:@"符合要求，我会联系TA" forState:UIControlStateNormal];
    [btnPass setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnPass setBackgroundColor:CPNAVBARCOLOR];
    [btnPass.titleLabel setNumberOfLines:0];
    [btnPass.titleLabel setFont:DEFAULTFONT];
    [btnPass.layer setCornerRadius:5];
    [btnPass setTag:button.tag];
    [btnPass addTarget:self action:@selector(passConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [viewContent addSubview:btnPass];
    
    UIButton *btnDeny = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnPass) + 20, VIEW_Y(btnPass), VIEW_W(btnPass), VIEW_H(btnPass))];
    [btnDeny setTitle:@"暂不合适，放入储备人才库" forState:UIControlStateNormal];
    [btnDeny setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnDeny setBackgroundColor:NAVBARCOLOR];
    [btnDeny.titleLabel setNumberOfLines:0];
    [btnDeny.titleLabel setFont:DEFAULTFONT];
    [btnDeny.layer setCornerRadius:5];
    [btnDeny setTag:button.tag];
    [btnDeny addTarget:self action:@selector(denyConfirm:) forControlEvents:UIControlEventTouchUpInside];
    [viewContent addSubview:btnDeny];
    
    [viewContent setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnPass) + 30)];
    self.replyPop = [[WKPopView alloc] initWithCustomView:viewContent];
    [self.replyPop setDelegate:self];
    [self.replyPop showPopView:self];
}

- (void)passConfirm:(UIButton *)button {
    [self replyApply:button.tag reply:@"1"];
}

- (void)denyConfirm:(UIButton *)button {
    [self replyApply:button.tag reply:@"2"];
}

- (void)replyApply:(NSInteger)tag reply:(NSString *)reply {
    [self.replyPop cancelClick];
    ApplyCvListModel *model = [self.arrData objectAtIndex:tag];
    self.operate = [[CvOperate alloc] init:model.cvMainID paName:model.paName viewController:self];
    [self.operate setDelegate:self];
    [self.operate replyCv:model.ID replyType:reply];
}

- (void)cvOperateFinished {
    self.page = 1;
    [self getCpData];
}

#pragma mark - 聊聊
- (void)chatClick:(UIButton *)button {
    ApplyCvListModel *model = [self.arrData objectAtIndex:button.tag];
    self.operate = [[CvOperate alloc] init:model.cvMainID paName:model.paName viewController:self];
    [self.operate setJobId:model.JobID];
    [self.operate setDelegate:self];
    [self.operate beginChat];
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    [popView cancelClick];
}

- (void)menuTapGesture{
    hideMenu = YES;
    [self setMenuTabViewStatus];
}

#pragma mark - 设置下拉菜单的状态
- (void)setMenuTabViewStatus{
    
    if (hideMenu) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuTableview.alpha = 0;
        } completion:^(BOOL finished) {
            self.menuTableview.hidden = hideMenu;
        }];
    }else{
        self.menuTableview.alpha = 1;
        self.menuTableview.hidden = hideMenu;
    }
}

#pragma mark - 获取发布的所有职位
- (void)getCpJobList{
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [NSString stringWithFormat:@"%ld", self.page], @"intPageNo", @"4", @"intJobStatus", nil];
    [AFNManager requestCpWithMethod:POST ParamDict:paramDict url:@"GetCpJobList" tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        if (requestData.count>0) {
            [self.jobListNameArr addObject:@"全部职位"];
            [self.jobListIdArr addObject:@"0"];
            for (NSDictionary *dic in requestData) {
                [self.jobListNameArr addObject:dic[@"Name"]];
                [self.jobListIdArr addObject:dic[@"ID"]];
            }
        }
        [self addPopMenue];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}

- (void)addPopMenue{
    
    PullDownMenu *pulldownMenu = [[PullDownMenu alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, Menu_H) controller:self Title:@[@"安抚",@"阿斯蒂芬"] replyRate:@""];
    [self.view addSubview:pulldownMenu];
    self.pulldownMenu = pulldownMenu;
    __weak typeof(self)weakself = self;
    self.pulldownMenu.menuClick = ^(NSString *title) {
        hideMenu = !hideMenu;
        [weakself setMenuTabViewStatus];
    };
    
    [self.view addSubview:self.menuTableview];
}
@end

