//
//  MyselfAssessIndexController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyselfAssessIndexController.h"
#import "AssessIndexWebController.h"
#import "MyselfAssessModel.h"
#import "MyselfAssessCell.h"
#import "AssessPayAlert.h"
#import "AssessIndexModel.h"
#import "ConfirmAssessOrderController.h"
#import "AssessDeliverAlert.h"
#import "EmptyDataView.h"

@interface MyselfAssessIndexController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , strong) NSMutableArray *dataArr;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) EmptyDataView *emptyView;
@end

@implementation MyselfAssessIndexController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self getMyAssessTest];
    [SVProgressHUD show];
    [self.view addSubview:self.tableView];
    self.view.backgroundColor = SEPARATECOLOR;
    [self createEmptyView];
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
- (void)createEmptyView{
    self.emptyView = [[EmptyDataView alloc]initWithTip:@"呀！您还没做过人才测评"];
    [self.view addSubview:self.emptyView];
    self.emptyView.sd_layout
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 120);
    self.emptyView.hidden = YES;
    __weak typeof(self)weakself = self;
    self.emptyView.emptyDataTouch = ^{
        [weakself getMyAssessTest];
    };
}
#pragma mark - UITableViewDelegate , UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    MyselfAssessModel *model = [self.dataArr objectAtIndex:indexPath.row];
    MyselfAssessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myselfAssessCell"];
    if (cell == nil) {
        cell = [[MyselfAssessCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myselfAssessCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.model = model;
    cell.cellBlock = ^(MyselfAssessModel *myselfModel, UIButton *button) {
        if (button.tag == 100) {// 查看报告
            NSString *urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/report/%@?PaMainID=%@&Code=%@",[USER_DEFAULT valueForKey:@"subsite"],myselfModel.ID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
            AssessIndexWebController *avc = [AssessIndexWebController new];
            avc.urlString = urlStr;
            [self.navigationController pushViewController:avc animated:YES];
            
        }else if (button.tag == 101){// 重新测评
            [self reAssessIndex:myselfModel];
            
            
        }else if (button.tag == 102){// 继续完成测评
            NSString *urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/test?AssessTypeID=%@&PaMainID=%@&Code=%@",[USER_DEFAULT valueForKey:@"subsite"],myselfModel.AssessTypeID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
            AssessIndexWebController *avc = [AssessIndexWebController new];
            avc.urlString = urlStr;
            [self.navigationController pushViewController:avc animated:YES];
        }else if (button.tag == 103){
            [self ChangeAssessStatus:myselfModel];
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
//    return 200;
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[MyselfAssessCell class] contentViewWidth:SCREEN_WIDTH];
}

#pragma mark - 我的测评
- (void)getMyAssessTest{
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT valueForKey:@"paMainCode"]
                                };
    
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETMYASSESSYEST tableName:@"ds" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        [self.dataArr removeAllObjects];
        if (requestData != nil) {
            for (NSDictionary *dict in requestData) {
                MyselfAssessModel *model = [MyselfAssessModel buildModelWithDic:dict];
                [self.dataArr addObject:model];
            }
        }
        
        if (self.dataArr.count > 0) {
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

- (void)ChangeAssessStatus:(MyselfAssessModel *)model{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT valueForKey:@"paMainCode"],
                                @"assessTestLogID":model.ID,
                                @"isOpen":[model.IsOpen boolValue]?@"1":@"0"
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"ChangeAssessStatus" tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        [self getMyAssessTest];
        if((dataDict != nil) && [(NSString *)dataDict isEqualToString:@"1"]){
            
            NSString *titleStr = nil;
            NSString *markStr = nil;
            NSString *contenStr = nil;
            if ([model.IsOpen boolValue]) {
                titleStr = @"已成功修改为不可投递状态";
                markStr = @"不可投递";
                contenStr = @"申请职位时，不投递本份测评报告。";
            }else{
                titleStr = @"已成功修改为可投递状态";
                markStr = @"可投递";
                contenStr = @"申请职位时，自动投递本份测评报告。";
            }
            
            AssessDeliverAlert *alert = [[AssessDeliverAlert alloc]init];
            [alert setTitle:titleStr markContent:markStr content:contenStr btnTitle:@"知道了"];
            [alert show];
            
        }else{
            [RCToast showMessage:@"设置失败"];
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:@"设置失败"];
    }];
}

#pragma mark - 重新测评
- (void)reAssessIndex:(MyselfAssessModel*)model{
    
    if([model.isPay boolValue]){// 已经支付
        
        AssessPayAlert *alert = [AssessPayAlert new];
        alert.content = @"重新测评会覆盖之前的测评报告。";
        alert.title = @"重新测评";
        alert.btnStr = @"继续测评";
        alert.clickAssessPayBlock = ^{
            
            NSString *urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/NoticeBegin?AssessTypeID=%@&PaMainID=%@&Code=%@",[USER_DEFAULT valueForKey:@"subsite"],model.AssessTypeID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
            AssessIndexWebController *avc = [AssessIndexWebController new];
            avc.urlString = urlStr;
            [self.navigationController pushViewController:avc animated:YES];
        };
        [alert show];
        return;
    }
    
    AssessPayAlert *alert = [AssessPayAlert new];
    alert.content = [NSString stringWithFormat:@"重新测评会覆盖之前的测评报告。该测评为付费测评，价格为￥%@元。",model.price];
    alert.title = @"重新测评";
    alert.btnStr = @"付费";
    alert.clickAssessPayBlock = ^{
        ConfirmAssessOrderController *cvc = [[ConfirmAssessOrderController alloc]init];
        AssessIndexModel *assessModel = [[AssessIndexModel alloc]init];
        assessModel.Price= model.price;
        assessModel.ID = model.AssessTypeID;
        assessModel.Name = model.AssessTypeName;
        cvc.assessModel = assessModel;
        
        cvc.sendbackAssessType = ^(BOOL paySuccess, AssessIndexModel *assessModel) {
            
            if (paySuccess) {// 支付成功
                
                [RCToast showMessage:@"支付成功"];
            
            }else{// 支付失败
                [RCToast showMessage:@"支付失败"];
                
            }
        };
        [self.navigationController pushViewController:cvc animated:YES];
    };
    [alert show];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getMyAssessTest];
}


@end
