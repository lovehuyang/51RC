//
//  CvInfoViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/3.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  简历页面

#import "CvInfoViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "SCNavTabBarController.h"
#import "CvInfoChildViewController.h"
#import "WKLabel.h"
#import "WKLoginView.h"
#import "WKButton.h"
#import "ShieldSetViewController.h"
#import "CVListModel.h"
#import "OneMinuteViewController.h"
#import "WKNavigationController.h"
#import "OneMinuteCVViewController.h"


@interface CvInfoViewController ()<NetWebServiceRequestDelegate, CvInfoChildDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) WKLoginView *loginView;
@end

@implementation CvInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"简历";
    [self getData];
    [self configChildControllers];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getData) name:NOTIFICATION_GETCVLIST object:nil];
}
- (void)setupAddCVBtn{
    UIButton *addCvBtn = [UIButton new];
    [self.view addSubview:addCvBtn];
    addCvBtn.sd_layout
    .rightSpaceToView(self.view, 20)
    .bottomSpaceToView(self.view, 50)
    .widthIs(50)
    .heightEqualToWidth();
    [addCvBtn setImage:[UIImage imageNamed:@"addCV"] forState:UIControlStateNormal];
    [addCvBtn addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
    [self.view bringSubviewToFront:addCvBtn];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    if (!PERSONLOGIN) {
        if (self.loginView == nil) {
            self.loginView = [[WKLoginView alloc] initLoginView:self];
        }
        [self.view addSubview:self.loginView];
        self.edgesForExtendedLayout = UIRectEdgeTop;
        return;
    }
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.loginView removeFromSuperview];
    for (UIView *view in self.view.subviews) {
        if (view.tag != LOADINGTAG) {
            [view removeFromSuperview];
        }
    }
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvList" Params:paramDict viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)cvInfoReload {
    [self getData];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
        
        if(arrayCv.count == 0){// 一分钟填写简历
            [self createOneMinuteController:@"0"];
            return;
            
        }else{
            BOOL isValid = NO;
            for (NSDictionary *dict in arrayCv) {
                BOOL validBool = [dict[@"Valid"] boolValue];
                isValid = isValid || validBool;
            }
            if (!isValid) {
                //一分钟填写简历
                NSDictionary *dict = [arrayCv firstObject];
                [self createOneMinuteController:dict[@"ID"]];
                return;
            }
        }
    
        self.navigationItem.title = @"简历";
        [self setupBarItem];
        if (arrayCv.count == 1) {
            NSDictionary *data = [arrayCv objectAtIndex:0];
            CvInfoChildViewController *childCtrl = [[CvInfoChildViewController alloc] init];
            [childCtrl setDelegate:self];
            childCtrl.cvMainId = [data objectForKey:@"ID"];
            childCtrl.onlyOne = YES;
            [childCtrl.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_H(childCtrl.view))];
            [self addChildViewController:childCtrl];
            [self.view addSubview:childCtrl.view];
        }
        else {
            NSMutableArray *arrayCtrl = [[NSMutableArray alloc] init];
            for (NSDictionary *data in arrayCv) {
                CvInfoChildViewController *childCtrl = [[CvInfoChildViewController alloc] init];
                [childCtrl setDelegate:self];
                childCtrl.cvMainId = [data objectForKey:@"ID"];
                childCtrl.title = [data objectForKey:@"Name"];
                [arrayCtrl addObject:childCtrl];
            }
            SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
            navTabCtrl.subViewControllers = arrayCtrl;
            navTabCtrl.scrollEnabled = YES;
            [navTabCtrl addParentController:self];
        }
        if (arrayCv.count < 3) {

            [self setupAddCVBtn];
        }
        else {
            self.navigationItem.rightBarButtonItem = NULL;
        }
    }
    else if (request.tag == 2) {
        [self getData];
    }
}

#pragma mark - 新建简历
- (void)create {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"CreateResume" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 一分钟填写简历
- (void)createOneMinuteController:(NSString *)cvID{
    self.navigationItem.title = @"一分钟填写简历";
    [self.navigationItem setRightBarButtonItem:nil];
    OneMinuteCVViewController *oneMinuteCV = [[OneMinuteCVViewController alloc] init];
    oneMinuteCV.pageType = PageType_CV;
    oneMinuteCV.intCvMainID = cvID;
    [oneMinuteCV.view setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_H(oneMinuteCV.view))];
    [self addChildViewController:oneMinuteCV];
    [self.view addSubview:oneMinuteCV.view];
}

#pragma mark - 屏蔽设置
- (void)shieldSet{
    
//    UIViewController *oneMinuteCV = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"oneMinuteView"];
//    [self.navigationController pushViewController:oneMinuteCV animated:YES];
    
    ShieldSetViewController *svc = [ShieldSetViewController new];
    [self.navigationController pushViewController:svc animated:YES];
}

#pragma mark - 屏蔽设置
- (void)setupBarItem{
    self.navigationItem.rightBarButtonItem = [[BarButtonItem alloc]initWithTitle:@"屏蔽设置" style:UIBarButtonItemStylePlain target:self action:@selector(shieldSet)];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_GETCVLIST object:nil];
}

- (void)configChildControllers {
    NSArray *arr1 = @[@"OneMinuteCVViewController"];
    
    for (NSInteger index = 0; index <arr1.count; index ++) {
        
        Class VcClass = NSClassFromString(arr1[index]);
        
        UIViewController *viewController = [[VcClass alloc]init];
        
        [self addChildViewController:viewController];
    }
}

@end
