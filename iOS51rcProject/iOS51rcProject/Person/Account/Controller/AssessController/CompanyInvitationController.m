//
//  CompanyInvitationController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "CompanyInvitationController.h"
#import "AssessIndexWebController.h"
#import "CpInvitTestModel.h"
#import "CpInvitTestCell.h"
#import "EmptyDataView.h"

@interface CompanyInvitationController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray *dataArr;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) EmptyDataView *emptyView;
@end

@implementation CompanyInvitationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [SVProgressHUD show];
    [self getCpInvitTest];
    [self createEmptyView];
}

- (void)createEmptyView{
    self.emptyView = [[EmptyDataView alloc]initWithTip:@"还没有企业邀请您"];
    [self.view addSubview:self.emptyView];
    self.emptyView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 120);
    self.emptyView.hidden = YES;
    __weak typeof(self)weakself = self;
    self.emptyView.emptyDataTouch = ^{
        [weakself getCpInvitTest];
    };
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - 44 - 44) style:UITableViewStylePlain];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = SEPARATECOLOR;
    }
    return _tableView;
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

#pragma mark - UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CpInvitTestModel *model = [self.dataArr objectAtIndex:indexPath.row];
    CpInvitTestCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cpInvitCell"];
    if (cell == nil) {
        cell = [[CpInvitTestCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cpInvitCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    cell.cellBlock = ^(CpInvitTestModel *model) {
        
        NSString *urlStr = nil;
        if([model.isAssessStatus isEqualToString:@"0"]){// 开始测评
            urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/NoticeBegin?AssessTypeID=%@&PaMainID=%@&Code=%@&CpInviteID=%@",[USER_DEFAULT valueForKey:@"subsite"],model.AssessTypeID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"],model.ID];
        }else{// 继续测评
            urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/test?AssessTypeID=%@&PaMainID=%@&Code=%@&TestLogID=%@",[USER_DEFAULT valueForKey:@"subsite"],model.AssessTypeID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"],model.AssessTestLogID];
        }
        AssessIndexWebController *avc = [AssessIndexWebController new];
        avc.urlString = urlStr;
        [self.navigationController pushViewController:avc animated:YES];
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//        return 200;
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[CpInvitTestCell class] contentViewWidth:SCREEN_WIDTH];
}

- (void)getCpInvitTest{
    
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT valueForKey:@"paMainCode"]
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETCPINVITTEST tableName:@"ds" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        [self.dataArr removeAllObjects];
        if (requestData !=  nil) {
            for (NSDictionary *dict in requestData) {
                CpInvitTestModel *model = [CpInvitTestModel buildModelWithDic:dict];
                [self.dataArr addObject:model];
            }
        }
        if(self.dataArr.count > 0){
            self.tableView.hidden = NO;
            self.emptyView.hidden = YES;
        }else{
            self.tableView.hidden = YES;
            self.emptyView.hidden = NO;
        }
        
        [self.tableView reloadData];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getCpInvitTest];
}
@end
