//
//  TalentsTestNativeViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "TalentsTestNativeViewController.h"
#import "MyOrderViewController.h"
#import "ConfirmAssessOrderController.h"
#import "MyAssessIndexController.h"
#import "OneMinuteCVViewController.h"
#import "AssessIndexWebController.h"
#import "AssessIndexCell.h"
#import "AssessIndexModel.h"
#import "AssessShareView.h"
#import "WXApi.h"
#import <ShareSDK/ShareSDK.h>
#import "AssessPayAlert.h"
#import "AssessPaySuccessAlert.h"
#import "AlertView.h"


@interface TalentsTestNativeViewController ()<UITableViewDelegate , UITableViewDataSource>
@property (nonatomic , strong) UIImageView *headerImgView;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) NSMutableArray *dataArr;
@end

@implementation TalentsTestNativeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"人才测评";
    // Do any additional setup after loading the view.
    [self.view addSubview:self.tableView];
    [SVProgressHUD show];
    [self getAssessIndex];
    
    self.navigationItem.rightBarButtonItem = [[BarButtonItem alloc]initWithTitle:@"我的测评" style:UIBarButtonItemStylePlain target:self action:@selector(myAssessIndex)];
}

- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV) style:UITableViewStylePlain];
        _tableView.tableHeaderView = [self tableviewHeader];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = SEPARATECOLOR;
        _tableView.tableFooterView = [UIView new];
    }
    return _tableView;
}
- (UIImageView *)tableviewHeader{
    UIImageView *headerImgView = [UIImageView new];
    headerImgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH *0.416);
    self.headerImgView = headerImgView;
    return headerImgView;
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
    
    AssessIndexModel *model = [self.dataArr objectAtIndex:indexPath.row];
    AssessIndexCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AssessCell"];
    if (cell == nil) {
        cell = [[AssessIndexCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"AssessCell"];
    }
    cell.model = model;
    cell.assessBlock = ^(AssessIndexModel *model, UIButton *button) {
        if(button.tag == 101){// 邀请朋友
            [self shareToFriends];
        }else{// 我要测评
            
            if ([model.isPay boolValue]) {// 跳转至测评页面
                 [self pushAssessWebViewController:model];
                
            }else if(![model.isCvLevel boolValue]){// 没有完整简历
                
                OneMinuteCVViewController *oneCV = [[OneMinuteCVViewController alloc]init];
                oneCV.pageType = PageType_AssessIndex;
                oneCV.assessModle = model;
                oneCV.returnToAssessViewController = ^(AssessIndexModel *assessIndex) {
                    [self showPayAlert:assessIndex];
                };
                
                [self.navigationController pushViewController:oneCV animated:NO];
            }else if (![model.isPay boolValue]) {// 付费测评
                
                [self showPayAlert:model];
                
            }
        }
    };
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     return [self.tableView cellHeightForIndexPath:indexPath model:self.dataArr[indexPath.row] keyPath:@"model" cellClass:[AssessIndexCell class] contentViewWidth:SCREEN_WIDTH];
}

#pragma mark - 弹出缴费弹框
- (void)showPayAlert:(AssessIndexModel *)model{
    AssessPayAlert *alert = [AssessPayAlert new];
    alert.content = [NSString stringWithFormat:@"该测评为付费测评，价格为￥%@元。",model.Price];
    alert.title = @"我要测评";
    alert.btnStr = @"付费";
    alert.clickAssessPayBlock = ^{
        ConfirmAssessOrderController *cvc = [[ConfirmAssessOrderController alloc]init];
        cvc.assessModel = model;
        
        cvc.sendbackAssessType = ^(BOOL paySuccess, AssessIndexModel *assessModel) {
            
            if (paySuccess) {
                [self paySuccess:assessModel];
            }else{
                [self payFaild:assessModel];
            }
        };
        [self.navigationController pushViewController:cvc animated:YES];
    };
    [alert show];
}

#pragma mark - 支付成功 // 测评类型
- (void)paySuccess:(AssessIndexModel *)paySuccessModel{
    
    AssessPaySuccessAlert *successAlert = [AssessPaySuccessAlert new];
    successAlert.clickBlock = ^(NSString *event) {
        NSLog(@"%@",event);
        if([event containsString:@"订单"]){
            MyOrderViewController *mvc = [[MyOrderViewController alloc]init];
            [self.navigationController pushViewController:mvc animated:YES];
        }else{
            [self pushAssessWebViewController:paySuccessModel];
        }
    };
    [successAlert show];
}

