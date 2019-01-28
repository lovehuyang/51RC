//
//  ShieldSetViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//  屏蔽设置页面

#import "ShieldSetViewController.h"
#import "ShieldSetEmptyDataView.h"
#import "NSString+RCString.h"
#import "TagView.h"
#import "AddShieldBtn.h"
#import "InputAlertView.h"
#import "AlertView.h"

@interface ShieldSetViewController ()<TagViewDelegate>
@property (nonatomic , strong) TagView * tagView;
@property (nonatomic , strong) ShieldSetEmptyDataView *emptyDataView;
@property (nonatomic , strong) UILabel *tipLab;
@property (nonatomic , strong) AddShieldBtn *btn;
@end

@implementation ShieldSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"屏蔽设置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[BarButtonItem alloc]initWithTitle:@"+添加关键词" style:UIBarButtonItemStylePlain target:self action:@selector(addKeyWords)];
    //
    [self setupEmptyDataUI];
    [self.view addSubview:self.tipLab];
    [self createTagView];
    
    AddShieldBtn *btn = [AddShieldBtn new];
    [self.view addSubview:btn];
    btn.hidden = YES;
    btn.sd_layout
    .leftSpaceToView(self.view, 20)
    .rightSpaceToView(self.view, 20)
    .heightIs(35)
    .bottomSpaceToView(self.view, 20);
    [btn addTarget:self action:@selector(addKeyWords) forControlEvents:UIControlEventTouchUpInside];
    self.btn = btn;
    [self getData];
}

#pragma mark - 懒加载
-(void )createTagView{
    self.tagView = [[TagView alloc]initWithFrame:CGRectMake(0, HEIGHT_STATUS_NAV + 30, SCREEN_WIDTH, 0)];
    self.tagView.hidden = YES;
    self.tagView.delegate = self;
    [self.view addSubview:self.tagView];
}
- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab = [UILabel new];
        _tipLab.frame = CGRectMake(0, HEIGHT_STATUS_NAV, SCREEN_WIDTH, 30);
        _tipLab.text = @"    包含以下关键词的企业不能主动查看您的简历";
        _tipLab.font = DEFAULTFONT;
        _tipLab.textColor = TEXTGRAYCOLOR;
        _tipLab.hidden = YES;
    }
    return _tipLab;
}
#pragma mark - TagViewDelegate
- (void)tagViewClick:(NSString *)title{

    AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak __typeof(alertView)WeakAlertView = alertView;
    [WeakAlertView initWithTitle:@"提示" content:@"确定要删除此关键词么？" btnTitleArr:@[@"取消",@"确定"] canDismiss:YES];
    WeakAlertView.clickButtonBlock = ^(UIButton *button) {
        if (button.tag == 101) {
            [self deletePaMainByHideConditions:title];
        }
    };
    [WeakAlertView show];
}

#pragma mark - 数据为空的UI
- (void)setupEmptyDataUI{
    ShieldSetEmptyDataView *emptyDataView = [ShieldSetEmptyDataView new];
    [self.view addSubview:emptyDataView];
    emptyDataView.sd_layout
    .leftSpaceToView(self.view, 0)
    .topSpaceToView(self.view, HEIGHT_STATUS_NAV)
    .rightSpaceToView(self.view, 0)
    .bottomSpaceToView(self.view, 0);
    self.emptyDataView = emptyDataView;
    self.emptyDataView.hidden = YES;
    __weak typeof(self)weakSelf = self;
    self.emptyDataView.addEvent = ^{
        [weakSelf addKeyWords];
    };
}

#pragma mark - 获取
- (void)getData{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{
                                @"pamainID":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"]
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_HIDENCONDITIONS tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        [SVProgressHUD dismiss];
        NSString *resultStr = (NSString *)dataDict;
        NSArray *dataArr = [NSString getHideConditions:resultStr];
        if (dataArr.count > 0) {
            [self.tagView removeFromSuperview];
            [self createTagView];
            self.emptyDataView.hidden = YES;
            self.tagView.hidden = NO;
            self.tipLab.hidden = NO;
            self.btn.hidden = NO;
            self.tagView.arr = dataArr;
        }else{
            self.emptyDataView.hidden = NO;
            self.tagView.hidden = YES;
            self.tipLab.hidden = YES;
            self.btn.hidden = YES;
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 新增
- (void)updatePaMainByHideConditions:(NSString *)condition{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{
                                @"pamainID":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"txtKeyWord":condition
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_UPDATEHIDNCONDITION tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        BOOL resulr = [(NSString *)dataDict isEqualToString:@"1"];
        if (resulr) {
            [self getData];
        }else{
            [SVProgressHUD dismiss];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 删除
- (void)deletePaMainByHideConditions:(NSString *)condition{
    [SVProgressHUD show];
    NSDictionary *paramDict = @{
                                @"pamainID":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"txtKeyWord":condition
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_DELETEHIDECONDITIONS tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        BOOL resulr = [(NSString *)dataDict isEqualToString:@"1"];
        if (resulr) {
            [self getData];
        }else{
            [SVProgressHUD dismiss];
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

- (void)addKeyWords{
    InputAlertView *inputView = [[InputAlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak __typeof(inputView)WeakInputView = inputView;
    [WeakInputView initWithTitle:@"屏蔽设置" content:@"输入您要屏蔽的关键词" btnTitleArr:@[@"取消",@"确定"] canDismiss:NO];
    WeakInputView.clickButtonBlock = ^(UIButton *button, NSString *inputText) {
        // 确定
        if (button.tag == 101) {
            [self updatePaMainByHideConditions:inputText];
        }
    };
    [WeakInputView show:self.view];
}

@end
