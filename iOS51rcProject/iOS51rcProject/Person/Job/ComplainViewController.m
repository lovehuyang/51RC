//
//  ComplainViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  投诉页面

#import "ComplainViewController.h"
#import "ComplainView.h"
#import "NetWebServiceRequest.h"
#import "Common.h"
#import "UserInfo.h"

const NSInteger tag1 = 1;// 下载个人信息
const NSInteger tag2 = 2;// 提交投诉信息

@interface ComplainViewController ()<NetWebServiceRequestDelegate>
@property (nonatomic , strong)ComplainView *contactView;
@property (nonatomic , strong)ComplainView *phoneView;
@property (nonatomic , strong)ComplainView *emailView;
@property (nonatomic , strong)ComplainView *reasonView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic , strong)UserInfo *userInfo;// 用户信息的数据模型
@end

@implementation ComplainViewController

- (instancetype)init{
    if (self = [super init]) {
        self.title = @"投诉";
        self.view.backgroundColor = UIColorWithRGBA(215, 215, 215, 1);
    }
    return  self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self getData];
    UIButton *submitBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    submitBtn.frame = CGRectMake(0, 0, 44, 44);
    [submitBtn setTitle:@"提交" forState:UIControlStateNormal];
    submitBtn.titleLabel.font = BIGGERFONT;
    [submitBtn addTarget:self action:@selector(submitClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:submitBtn];
    self.navigationItem.rightBarButtonItem = rightItem;
}

- (void)setupSubViews{
    // 联系人
    ComplainView *contactView = [[ComplainView alloc]initWithFrame:CGRectMake(15,  HEIGHT_STATUS_NAV + 20, SCREEN_WIDTH - 30, 55) title:@"联系人（必填）" content:self.userInfo.Name textViewHeight:40];
    self.contactView = contactView;
    [self.view addSubview:self.contactView];
    
    // 手机号
    ComplainView *phoneView = [[ComplainView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(contactView.frame) + 10, SCREEN_WIDTH - 30, 55) title:@"手机号码（必填）" content:self.userInfo.Mobile textViewHeight:40];
    self.phoneView = phoneView;
    [self.view addSubview:self.phoneView];
    
    // 邮箱
    ComplainView *emailView = [[ComplainView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(phoneView.frame) + 10, SCREEN_WIDTH - 30, 55) title:@"邮箱（必填）" content:self.userInfo.Email textViewHeight:40];
    self.emailView = emailView;
    [self.view addSubview:self.emailView];
    
    // 投诉原因
    ComplainView *reasonView = [[ComplainView alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(emailView.frame) + 10, SCREEN_WIDTH - 30, 100) title:@"投诉原因（必填）" content:@"" textViewHeight:40];
    self.reasonView = reasonView;
    [self.view addSubview:self.reasonView];
}
- (void)getData{
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaMain" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:tag1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - NetWebServiceRequestDelegate
- (void)netRequestFinished:(NetWebServiceRequest *)request finishedInfoToResult:(NSString *)result responseData:(GDataXMLDocument *)requestData{
    if (request.tag == tag1) {
        NSArray *arrayPaMain = [Common getArrayFromXml:requestData tableName:@"Table"];
        if ([arrayPaMain count] == 0) {
            [USER_DEFAULT removeObjectForKey:@"paMainId"];
            [USER_DEFAULT removeObjectForKey:@"paMainCode"];
            return;
        }
        self.userInfo = [UserInfo buideModel:arrayPaMain[0]];
        [self setupSubViews];
    }
}
- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.runningRequest cancel];
}
#pragma mark - 提交事件
- (void)submitClick{
    [self.view endEditing:YES];
    if (!self.contactView.content.length) {
        [RCToast showMessage:@"联系人不能为空！"];
        return;
    }else if (!self.phoneView.content.length){
         [RCToast showMessage:@"手机号码不能为空！"];
        return;
    }else if (self.phoneView.content.length && ![Common checkMobile:self.phoneView.content]){
        [RCToast showMessage:@"手机号格式错误"];
        return;

    }else if (!self.emailView.content.length){
         [RCToast showMessage:@"邮箱不能为空！"];
        return;
    }else if (!self.reasonView.content.length){
         [RCToast showMessage:@"投诉原因不能为空！"];
        return;
    }
    
    NSDictionary *param = @{@"jobId":self.jobId,
                            @"txtComplaintWhy":self.reasonView.content,
                            @"userName":self.contactView.content,
                            @"mobile":self.phoneView.content,
                            @"email":self.emailView.content,
                            @"caMainId":self.caMainId,
                            @"paMainID":PAMAINID,
                            @"code":[USER_DEFAULT objectForKey:@"paMainCode"]
                            };
    [AFNManager requestWithMethod:POST ParamDict:param url:URL_SAVECOMPLAIN tableName:@"SaveComplaintsResponse" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [RCToast showMessage:@"投诉成功！"];
        
        __weak __typeof (self)weakSelf = self;
        dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5/*延迟执行时间*/ * NSEC_PER_SEC));
        
        dispatch_after(delayTime, dispatch_get_main_queue(), ^{
            [weakSelf.navigationController popViewControllerAnimated:YES];
        });
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [RCToast showMessage:msg];
    }];
}


@end
