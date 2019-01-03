//
//  SetCvTopViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//  简历置顶页面

#import "SetCvTopViewController.h"
#import "TopTableFirstCell.h"
#import "TopTableSecondCell.h"
#import "CVTopPackageModel.h"
#import "CVTicketModel.h"
#import "CVTicketCell.h"
#import "ZHAttributeTextView.h"
#import "ProtocolView.h"
#import "AlertView.h"
#import "ShareView.h"
#import <ShareSDK/ShareSDK.h>
#import "RedPacketView.h"
#import "ConfirmOrderController.h"

@interface SetCvTopViewController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) UIImageView *headImgView;//
@property (nonatomic , strong) UIView *footView;//

@property (nonatomic , strong) NSArray *cvTopPackageArr;// 套餐数据源
@property (nonatomic , strong) NSArray *ticketArr;// 代金券的数据源
@end

@implementation SetCvTopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"简历置顶";
    [self getpaOrderResumeTop];
    [self.view addSubview:self.tableView];
}

- (void)getpaOrderResumeTop{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"cvMainId":self.cvMainId
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETPAORDERRESUMETOP tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        NSDictionary *resultDict = [CommonTools translateJsonStrToDictionary:(NSString *)dataDict];
        [SVProgressHUD dismiss];
        // 套餐数据
        NSArray *cvTopPackageArr = resultDict[@"cvTopPackage"];
        NSMutableArray *tempArr1 = [NSMutableArray array];
        for (NSDictionary *dict in cvTopPackageArr) {
            CVTopPackageModel *model = [CVTopPackageModel buildModelWithDic:dict];
            [tempArr1  addObject:model];
        }
        self.cvTopPackageArr = [NSArray arrayWithArray:tempArr1];
        
        // 代金券数据
        NSArray *ticketArr = resultDict[@"discountInfo"];
        NSMutableArray *tempArr2 = [NSMutableArray array];
        for (NSDictionary *dict in ticketArr) {
            CVTicketModel *model = [CVTicketModel buildModelWithDic:dict];
            [tempArr2 addObject:model];
        }
        self.ticketArr = [NSArray arrayWithArray:tempArr2];
        [self.tableView reloadData];

    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}
#pragma mark - 懒加载
- (UITableView *)tableView{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV) style:UITableViewStylePlain];
        _tableView.tableHeaderView = self.headImgView;
        _tableView.tableFooterView = self.footView;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = SEPARATECOLOR;
    }
    return _tableView;
}
-  (UIImageView *)headImgView{
    if (!_headImgView) {
        _headImgView = [[UIImageView alloc]init];
        _headImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*17/55);
        _headImgView.image = [UIImage imageNamed:@"003宣传页面_02_02"];
    }
    return _headImgView;
}

