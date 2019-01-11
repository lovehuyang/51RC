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
#import "WXApi.h"

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
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(wxpayFailed) name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(InquireWeiXinOrder:) name:NOTIFICATION_WXPAYSUCCESS object:nil];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_ALIPAYSUCCESS object:nil];
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYFAILED object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_WXPAYSUCCESS object:nil];
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
    [SVProgressHUD show];
    
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
            [self wxpayParamData:(NSString *)dataDict];
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
            // 查询支付结果
            NSString *result = resultDic[@"result"];
            NSDictionary *resultDict = [CommonTools translateJsonStrToDictionary:result];
            NSString *out_trade_no = [resultDict[@"alipay_trade_app_pay_response"] objectForKey:@"out_trade_no"];
            [self InquireWeiXinOrder:out_trade_no];

        }else{
            [self alipayFailed];
        }
    }];
}

#pragma mark - 微信支付
- (void)wxpayParamData:(NSString *)dataStr{
    NSDictionary *dataDict = [CommonTools translateJsonStrToDictionary:dataStr];
    
    if ([dataDict[@"prepayid"] length] == 0 || dataDict[@"prepayid"] == nil ) {
        [RCToast showMessage:@"请到您提交订单的平台完成支付或重新提交订单"];
        return;
    }
    
    
    //需要创建这个支付对象
    PayReq *req   = [[PayReq alloc] init];
    //由用户微信号和AppID组成的唯一标识，用于校验微信用户
    req.openID = [dataDict objectForKey:@"appid"];
    
    // 商家id，在注册的时候给的
    req.partnerId =  [dataDict objectForKey:@"partnerid"];
    
    // 预支付订单这个是后台跟微信服务器交互后，微信服务器传给你们服务器的，你们服务器再传给你
    req.prepayId  =  [dataDict objectForKey:@"prepayid"];
    
    [[NSUserDefaults standardUserDefaults]setObject:dataDict[@"outTradeNo"] forKey:KEY_PAYORDERNUM];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    // 根据财付通文档填写的数据和签名
    //这个比较特殊，是固定的，只能是即req.package = Sign=WXPay
    req.package   =  [dataDict objectForKey:@"package"];
    
    // 随机编码，为了防止重复的，在后台生成
    req.nonceStr  =  [dataDict objectForKey:@"noncestr"];
    
    // 这个是时间戳，也是在后台生成的，为了验证支付的
    NSString * stamp =  [dataDict objectForKey:@"timestamp"];
    req.timeStamp = stamp.intValue;
    
    // 这个签名也是后台做的
    req.sign =  [dataDict objectForKey:@"sign"];
    
    //发送请求到微信，等待微信返回onResp
    [WXApi sendReq:req];
}

#pragma mark - 支付宝支付成功
- (void)alipaySuccess{
    self.payResult(YES);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"支付宝支付成功"];
}

#pragma mark - 支付宝支付失败
- (void)alipayFailed{
    self.payResult(NO);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"支付支付失败，请重新支付"];
}

#pragma mark - 微信支付通知

- (void)wxpayFailed{
    
    self.payResult(NO);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"微信支付失败，请重新支付"];
}

- (void)wxpaySuccess{
    
    self.payResult(YES);
    [self.navigationController popViewControllerAnimated:NO];
    [RCToast showMessage:@"微信支付成功"];
}
#pragma mark - 支付宝/微信查询支付结果
- (void)InquireWeiXinOrder:(NSString *)orderNum{
    if (![orderNum isKindOfClass:[NSString class]]) {
        orderNum = [[NSUserDefaults standardUserDefaults]objectForKey:KEY_PAYORDERNUM];
    }
    
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderNum":orderNum
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_INQUIREWEIXINORDER tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        NSString *result = (NSString *)dataDict;
        if (result != nil && [result isEqualToString:@"1"]) {
            if ([self.model.payMethod integerValue] == 2) {
                [self alipaySuccess];
            }else if ([self.model.payMethod integerValue] == 1){
                [self wxpaySuccess];
            }
        }else{
            if ([self.model.payMethod integerValue] == 2) {
                [self alipayFailed];
            }else if ([self.model.payMethod integerValue] == 1){
                [self wxpayFailed];
            }
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}

@end
