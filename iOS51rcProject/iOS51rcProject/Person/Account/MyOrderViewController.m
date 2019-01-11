//
//  MyOrderViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyOrderViewController.h"
#import "ConfirmPaymentOrderController.h"
#import "MyOrderCell.h"
#import "OrderListModel.h"

@interface MyOrderViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *dataArr;// 数据源
@end

@implementation MyOrderViewController
- (instancetype)init{
    if (self = [super init]) {
        self.title = @"我的订单";
        self.view.backgroundColor = SEPARATECOLOR;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [SVProgressHUD show];
    UILabel *tipLab = [UILabel new];
    [self.view addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(self.view, 15)
    .rightSpaceToView(self.view, 15)
    .topSpaceToView(self.view, 0)
    .heightIs(40);
    tipLab.text = @"以下是您的简历置顶订单，记录保存12个月";
    tipLab.font = DEFAULTFONT;
    [self.view addSubview:self.tableView];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{

        [self getPaOrderList];
    }];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(beginRefreah) name:NOTIFICATION_CANCELORDER object:nil];
    
    // GCD延时执行
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getPaOrderList];
    });
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_CANCELORDER object:nil];
}

- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

- (void)getPaOrderList{

    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT valueForKey:@"paMainCode"]
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETPAORDERLIST tableName:@"PaOrderList" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        [self.dataArr removeAllObjects];
        if (requestData.count) {
            for (NSDictionary *dict in requestData) {
                OrderListModel *model = [OrderListModel buildModelWithDic:dict];
                [self.dataArr addObject:model];
            }
        }
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 40) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = SEPARATECOLOR;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OrderListModel *model = [self.dataArr objectAtIndex:indexPath.row];
    MyOrderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"myOrderCell"];
    if (cell == nil) {
       cell = [[MyOrderCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myOrderCell"];
    }
    cell.model = model;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    OrderListModel *model = [self.dataArr objectAtIndex:indexPath.row];
    if ([model.cvTopStatus isEqualToString:@"待支付"]) {
        ConfirmPaymentOrderController *cvc = [[ConfirmPaymentOrderController alloc]init];
        cvc.model = self.dataArr[indexPath.row];
        __weak typeof(self)weakself = self;
        cvc.payResult = ^(BOOL success) {
            if (success) {
                [weakself.tableView.mj_header beginRefreshing];
            }else{
                [weakself.tableView.mj_header beginRefreshing];
            }
        };
        [self.navigationController pushViewController:cvc animated:YES];
    }else{
        DLog(@"不能点击");
    }
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[MyOrderCell class] contentViewWidth:SCREEN_WIDTH];
}

- (void)beginRefreah{
    [self.tableView.mj_header beginRefreshing];
}
@end
