//
//  CpViewViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CpViewViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "SCNavTabBarController.h"
#import "CpViewChildViewController.h"
#import "WKLabel.h"

@interface CpViewViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@end

@implementation CpViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvList" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
    if (arrayCv.count == 0) {
        UIView *viewNoData = [[UIView alloc] initWithFrame:self.view.frame];
        [viewNoData setBackgroundColor:[UIColor whiteColor]];
        [viewNoData setTag:NODATAVIEWTAG];
        [self.view addSubview:viewNoData];
        
        UIImageView *imgNoData = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 150) / 2, 150, 150, 150 * 0.86)];
        [imgNoData setImage:[UIImage imageNamed:@"img_nodata.png"]];
        [imgNoData setContentMode:UIViewContentModeScaleAspectFit];
        [viewNoData addSubview:imgNoData];
        
        WKLabel *lbNoData = [[WKLabel alloc] initWithFixedSpacing:CGRectMake((SCREEN_WIDTH - 200) / 2, VIEW_BY(imgNoData) + 20, 200, 20) content:@"呀！啥都没有\n快去创建简历吧~" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:7];
        [lbNoData setTextAlignment:NSTextAlignmentCenter];
        [lbNoData setCenter:CGPointMake(SCREEN_WIDTH / 2, lbNoData.center.y)];
        [viewNoData addSubview:lbNoData];
    }
    else if (arrayCv.count == 1) {
        NSDictionary *data = [arrayCv objectAtIndex:0];
        CpViewChildViewController *childCtrl = [[CpViewChildViewController alloc] init];
        childCtrl.cvMainId = [data objectForKey:@"ID"];
        childCtrl.onlyOne = YES;
        [childCtrl.view setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, VIEW_H(childCtrl.view))];
        [self addChildViewController:childCtrl];
        [self.view addSubview:childCtrl.view];
    }
    else {
        NSMutableArray *arrayCtrl = [[NSMutableArray alloc] init];
        for (NSDictionary *data in arrayCv) {
            CpViewChildViewController *childCtrl = [[CpViewChildViewController alloc] init];
            childCtrl.cvMainId = [data objectForKey:@"ID"];
            childCtrl.title = [data objectForKey:@"Name"];
            [arrayCtrl addObject:childCtrl];
        }
        SCNavTabBarController *navTabCtrl = [[SCNavTabBarController alloc] init];
        navTabCtrl.subViewControllers = arrayCtrl;
        navTabCtrl.scrollEnabled = YES;
        [navTabCtrl addParentController:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
