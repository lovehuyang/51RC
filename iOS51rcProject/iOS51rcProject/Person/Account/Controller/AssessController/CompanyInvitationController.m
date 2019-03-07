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

@interface CompanyInvitationController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray *dataArr;
@property (nonatomic , strong) UITableView *tableView;
@end

@implementation CompanyInvitationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [SVProgressHUD show];
    [self getCpInvitTest];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 10, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT - 44 - 44 - 10) style:UITableViewStylePlain];
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
