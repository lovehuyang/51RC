//
//  ChatListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ChatListCpViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "ChatCpViewController.h"
#import "WKLoginView.h"
#import "ChatListCell.h"
#import "ChatListModel.h"

@interface ChatListCpViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) WKLoginView *loginView;
@end

@implementation ChatListCpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"聊聊";
    [SVProgressHUD show];
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - 44) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self getData];
    }];
    self.tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
}

- (NSMutableArray *)arrData{
    if (!_arrData) {
        _arrData = [NSMutableArray array];
    }
    return _arrData;
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    [self.loginView removeFromSuperview];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetChatOnlineList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.tableView.mj_header endRefreshing];
    [SVProgressHUD dismiss];
    [self.arrData removeAllObjects];
    NSArray *tempArr = [Common getArrayFromXml:requestData tableName:@"Table"];
    for (NSDictionary *dict in tempArr) {
        ChatListModel *model = [ChatListModel buildModelWithDic:dict];
        [self.arrData addObject:model];
    }
    [self.tableView reloadData];
    if (self.arrData.count == 0) {
        [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
    }
}

- (void)netRequestFailed:(NetWebServiceRequest *)request didRequestError:(int *)error{
    [SVProgressHUD dismiss];
    [self.tableView.mj_header endRefreshing];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[ChatListCell class] contentViewWidth:SCREEN_WIDTH];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ChatListModel *model = [self.arrData objectAtIndex:indexPath.row];
    ChatListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[ChatListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ChatListModel *model = [self.arrData objectAtIndex:indexPath.row];
    ChatCpViewController *chatCtrl = [[ChatCpViewController alloc] init];
    chatCtrl.title = model.Name;
    chatCtrl.cvMainId = model.cvMainID;
    chatCtrl.caMainId = model.caMainID;
    [self.navigationController pushViewController:chatCtrl animated:YES];
}

@end
