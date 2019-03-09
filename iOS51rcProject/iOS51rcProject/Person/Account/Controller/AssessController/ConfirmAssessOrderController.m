//
//  ConfirmAssessOrderController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ConfirmAssessOrderController.h"
#import "BottomPayView.h"
#import "PayWayCell.h"
#import "AssessIndexModel.h"
#import "Common.h"
#import "WXApi.h"
#import "PayWayModel.h"
#import <AlipaySDK/AlipaySDK.h>

@interface ConfirmAssessOrderController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSInteger payMethodID;// 支付方式1微信（默认），2支付宝
}
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) BottomPayView *bottomPayView;//底部支付按钮
@property (nonatomic , strong) NSMutableArray *payWayArr;// 支付方式

@end

@implementation ConfirmAssessOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"确认订单";
    payMethodID = 1;
    [self createBottomView];
    [self.view addSubview:self.tableView];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT- 45) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = SEPARATECOLOR;
        _tableView.tableFooterView = [UIView new];
        //        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}
- (void)createBottomView{
    
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
    self.bottomPayView.money = self.assessModel.Price;
    __weak typeof(self)weakself = self;
    self.bottomPayView.payEvent = ^{
        // 检测时候否安装了微信客户端
        BOOL install = [WXApi isWXAppInstalled];
        
        if (!install && payMethodID == 1) {
            [RCToast showMessage:@"您未安装微信客户端"];
            return ;
        }
        
        [weakself getAppPayOrder];
    };
}
- (NSMutableArray *)payWayArr{
    if (!_payWayArr) {
        _payWayArr = [NSMutableArray array];
        NSMutableArray *payWayArr = [NSMutableArray arrayWithObjects:@"微信支付",@"支付宝支付",nil];
        NSMutableArray *logoNameArr = [NSMutableArray arrayWithObjects:@"icon_wechat_pay",@"icon_alipay",nil];
        
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
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    
    if(indexPath.section ==0 ){
        if (indexPath.row == 0) {
            cell.textLabel.text = @"人才测评";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
        }else if (indexPath.row == 1){
            cell.textLabel.text = @"测评类型";
            cell.textLabel.font = DEFAULTFONT;
            cell.detailTextLabel.textColor = [UIColor blackColor];
            cell.detailTextLabel.text = self.assessModel.Name;
            cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
        }else{
            NSString *priceStr = [NSString stringWithFormat:@"价格:￥%@",self.assessModel.Price];
            cell.detailTextLabel.textColor = NAVBARCOLOR;
            cell.detailTextLabel.font = DEFAULTFONT;
            NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:priceStr];
            [AttributedStr addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, 3)];
            cell.detailTextLabel.attributedText = AttributedStr;
        }
    }
    
    if (indexPath.section == 1) {
        PayWayCell *cell = [[PayWayCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil indexPath:indexPath];
        if (indexPath.row > 0) {
            cell.payModel = self.payWayArr[indexPath.row - 1];
        }
        cell.selectPayWay = ^(PayWayModel *payModel) {
            if([payModel.payWay containsString:@"微信"]){
                payMethodID = 1;
            }else if([payModel.payWay containsString:@"支付宝"]){
                payMethodID = 2;
            }
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
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [UIView new];
    headerView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
    headerView.backgroundColor = SEPARATECOLOR;
    return headerView;
}
#pragma mark - 统一下单接口
- (void)getAppPayOrder{
    [SVProgressHUD show];
    // ip地址
    NSString *ipStr = [Common getIPaddress];
    
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"orderType":self.assessModel.ID,
                                @"payMethodID":[NSString stringWithFormat:@"%ld",(long)payMethodID],
                                @"mobileIP":ipStr,
                                @"payFrom":@"4",
                                @"orderTypeNew":@"3",
                                };
    //  URL_GETAPPPAYORDER
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETAPPPAYORDER tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        DLog(@"");
        if (payMethodID == 1) {
            [self wxpayParamData:(NSString *)dataDict];
        }else if (payMethodID == 2){
            [self alipayParamData:(NSString *)dataDict];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 调用微信支付SDK
- (void)wxpayParamData:(NSString *)dataStr{
    NSDictionary *dataDict = [CommonTools translateJsonStrToDictionary:dataStr];
    
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

#pragma mark - 调用支付宝支付SDK
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
            if (payMethodID == 2) {
                [self alipaySuccess];
            }else if (payMethodID == 1){
                [self wxpaySuccess];
            }
        }else{
            if (payMethodID == 2) {
                [self alipayFailed];
            }else if (payMethodID == 1){
                [self wxpayFailed];
            }
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        
    }];
}

#pragma mark - 支付宝支付通知

- (void)alipayFailed{
    
    self.sendbackAssessType(NO, self.assessModel);
    [self.navigationController popViewControllerAnimated:NO];
}
- (void)alipaySuccess{
    
    self.sendbackAssessType(YES, self.assessModel);
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 微信支付通知

- (void)wxpayFailed{
    
    self.sendbackAssessType(NO, self.assessModel);
    [self.navigationController popViewControllerAnimated:NO];
}

- (void)wxpaySuccess{
    
    self.sendbackAssessType(YES, self.assessModel);
    [self.navigationController popViewControllerAnimated:NO];
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
@end