- (void)pushAssessWebViewController:(AssessIndexModel *)paySuccessModel{
    NSString *urlStr = nil;
    if([paySuccessModel.isComplete boolValue]){// 有未完成的测评,继续上次测评
        urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/test?AssessTypeID=%@&PaMainID=%@&Code=%@",[USER_DEFAULT valueForKey:@"subsite"],paySuccessModel.ID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
    }else{
        urlStr= [NSString stringWithFormat:@"http://%@/personal/assess/NoticeBegin?AssessTypeID=%@&PaMainID=%@&Code=%@",[USER_DEFAULT valueForKey:@"subsite"],paySuccessModel.ID,PAMAINID,[USER_DEFAULT valueForKey:@"paMainCode"]];
    }
    
    AssessIndexWebController *avc = [AssessIndexWebController new];
    avc.urlString = urlStr;
    [self.navigationController pushViewController:avc animated:YES];
}

#pragma mark - 支付失败
- (void)payFaild:(AssessIndexModel *)payFaieldModel{
    
    AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak __typeof(alertView)WeakAlertView = alertView;
    [WeakAlertView initWithTitle:@"提示" content:@"尚未支付成功，请重新支付" btnTitleArr:@[@"暂不支付",@"重新支付"] canDismiss:NO];
    WeakAlertView.clickButtonBlock = ^(UIButton *button) {
        if (button.tag == 101) {// 支付
           
            ConfirmAssessOrderController *cvc = [[ConfirmAssessOrderController alloc]init];
            cvc.assessModel = payFaieldModel;
            
            cvc.sendbackAssessType = ^(BOOL paySuccess, AssessIndexModel *assessModel) {
                
                if (paySuccess) {
                    [self paySuccess:assessModel];
                }else{
                    [self payFaild:assessModel];
                }
            };
            [self.navigationController pushViewController:cvc animated:YES];
        }
    };
    
    [WeakAlertView show];
}


#pragma mark - 分享
- (void)shareToFriends{
    AssessShareView *shareView = [AssessShareView new];
    shareView.shareBlock = ^(UIButton *button) {
      
        SSDKPlatformType platformType;// 分享的平台
        
        if (button.tag == 100) {
            platformType = SSDKPlatformSubTypeWechatSession;
        }else if (button.tag == 101){
            platformType = SSDKPlatformSubTypeWechatTimeline;

        }else {
            platformType = SSDKPlatformSubTypeWechatFav;
        }
        
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params SSDKSetupShareParamsByText:@"人才测评让你更懂自己-齐鲁人才网" images:[UIImage imageNamed:@"320logo.png"] url:[NSURL URLWithString:@"http://m.qlrc.com/personal/assess/AssessType"] title:@"齐鲁人才网" type:SSDKContentTypeAuto];
        
        [ShareSDK share:platformType parameters:params onStateChanged:^(SSDKResponseState state, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error) {
            
            switch (state) {
                    
                case SSDKResponseStateSuccess:
                    //成功
                    [RCToast showMessage:@"分享成功"];
                    break;
                case SSDKResponseStateFail:{
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
}

#pragma mark - 人才测评套餐
- (void)getAssessIndex{
    NSDictionary *paramDict = @{
                                @"paMainId":PAMAINID,
                                @"code":[USER_DEFAULT valueForKey:@"paMainCode"]
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETASSESSINDEX tableName:@"ds" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [self.dataArr removeAllObjects];
        [SVProgressHUD dismiss];
        if (requestData) {
            for (NSDictionary *dict in requestData) {
                AssessIndexModel *model = [AssessIndexModel buildModelWithDic:dict];
                [self.dataArr addObject:model];
            }
            AssessIndexModel *model = [self.dataArr firstObject];
            [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:model.indexImageUrl]];
            [self.headerImgView sd_setImageWithURL:[NSURL URLWithString:model.indexImageUrl] placeholderImage:[UIImage imageNamed:@"bg_talent_top_Placehoder"]];
        }
        
        [self.tableView reloadData];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self getAssessIndex];
}

#pragma mark - 我的测评
- (void)myAssessIndex{
    MyAssessIndexController *mvc = [MyAssessIndexController new];
    [self.navigationController pushViewController:mvc animated:YES];
}
@end
