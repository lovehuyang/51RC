//
//  AccountListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  用户设置页面

#import "AccountListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "PreviewViewController.h"
#import "WKNavigationController.h"
#import "OrderApplyViewController.h"
#import "AccountSafeViewController.h"
#import "AccountInfoViewController.h"
#import "AccountListModel.h"
#import "CpMainInfoModel.h"
#import "AccountListCell.h"

@interface AccountListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) CpMainInfoModel *companyModel;

@end

@implementation AccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    [self getData];
}

#pragma mark - 懒加载
- (NSMutableArray *)arrData{
    if (!_arrData) {
        _arrData = [NSMutableArray array];
    }
    return _arrData;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetAccountList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainId", CAMAINCODE, @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.arrData removeAllObjects];
        NSArray *tempArr = [Common getArrayFromXml:requestData tableName:@"dtList"];
        for (NSDictionary *dict in tempArr) {
            AccountListModel *model = [AccountListModel buildModelWithDic:dict];
            [self.arrData addObject:model];
        }
        NSDictionary *dict = [[Common getArrayFromXml:requestData tableName:@"dtCp"] objectAtIndex:0];
        self.companyModel = [CpMainInfoModel buildModelWithDic:dict];
        [self.tableView reloadData];
    }
    else {
        [self getData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        WKLabel *lbUserCount = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 0, SCREEN_WIDTH, 40) content:[NSString stringWithFormat:@"当前用户数配额为%@个", self.companyModel.MaxUserNumber] size:DEFAULTFONTSIZE color:nil];
        NSMutableAttributedString *userCountString = [[NSMutableAttributedString alloc] initWithString:lbUserCount.text];
        [userCountString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(8, [self.companyModel.MaxUserNumber length])];
        [lbUserCount setAttributedText:userCountString];
        [viewContent addSubview:lbUserCount];
        
        WKButton *btnBuy = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(SCREEN_WIDTH - 100, 0, 85, VIEW_H(lbUserCount)) image:@"cp_accountbuy.png" title:@"购买用户数" fontSize:DEFAULTFONTSIZE color:NAVBARCOLOR bgColor:nil];
        [btnBuy addTarget:self action:@selector(buyClick) forControlEvents:UIControlEventTouchUpInside];
        [viewContent addSubview:btnBuy];
        
        UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbUserCount), SCREEN_WIDTH, 10)];
        [viewTitle setBackgroundColor:SEPARATECOLOR];
        [viewContent addSubview:viewTitle];
        
        return viewContent;
    }
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
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[AccountListCell class] contentViewWidth:SCREEN_WIDTH];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AccountListModel *model = [self.arrData objectAtIndex:indexPath.section];
    AccountListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[AccountListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    cell.indexPath = indexPath;
    cell.model = model;
    __weak typeof(self)weakSelf = self;
    cell.cellBlock = ^(WKButton *button, NSString *event) {
        if ([event isEqualToString:@"startClick"]) {
            [weakSelf startClick:button];
        }else if ([event isEqualToString:@"pauseClick"]) {
            [weakSelf pauseClick:button];
        }else if ([event isEqualToString:@"safeClick"]) {
            [weakSelf safeClick:button];
        }else if ([event isEqualToString:@"userClick"]) {
            [weakSelf userClick:button];
        }
    };
    return cell;
}

- (void)startClick:(UIButton *)button {
    [self operateUser:@"确定要启用该用户吗？" index:button.tag];
}

- (void)pauseClick:(UIButton *)button {
    [self operateUser:@"确定要暂停该用户吗？" index:button.tag];
}

- (void)operateUser:(NSString *)title index:(NSInteger)index {
    AccountListModel *model = [self.arrData objectAtIndex:index];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"ChangeAccountStatus" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", model.ID, @"caMainIDChange", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)safeClick:(UIButton *)button {
    AccountListModel *model = [self.arrData objectAtIndex:button.tag];
    AccountSafeViewController *accountSafeCtrl = [[AccountSafeViewController alloc] init];
    accountSafeCtrl.caMainId = model.ID;
    accountSafeCtrl.title = model.Name;
    [self.navigationController pushViewController:accountSafeCtrl animated:YES];
}

- (void)userClick:(UIButton *)button {
    AccountListModel *model = [self.arrData objectAtIndex:button.tag];
    AccountInfoViewController *accountInfoCtrl = [[AccountInfoViewController alloc] init];
    accountInfoCtrl.caMainId = model.ID;
    [self.navigationController pushViewController:accountInfoCtrl animated:YES];
}

- (void)buyClick {
    OrderApplyViewController *orderApplyCtrl = [[OrderApplyViewController alloc] init];
    orderApplyCtrl.urlString = [NSString stringWithFormat:@"http://%@/company/order/applysuborder?ordertype=11", [USER_DEFAULT valueForKey:@"subsite"]];
    [self.navigationController pushViewController:orderApplyCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AccountListModel *model = [self.arrData objectAtIndex:indexPath.section];
    AccountInfoViewController *accountInfoCtrl = [[AccountInfoViewController alloc] init];
    accountInfoCtrl.caMainId = model.ID;
    [self.navigationController pushViewController:accountInfoCtrl animated:YES];
}

@end
