//
//  ConfirmOrderController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/7.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ConfirmPaymentOrderController.h"
#import "OrderListModel.h"
#import "AlertView.h"
#import "Common.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ConfirmPaymentOrderController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger sectionNum;//
}
@property (nonatomic , copy) NSString *orderID;// 订单的id
@property (nonatomic , copy) NSString *cvMainID;// 简历的id
@property (nonatomic , strong)UITableView *tableview;
@property (nonatomic , strong)UIView *footView;
@end

@implementation ConfirmPaymentOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.model.DiscountMoney != nil && self.model.DiscountMoney.length) {
        sectionNum = 4;
    }else{
        sectionNum = 3;
    }
    
    self.title = @"确认订单";
    self.view.backgroundColor = SEPARATECOLOR;
    [self getWaitPayOrder];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayFailed) name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(alipaySuccess) name:NOTIFICATION_ALIPAYSUCCESS object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYSUCCESS object:nil];
}
- (void)dealloc{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = SEPARATECOLOR;
        _tableview.tableFooterView = self.footView;
    }
    return _tableview;
}

- (UIView *)footView{
    if (!_footView) {
        _footView = [UIView new];
        _footView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 80);
        
        CGFloat btn_W = (SCREEN_WIDTH - 30 - 30)/2;
        UIButton *payBtn = [UIButton new];
        [_footView addSubview:payBtn];
        payBtn.sd_layout
        .leftSpaceToView(_footView, 15)
        .centerYEqualToView(_footView)
        .widthIs(btn_W)
        .heightIs(35);
        payBtn.backgroundColor = NAVBARCOLOR;
        payBtn.sd_cornerRadius = @(5);
        [payBtn setTitle:@"去付款" forState:UIControlStateNormal];
        payBtn.titleLabel.font = DEFAULTFONT;
        payBtn.tag = 100;
        [payBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *cancelBtn = [UIButton new];
        [_footView addSubview:cancelBtn];
        cancelBtn.sd_layout
        .rightSpaceToView(_footView, 15)
        .centerYEqualToView(payBtn)
        .widthIs(btn_W)
        .heightRatioToView(payBtn, 1);
        cancelBtn.backgroundColor = [UIColor lightGrayColor];
        cancelBtn.sd_cornerRadius = @(5);
        cancelBtn.titleLabel.font = DEFAULTFONT;
        [cancelBtn setTitle:@"取消订单" forState:UIControlStateNormal];
        cancelBtn.tag = 101;
        [cancelBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cell.textLabel.text = [NSString stringWithFormat:@"订单号：%@",self.model.payOrderNum];
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
        }else if (indexPath.row == 1){
            cell.textLabel.text = self.model.cvOrderName;
            [cell.textLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
            UILabel *priceLab = [UILabel new];
            [cell.contentView addSubview:priceLab];
            priceLab.sd_layout
            .rightSpaceToView(cell.contentView, 5)
            .centerYEqualToView(cell.contentView)
            .heightRatioToView(cell.contentView, 1);
            priceLab.textAlignment = NSTextAlignmentRight;
            [priceLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
            priceLab.textColor = NAVBARCOLOR;
            NSString *priceText = [NSString stringWithFormat:@"￥%@元",self.model.OrderMoney];
            if (self.model.DiscountMoney != nil && self.model.DiscountMoney.length) {
                priceText = [NSString stringWithFormat:@"￥%@",self.model.OrderMoney];
            }
            priceLab.text = priceText;;
        }
    }else if (indexPath.section == 1){
        cell.textLabel.text = self.model.CvName;
        cell.textLabel.font = DEFAULTFONT;
    
    }else if (indexPath.section == 2 && sectionNum == 4){
        cell.textLabel.text = [NSString stringWithFormat:@"%@元代金券",self.model.DiscountMoney];;
        cell.textLabel.font = DEFAULTFONT;
        
    }else if ((indexPath.section == 2 && sectionNum == 3) || (sectionNum == 4 && indexPath.section == 3)){
        UIImageView *logoImgView = [UIImageView new];
        [cell.contentView addSubview:logoImgView];
        logoImgView.sd_layout
        .leftSpaceToView(cell.contentView, 15)
        .centerYEqualToView(cell.contentView)
        .widthIs(25)
        .heightEqualToWidth();
        
        UILabel *payMethodLab = [UILabel new];
        [cell.contentView addSubview:payMethodLab];
        payMethodLab.sd_layout
        .leftSpaceToView(logoImgView, 5)
        .centerYEqualToView(cell.contentView)
        .heightRatioToView(cell.contentView, 1);
        [payMethodLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
        payMethodLab.font = DEFAULTFONT;
        
        if ([self.model.payMethod isEqualToString:@"1"]) {// 微信
            logoImgView.image = [UIImage imageNamed:@"icon_wechat_pay"];
            payMethodLab.text = @"微信支付";
        }else{// 支付宝
            logoImgView.image = [UIImage imageNamed:@"icon_alipay"];
            payMethodLab.text = @"支付宝支付";
        }
    }
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return sectionNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 0) {
        return 2;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 10;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [UIView new];
    view.backgroundColor = SEPARATECOLOR;
    return view;
}

#pragma mark - 点击事件
- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {// 去付款
        [self payMoney];
        
    }else if (btn.tag == 101){//
        AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        __weak __typeof(alertView)WeakAlertView = alertView;
        [WeakAlertView initWithTitle:@"提示" content:@"确定要取消此订单么？" btnTitleArr:@[@"取消",@"确定"] canDismiss:YES];
        WeakAlertView.clickButtonBlock = ^(UIButton *button) {
            if (button.tag == 101) {// 确定
                [self cancelOrder];
            }
        };
        [WeakAlertView show];
    }
}

- (void)cancelOrder{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderID":self.orderID
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_WEIXINORDERCANCEL tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        if ([(NSString *)dataDict isEqualToString:@"1"] ) {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_CANCELORDER object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
    
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

- (void)getWaitPayOrder{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderNum":self.model.payOrderNum
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETWAITPAYORDER tableName:@"WaitPayOrderList" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        self.orderID = dataDict[@"ID"];
        self.cvMainID = dataDict[@"cvMainID"];
        [self.view addSubview:self.tableview];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}


- (void)payMoney{
//    [SVProgressHUD show];
    
    // ip地址
    NSString *ipStr = [Common getIPaddress];

    
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"cvmainId":self.cvMainID,
                                @"orderid":self.orderID,
                                @"orderType":self.model.orderService,
                                @"payMoney":self.model.OrderMoney,
                                @"discountID":self.model.paOrderDiscountID,// 代金券id
                                @"payMethodID":self.model.payMethod,
                                @"mobileIP":[self.model.payMethod integerValue] == 2? @"":ipStr,
                                @"payFrom":@"4"
                                };
    
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"GetAppPayOrderIOS" tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        if ([self.model.payMethod integerValue] == 1) {
            DLog(@"");
//            [self wxpayParamData:(NSString *)dataDict];
        }else if ([self.model.payMethod integerValue] == 2){
            DLog(@"");
            [self alipayParamData:(NSString *)dataDict];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 支付宝支付
- (void)alipayParamData:(NSString *)dataStr{
    // 获取appScheme
    NSDictionary *plistDic = [[NSBundle mainBundle] infoDictionary];
    NSArray * arr = plistDic[@"CFBundleURLTypes"];
    NSString * appScheme = [[[arr objectAtIndex:1] objectForKey:@"CFBundleURLSchemes"] firstObject];
    
    [[AlipaySDK defaultService]payOrder:dataStr fromScheme:appScheme callback:^(NSDictionary *resultDic) {
        
        if ([resultDic[@"resultStatus"] isEqualToString:@"9000"]){
            [self alipaySuccess];
        }else{
            [self alipayFailed];
        }
    }];
}

#pragma mark - 支付宝支付成功
- (void)alipaySuccess{
    self.alipayResult(YES);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"支付宝支付成功"];
}

#pragma mark - 支付宝支付失败
- (void)alipayFailed{
    self.alipayResult(NO);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"支付支付失败，请重新支付"];
}
@end
