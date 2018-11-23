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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self getData];
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvList" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
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
        if (arrayCv.count == 0) {
            UIView *viewNoData = [[UIView alloc] init];
            [viewNoData setBackgroundColor:[UIColor whiteColor]];
            [viewNoData setTag:NODATAVIEWTAG];
            [self.view addSubview:viewNoData];
            
            WKLabel *lbNoData = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, 0, SCREEN_WIDTH, 20) content:@"不要质疑此刻的付出\n创建一份代表自己能力的简历\n让HR知道你多牛" size:BIGGERFONTSIZE color:TEXTGRAYCOLOR spacing:7];
            [lbNoData setTextAlignment:NSTextAlignmentCenter];
            [lbNoData setCenter:CGPointMake(SCREEN_WIDTH / 2, lbNoData.center.y)];
            [viewNoData addSubview:lbNoData];
            
            UIImageView *imgNoData = [[UIImageView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbNoData) + 20, SCREEN_WIDTH * 0.7, SCREEN_WIDTH * 0.7 * 0.44)];
            [imgNoData setCenter:CGPointMake(SCREEN_WIDTH / 2, imgNoData.center.y)];
            [imgNoData setImage:[UIImage imageNamed:@"img_frog.png"]];
            [imgNoData setContentMode:UIViewContentModeScaleAspectFit];
            [viewNoData addSubview:imgNoData];
            
            WKButton *btnAdd = [[WKButton alloc] initWithFrame:CGRectMake(15, VIEW_BY(imgNoData) + 20, SCREEN_WIDTH - 30, 40)];
            [btnAdd setTitle:@"创建简历，证明自己" forState:UIControlStateNormal];
            [btnAdd addTarget:self action:@selector(create) forControlEvents:UIControlEventTouchUpInside];
            [viewNoData addSubview:btnAdd];
            
            [viewNoData setFrame:CGRectMake(0, (SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT - VIEW_BY(btnAdd)) / 2, SCREEN_WIDTH, VIEW_BY(btnAdd))];
        }
        else if (arrayCv.count == 1) {
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

- (void)create {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"CreateResume" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 屏蔽设置
- (void)shieldSet{
    ShieldSetViewController *svc = [ShieldSetViewController new];
    [self.navigationController pushViewController:svc animated:YES];
}
- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"屏蔽设置" style:UIBarButtonItemStylePlain target:self action:@selector(shieldSet)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:NOTIFICATION_GETCVLIST object:nil];
}
@end
