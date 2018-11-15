//
//  ShieldSetViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//  屏蔽设置页面

#import "ShieldSetViewController.h"
#import "BarButtonItem.h"
#import "ShieldSetEmptyDataView.h"
#import "NSString+RCString.h"
#import "TagView.h"
#import "AddShieldBtn.h"


@interface ShieldSetViewController ()
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
    [self.view addSubview:self.tagView];
    self.tagView.handleSelectTag = ^(NSString *keyWord) {
        DLog(@"%@",keyWord);
    };
    
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
-(TagView *)tagView{
    if (!_tagView) {
        _tagView = [[TagView alloc]initWithFrame:CGRectMake(0, HEIGHT_STATUS_NAV + 30, SCREEN_WIDTH, 0)];
        _tagView.hidden = YES;
    }
    return _tagView;
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

#pragma mark - 获取屏蔽关键词
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
        if (resultStr.length > 0) {
            self.emptyDataView.hidden = YES;
            self.tagView.hidden = NO;
            self.tipLab.hidden = NO;
            self.btn.hidden = NO;
            NSArray *dataArr = [NSString getHideConditions:resultStr];
            self.tagView.arr = dataArr;
            DLog(@"");
        }else{
            self.emptyDataView.hidden = NO;
            self.tagView.hidden = YES;
            self.tipLab.hidden = YES;
            self.btn.hidden = YES;
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}
- (void)addKeyWords{
    
}

@end