- (UIView *)footView{
    if (!_footView) {
        _footView = [UIView new];
        _footView.frame =CGRectMake(0, 0, SCREEN_WIDTH, VIEW_H(self.headImgView));
        _footView.backgroundColor = SEPARATECOLOR;
        UILabel *tipLab = [UILabel new];
        [_footView addSubview:tipLab];
        tipLab.sd_layout
        .leftSpaceToView(_footView, 15)
        .topSpaceToView(_footView, 10)
        .heightIs(30)
        .widthIs(200);
        [tipLab setSingleLineAutoResizeWithMaxWidth:100];
        tipLab.text = @"温馨提示";
        tipLab.font = DEFAULTFONT;
        
        NSString *tipText = @"1、购买前请认真阅读简历置顶用户协议。\n2、对服务有任何疑问或索要发票等事宜，请于每周一至周日8:30-17:30拨打客服热线:400-625-5151。";
        ZHAttributeTextView *myTextView = [[ZHAttributeTextView alloc]initWithFrame:CGRectMake(15, 30, SCREEN_WIDTH - 20, 80)];
        [_footView addSubview:myTextView];
        myTextView.numClickEvent = 2;                        // 有几个点击事件(只能设为1个或2个)
        myTextView.oneClickLeftBeginNum = 10;                 // 第一个点击的起始坐标数字是几
        myTextView.oneTitleLength = 8;                      // 第一个点击的文本长度是几
        myTextView.twoClickLeftBeginNum = 64;                // 第二个点击的起始坐标数字是几
        myTextView.twoTitleLength = 12;                      // 第二个点击的文本长度是几
        myTextView.fontSize = DEFAULTFONTSIZE;                            // 可点击的字体大小
        myTextView.titleTapColor = [UIColor blueColor];    // 可点击富文本字体颜色
        // 设置了上面后要在最后设置内容
        myTextView.content = tipText;
        myTextView.eventblock = ^(NSAttributedString *contentStr) {
            NSLog(@"点击了富文本--%@", contentStr.string);
            if([contentStr.string isEqualToString:@"简历置顶用户协议"]){
                ProtocolView *view = [ProtocolView new];
                [view show];
            }else{
                
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
                [self.view addSubview:webView];
                NSURL *url = [NSURL URLWithString:@"tel://400-625-5151"];
                [webView loadRequest:[NSURLRequest requestWithURL:url]];
            }
        };
    
    }
    return _footView;
}
#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section == 2) {// 代金券
        return self.ticketArr.count;
    }
    return 1;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (self.ticketArr.count > 0) {
        return 3;
    }else{
        return 2;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }else if (section == 1){
        return 10;
    }else if (section == 2){
        return 35;
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    view.backgroundColor = SEPARATECOLOR;
    if (section == 2) {
        view.backgroundColor = [UIColor whiteColor];
        UILabel *sectionLab = [[UILabel alloc]init];
        [view addSubview:sectionLab];
        sectionLab.sd_layout
        .leftSpaceToView(view, 10)
        .autoHeightRatio(0)
        .centerYEqualToView(view);
        sectionLab.text = @"代金券";
        sectionLab.font = DEFAULTFONT;
        [sectionLab setSingleLineAutoResizeWithMaxWidth:100];
        UILabel *subLab = [UILabel new];
        [view addSubview:subLab];
        subLab.sd_layout
        .leftSpaceToView(sectionLab, 5)
        .rightSpaceToView(view, 0)
        .bottomEqualToView(sectionLab)
        .autoHeightRatio(0);
        subLab.text = @"成功领取后，付款可直接抵扣现金哦~";
        subLab.font = SMALLERFONT;
        subLab.textColor = TEXTGRAYCOLOR;
        
    }

    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return [self.tableView cellHeightForIndexPath:indexPath model:@"/置顶介绍/" keyPath:@"titleStr" cellClass:[TopTableFirstCell class] contentViewWidth:SCREEN_WIDTH];
    }else if (indexPath.section == 1){
        return [self.tableView cellHeightForIndexPath:indexPath model:self.cvTopPackageArr keyPath:@"dataArr" cellClass:[TopTableSecondCell class] contentViewWidth:SCREEN_WIDTH];
    }
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section == 0) {
        TopTableFirstCell *cell = [[TopTableFirstCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.titleStr = @"/置顶介绍/";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }else if (indexPath.section == 1){
        TopTableSecondCell *cell = [[TopTableSecondCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.dataArr = self.cvTopPackageArr;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        __weak typeof(self)weakself = self;
        cell.buyPackageBlock = ^(CVTopPackageModel *model) {
            NSLog(@"购买的套餐：%@",model.orderName);
            ConfirmOrderController *cvc = [ConfirmOrderController new];
            cvc.model = model;
            
            [weakself.navigationController pushViewController:cvc animated:YES];
            
        };
        return cell;
    }else if (indexPath.section == 2){
        CVTicketCell *cell = [[CVTicketCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        CVTicketModel *model = self.ticketArr[indexPath.row];
        cell.model = model;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        __weak typeof(self)weakself = self;
        cell.getTicketBlock = ^(CVTicketModel *model) {
            ShareView *shareView = [ShareView new];
            shareView.shareBlock = ^{
                
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params SSDKSetupShareParamsByText:@"test" images:[UIImage imageNamed:@"320logo.png"] url:[NSURL URLWithString:@"http://m.qlrc.com/personal/js/joblist"] title:@"亲，用过齐鲁人才网站找工作么?新增一大波招聘信息等你来" type:SSDKContentTypeAuto];
                
                [ShareSDK share:SSDKPlatformSubTypeWechatTimeline parameters:params onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
                    
                    switch (state) {
                            
                        case SSDKResponseStateSuccess:
                            //成功
                            [weakself savepaOrderDiscount:model.discountType];
                            break;
                        case SSDKResponseStateFail:
                        {
                            NSLog(@"--%@",error.description);
                            [RCToast showMessage:error.description];
                            //失败
                            break;
                        }
                        case SSDKResponseStateCancel:
                            //取消
                            [RCToast showMessage:@"取消分享了"];
                            break;
                            
                        default:
                            break;
                    }
                }];
                
            };
            [shareView show];
        };
        return cell;
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cell.textLabel.text = @"haha";
    return cell;
}

#pragma mark - 获取代金券金额
- (void)savepaOrderDiscount:(NSString *)discountType{
    NSDictionary *paramDict = @{@"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"discountType":discountType
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_SAVAPAORDERDISCOUNT tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [self getpaOrderResumeTop];
        RedPacketView *redPacketView = [RedPacketView new];
        redPacketView.money =(NSString *)dataDict;
        [redPacketView show];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}
@end
