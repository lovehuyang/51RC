//
//  ConfirmOrderController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ConfirmOrderController.h"
#import "CVTopPackageModel.h"
#import "CVListModel.h"// 简历模型
#import "DiscountInfoModle.h"
#import "ConfirmOrderCell.h"
#import "DiscountCell.h"
#import "PayWayCell.h"
#import "PayWayModel.h"
#import "WXApi.h"
#import "BottomPayView.h"

@interface ConfirmOrderController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *cvDataArr;//简历的数据源
@property (nonatomic , strong) NSMutableArray *discountInfoArr;// 代金券数据源
@property (nonatomic , strong) NSMutableArray *payWayArr;//支付方式数据源
@property (nonatomic , strong) BottomPayView *bottomPayView;//底部支付按钮
@end

@implementation ConfirmOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"确认订单";
    [self.view addSubview:self.tableView];
    [self createUI];
    [self getConfirmOrder];
}
- (void)createUI{
    UILabel *titleLab = [UILabel new];
    [self.view addSubview:titleLab];
    titleLab.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(44);
    titleLab.font = DEFAULTFONT;
    titleLab.text = [NSString stringWithFormat:@"    套餐:%@",self.model.orderName];
    UILabel *priceLab = [UILabel new];
    [titleLab addSubview:priceLab];
    priceLab.sd_layout
    .rightSpaceToView(titleLab, 10)
    .topSpaceToView(titleLab, 0)
    .bottomSpaceToView(titleLab, 0);
    priceLab.textColor = NAVBARCOLOR;
    priceLab.textAlignment = NSTextAlignmentRight;
    priceLab.text = [NSString stringWithFormat:@"￥%@",self.model.nowPrice];
    priceLab.font = DEFAULTFONT;
}
- (void)createBottomView{
    
    // 计算优惠的金额
    CGFloat totalDiscountMoney = 0;
    for (DiscountInfoModle *model in self.discountInfoArr) {
        CGFloat discountMoney = [model.Money floatValue];
        totalDiscountMoney =+discountMoney;
    }
    // 计算应付的金额
    CGFloat totalMoney = [self.model.nowPrice floatValue] - totalDiscountMoney;

    if (!_bottomPayView) {
        BottomPayView *bottomPayView = [BottomPayView new];
        [self.view addSubview:bottomPayView];
        bottomPayView.sd_layout
        .leftSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .bottomSpaceToView(self.view, 0)
        .heightIs(45);
        self.bottomPayView = bottomPayView;
    }
    self.bottomPayView.money = [NSString stringWithFormat:@"%.2f",totalMoney];
    self.bottomPayView.payEvent = ^{
        NSLog(@"去支付");
    };
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - 44) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = SEPARATECOLOR;
        _tableView.tableFooterView = [UIView new];
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

- (NSMutableArray *)cvDataArr{
    if (!_cvDataArr) {
        _cvDataArr = [NSMutableArray array];
    }
    return _cvDataArr;
}
- (NSMutableArray *)discountInfoArr{
    if (!_discountInfoArr) {
        _discountInfoArr = [NSMutableArray array];
    }
    return _discountInfoArr;
}

- (NSMutableArray *)payWayArr{
    if (!_payWayArr) {
        _payWayArr = [NSMutableArray array];
        NSMutableArray *payWayArr = [NSMutableArray arrayWithObjects:@"支付宝支付",@"微信支付",nil];
        NSMutableArray *logoNameArr = [NSMutableArray arrayWithObjects:@"icon_alipay",@"icon_wechat_pay",nil];
        
        for (int i = 0; i<payWayArr.count; i ++) {
            PayWayModel *model = [[PayWayModel alloc]init];
            model.payWay = payWayArr[i];
            model.logoName = logoNameArr[i];
            if (i == 0) {
                model.isSelected = YES;
            }else{
                model.isSelected = NO;
            }
            [_payWayArr addObject:model];
        }
    }
    return _payWayArr;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self)weakself = self;
    if (indexPath.section == 0) {
        ConfirmOrderCell *cell = [[ConfirmOrderCell alloc]initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:nil indexPath:indexPath];
        if(indexPath.row > 0){
            cell.cvModel = self.cvDataArr[indexPath.row - 1];
        }
        cell.selectCvBlock = ^(CVListModel *cvModel) {
            for (CVListModel *model in weakself.cvDataArr) {
                if ([model.ID isEqualToString:cvModel.ID]) {
                    model.isSlected = YES;
                }else{
                    model.isSlected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if(indexPath.section == 1 && self.discountInfoArr.count){
        DiscountCell *cell = [[DiscountCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.discountModel = self.discountInfoArr[indexPath.row - 1];
        }
        cell.selectDiscountBlock = ^(DiscountInfoModle *discountModel) {
            for (DiscountInfoModle *modle in self.discountInfoArr) {
                if ([modle.ID isEqualToString:discountModel.ID]) {
                    modle.isSelceted = YES;
                }else{
                    modle.isSelceted = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 2 && self.discountInfoArr.count){
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            for (PayWayModel *modle in self.payWayArr) {
                if ([modle.payWay isEqualToString:payModel.payWay]) {
                    modle.isSelected = YES;
                }else{
                    modle.isSelected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }else if (indexPath.section == 1 && self.discountInfoArr.count == 0){
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            for (PayWayModel *modle in self.payWayArr) {
                if ([modle.payWay isEqualToString:payModel.payWay]) {
                    modle.isSelected = YES;
                }else{
                    modle.isSelected = NO;
                }
            }
            [weakself.tableView reloadData];
        };
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
    return nil;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.discountInfoArr.count > 0) {
        return 3;
    }
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.discountInfoArr.count > 0) {
        if (section == 0) {
            return self.cvDataArr.count + 1;
        }else if (section == 1){
            return self.discountInfoArr.count + 1;
        }else{
            return self.payWayArr.count + 1;
        }
    }else{
        if (section == 0) {
            return self.cvDataArr.count + 1;
        }else{
            return self.payWayArr.count + 1;
        }
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
    headerView.backgroundColor = SEPARATECOLOR;
    return headerView;
}
- (void)getConfirmOrder{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderService":self.model.orderService
                                };
    [AFNManager requestPaWithParamDict:paramDict url:URL_GETCONFIRMORDER tableNames:@[@"CvMainInfo",@"DiscountInfo"] successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        // 简历数据
        NSArray *cvArr = [requestData firstObject];
        for (NSDictionary *dict in cvArr) {
            CVListModel *model = [CVListModel buildModelWithDic:dict];
            [self.cvDataArr addObject:model];
        }
        for (CVListModel *model in self.cvDataArr) {
            if ([model.Valid boolValue] ) {
                model.isSlected = YES;
                break;
            }
        }
        
        if (requestData.count>1) {
            NSArray *discountArr = [requestData objectAtIndex:1];
            for (NSDictionary *dict in discountArr) {
                DiscountInfoModle *model = [DiscountInfoModle buildModelWithDic:dict];
                [self.discountInfoArr addObject:model];
            }
        }
        
        for (DiscountInfoModle *model in self.discountInfoArr) {
            model.isSelceted = YES;
            break;
        }
        [self createBottomView];
        [self.tableView reloadData];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}


@end
