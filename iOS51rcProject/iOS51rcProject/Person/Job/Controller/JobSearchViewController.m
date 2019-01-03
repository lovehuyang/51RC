//
//  JobSearchViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/29.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  职位页面

#import "JobSearchViewController.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "Common.h"
#import "CommonMacro.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "WKLabel.h"
#import "UIImageView+WebCache.h"
#import "WKFilterView.h"
#import "WKPopView.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "KeywordViewController.h"
#import "NearSearchViewController.h"
#import "UIView+Toast.h"
#import "NSString+RCString.h"
#import "RecommendJobView.h"
#import "InsertJobApplyModel.h"
#import "AdAlert.h"
#import "PJobListModel.h"
#import "PJobListCell.h"

@interface JobSearchViewController ()<BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, NetWebServiceRequestDelegate, UITableViewDelegate, UITableViewDataSource, WKFilterViewDelegate, UIScrollViewDelegate, UITextFieldDelegate, KeyWordViewDelegate, WKPopViewDelegate>

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) WKFilterView *viewPopFilter;
@property (nonatomic, strong) WKFilterView *viewPopFilterOther;
@property (nonatomic, strong) UITextField *txtKeyword;
@property (nonatomic, strong) UIView *viewFilter;
@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) NSMutableArray *arrData;// 职位列表数据源
@property (nonatomic, strong) NSMutableArray *arrJobType;
@property (nonatomic, strong) NSMutableArray *arrJobPlace;
@property (nonatomic, strong) NSMutableArray *arrJobTypeSelect;
@property (nonatomic, strong) NSMutableArray *arrJobPlaceSelect;
@property (nonatomic, strong) NSDictionary *dataPic;
@property (nonatomic, strong) NSString *keyword;
@property (nonatomic, strong) NSString *provinceId;
@property (nonatomic, strong) NSString *province;
@property (nonatomic, strong) NSArray *provinceArr;// 存放所有省份

@property (nonatomic, strong) NSMutableArray *insertJobApplyDataArr;// 推荐职位的数据源
@property (nonatomic, copy) NSString *cvMainID;// 推荐职位申请的简历id
@property (nonatomic, copy) NSString *subsiteID;
@property (nonatomic , strong) RecommendJobView *recommendView;// 推荐职位的弹出
@property NSInteger page;
@property int lastPosition;
@end

@implementation JobSearchViewController

- (NSMutableArray *)insertJobApplyDataArr{
    if (!_insertJobApplyDataArr) {
        _insertJobApplyDataArr = [NSMutableArray array];
    }
    return _insertJobApplyDataArr;
}
- (NSMutableArray *)arrData{
    if (!_arrData) {
        _arrData = [[NSMutableArray alloc]init];
    }
    return _arrData;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 获取省信息
    self.provinceArr = [Common getProvince];
    
    self.txtKeyword = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 150, 30)];
    [self.txtKeyword setDelegate:self];
    [self.txtKeyword setBackgroundColor:[UIColor whiteColor]];
    [self.txtKeyword setPlaceholder:@"请填写关键词"];
    [self.txtKeyword setFont:DEFAULTFONT];
    [self.txtKeyword.layer setCornerRadius:15];
    
    UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 15)];
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 15, 15)];
    [imgSearch setImage:[UIImage imageNamed:@"job_search.png"]];
    [imgSearch setContentMode:UIViewContentModeScaleAspectFit];
    [viewLeft addSubview:imgSearch];
    
    [self.txtKeyword setLeftViewMode:UITextFieldViewModeAlways];
    [self.txtKeyword setLeftView:viewLeft];
    self.navigationItem.titleView = self.txtKeyword;
    
    UIButton *btnNearby = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, VIEW_H(self.txtKeyword))];
    [btnNearby setTitle:@"附近" forState:UIControlStateNormal];
    [btnNearby setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnNearby.titleLabel setFont:DEFAULTFONT];
    [btnNearby setImage:[UIImage imageNamed:@"job_map.png"] forState:UIControlStateNormal];
    [btnNearby.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnNearby setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [btnNearby setImageEdgeInsets:UIEdgeInsetsMake(7, 2, 7, 0)];
    [btnNearby addTarget:self action:@selector(nearClick) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnNearby];
    
    self.viewFilter = [[UIView alloc] initWithFrame:CGRectMake(0, HEIGHT_STATUS_NAV, SCREEN_WIDTH, 44)];
    [self.viewFilter setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.viewFilter];
    
    float heightForFilterButton = SCREEN_WIDTH / 4;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btnFilter = [[UIButton alloc] initWithFrame:CGRectMake(i * heightForFilterButton, 0, heightForFilterButton, VIEW_H(self.viewFilter))];
        [btnFilter setTag:(i + 1)];
        NSString *filterTitle = @"";
        if (i == 0) {
            filterTitle = [USER_DEFAULT valueForKey:@"province"];
        }
        else if (i == 1) {
            filterTitle = @"职位类别";
        }
        else if (i == 2) {
            filterTitle = @"月薪范围";
        }
        else if (i == 3) {
            filterTitle = @"更多";
        }
        [btnFilter setTitle:filterTitle forState:UIControlStateNormal];
        [btnFilter setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnFilter.titleLabel setFont:DEFAULTFONT];
        [btnFilter.titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [btnFilter setImage:[UIImage imageNamed:@"img_arrowdown.png"] forState:UIControlStateNormal];
        [btnFilter.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self resizeFilterButton:btnFilter];
        [btnFilter addTarget:self action:@selector(filterClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewFilter addSubview:btnFilter];
        
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_H(btnFilter) - 3, VIEW_W(btnFilter) - 20, 2)];
        [viewSeparate setTag:8888];
        [viewSeparate setBackgroundColor:[UIColor clearColor]];
        [btnFilter addSubview:viewSeparate];
        
        if (i < 3) {
            UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(VIEW_W(btnFilter) - 1, 15, 1, VIEW_H(btnFilter) - 30)];
            [viewSeparate setBackgroundColor:SEPARATECOLOR];
            [btnFilter addSubview:viewSeparate];
        }
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewFilter) - 1, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.viewFilter addSubview:viewSeparate];
    
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.viewFilter) + HEIGHT_STATUS_NAV, SCREEN_WIDTH, SCREEN_HEIGHT - (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2) - TAB_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n建议您扩大搜索范围~"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    
    // 添加下拉刷新
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page =1;
        [self getData];
    }];
    self.tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    
    // 添加上拉加载更多
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    
    [self.view addSubview:self.tableView];
    
    UIView *viewStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT)];
    [viewStatusBar setBackgroundColor:NAVBARCOLOR];
    [self.view addSubview:viewStatusBar];
    //搜索
    if ([[USER_DEFAULT objectForKey:@"positioned"] isEqualToString:@"0"]) {
        self.searcher = [[BMKGeoCodeSearch alloc] init];
        self.searcher.delegate = self;
        
        self.locService = [[BMKLocationService alloc]init];
        self.locService.delegate = self;
        [self.locService startUserLocationService];
        
        [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    }
    else {
        [self getPic];
        [self defaultSearch];
    }
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(getCvList) name:NOTIFICATION_GETJOBLISTBYSEARCH object:nil];
}

- (void)getPic {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetLauncherPic" Params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"provinceId"], @"regionID", nil] viewController:self];
    [request setTag:3];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)getData {
    [self.dataParam setObject:[NSString stringWithFormat:@"%ld", self.page] forKey:@"pageNumber"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListBySearch" Params:self.dataParam viewController:(self.page == 1 ? self : nil)];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self filterClose];
    self.searcher.delegate = nil;
    self.locService.delegate = nil;
}

- (void)filterClick:(UIButton *)button {
    [self filterClose];
    if (button.tag == WKFilterTypeOther) {
        self.viewPopFilter = nil;
        if (self.viewPopFilterOther == nil) {
            self.viewPopFilterOther = [[WKFilterView alloc] initWithButton:button];
            [self.viewPopFilterOther setDelegate:self];
            [self.viewPopFilterOther setTag:0];
        }
        if (self.viewPopFilterOther.tag == 0) {
            [self.viewPopFilterOther showFilterView:self];
            [self.viewPopFilterOther setTag:1];
        }
        else {
            [self.viewPopFilterOther setTag:0];
            return;
        }
    }
    else {
        [self.viewPopFilterOther setTag:0];
        if (self.viewPopFilter.tag == button.tag) {
            self.viewPopFilter = nil;
            return;
        }
        if (self.arrData.count == 0) {
            if (button.tag == WKFilterTypeRegion && [[self.dataParam objectForKey:@"workPlace"] length] == 2) {
                [self.view.window makeToast:@"现有结果无法再继续筛选"];
                return;
            }
            else if (button.tag == WKFilterTypeJobType && [[self.dataParam objectForKey:@"jobType"] length] == 0) {
                [self.view.window makeToast:@"现有结果无法再继续筛选"];
                return;
            }
        }
        self.viewPopFilter = [[WKFilterView alloc] initWithButton:button];
        [self.viewPopFilter setDelegate:self];
        if (button.tag == WKFilterTypeRegion) {
            self.viewPopFilter.arrayData = self.arrJobPlace;
        }
        else if (button.tag == WKFilterTypeJobType) {
            self.viewPopFilter.arrayData = self.arrJobType;
        }
        else if (button.tag == WKFilterTypeSalary) {
            self.viewPopFilter.arrayData = [NSArray arrayWithObjects:
                    [NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"Description", @"", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@""] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"1K-2K", @"Description", @"2", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"2"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"2K-3K", @"Description", @"4", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"4"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"3K-4K", @"Description", @"6", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"6"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"4K-5K", @"Description", @"8", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"8"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"5K-6K", @"Description", @"9", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"9"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"6K-8K", @"Description", @"10", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"10"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"8K-10K", @"Description", @"11", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"11"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"10K-15K", @"Description", @"12", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"12"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"15K-20K", @"Description", @"13", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"13"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"20K以上", @"Description", @"14", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"14"] ? @"1" : @"0", @"Selected", nil],
                    [NSDictionary dictionaryWithObjectsAndKeys:@"面议", @"Description", @"100", @"TitleID", [[self.dataParam objectForKey:@"salary"] isEqualToString:@"100"] ? @"1" : @"0", @"Selected", nil], nil];
        }
        [self.viewPopFilter showFilterView:self];
    }
    [UIView animateWithDuration:0.5 animations:^{
        [[button viewWithTag:8888] setBackgroundColor:NAVBARCOLOR];
        [button setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }];
}

- (void)filterClose {
    [self.viewPopFilterOther removeFromSuperview];
    [self.viewPopFilter removeFromSuperview];
    for (UIView *view in self.viewFilter.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [UIView animateWithDuration:0.5 animations:^{
                [[button viewWithTag:8888] setBackgroundColor:[UIColor clearColor]];
                [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                button.imageView.transform = CGAffineTransformIdentity;
            }];
        }
    }
}

- (void)resizeFilterButton:(UIButton *)button {
    [button setTitleEdgeInsets:UIEdgeInsetsMake(0, - button.imageView.image.size.width, 0, button.imageView.image.size.width)];
    [button setImageEdgeInsets:UIEdgeInsetsMake(19, button.titleLabel.bounds.size.width, 19, -button.titleLabel.bounds.size.width)];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return [self.tableView cellHeightForIndexPath:indexPath model:self.arrData[indexPath.row] keyPath:@"model" cellClass:[PJobListCell class] contentViewWidth:SCREEN_WIDTH];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PJobListModel *model = [self.arrData objectAtIndex:indexPath.row];
    PJobListCell *cellTest = [[PJobListCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    cellTest.model = model;
    return cellTest;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    PJobListModel *model = [self.arrData objectAtIndex:indexPath.row];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = model.ID;
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    if (self.arrData.count < 30) {
//        return;
//    }
//    int currentPostion = scrollView.contentOffset.y;
//    if (currentPostion - self.lastPosition > 20  && currentPostion > 0) {
//        self.lastPosition = currentPostion;
//        [self.navigationController setNavigationBarHidden:YES animated:YES];
//        [self.tabBarController.tabBar setHidden:YES];
//        [self.viewFilter setHidden:YES];
//        [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT)];
//
//    }
//    else if ((self.lastPosition - currentPostion > 20) && (currentPostion <= scrollView.contentSize.height - scrollView.bounds.size.height - 20)) {
//        self.lastPosition = currentPostion;
//        [self.navigationController setNavigationBarHidden:NO animated:YES];
//        [self.tabBarController.tabBar setHidden:NO];
//        [self.viewFilter setHidden:NO];
//        [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2, SCREEN_WIDTH, SCREEN_HEIGHT - (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2) - TAB_BAR_HEIGHT)];
//    }
}

- (void)didFailToLocateUserWithError:(NSError *)error {
    [self defaultSearch];
    [self.view.window makeToast:@"无法获取到您所在省份，请在“设置”-->“隐私”-->“定位服务”中开启定位权限"];
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    reverseGeoCodeSearchOption.reverseGeoPoint = userLocation.location.coordinate;
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag) {
        [self.locService stopUserLocationService];
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSubSiteByAddress" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:result.address, @"address", nil] viewController:self];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
        
        [USER_DEFAULT setValue:@"1" forKey:@"positioned"];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arraySubsite = [Common getArrayFromXml:requestData tableName:@"Table"];
        if ([arraySubsite count] > 0) {
            NSDictionary *dataSubsite = [arraySubsite objectAtIndex:0];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"ProvinceID"] forKey:@"provinceId"];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"SubSIteCity"] forKey:@"province"];
            [USER_DEFAULT setValue:[[dataSubsite objectForKey:@"SubSiteUrl"] stringByReplacingOccurrencesOfString:@"www." withString:@"m."] forKey:@"subsite"];
            [USER_DEFAULT setValue:[dataSubsite objectForKey:@"SubSiteName"] forKey:@"subsitename"];
        }
        
        [self getPic];
        [self defaultSearch];
    }
    else if (request.tag == 2) {
        [self.tableView.mj_header endRefreshing];// 结束刷新
        [self.tableView.mj_footer endRefreshing];// 结束加载更多
        if (self.page == 1) {
            [self.arrData removeAllObjects];
            [self.tableView setContentOffset:CGPointMake(0, 0)];
        }
        NSArray *dtJobListArr  = [Common getArrayFromXml:requestData tableName:@"dtJobList"];
        for (NSDictionary *dict in dtJobListArr) {
            PJobListModel *model = [PJobListModel buideModel:dict];
            [self.arrData addObject:model];
        }
        [self.tableView reloadData];
        
        if (dtJobListArr > 0) {
            [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:YES];
        }
        else {
            [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
        }
        if (dtJobListArr.count < 30) {
            [self.tableView.mj_footer setHidden:YES];
        }
        else {
            [self.tableView.mj_footer setHidden:NO];
        }
        self.arrJobType = [[Common getArrayFromXml:requestData tableName:@"dtJobType"] mutableCopy];
        self.arrJobPlace = [[Common getArrayFromXml:requestData tableName:@"dtJobRegion"] mutableCopy];
        if (self.arrJobType.count % 2 == 1) {
            [self.arrJobType addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"blank", nil]];
        }
        if (self.arrJobPlace.count % 2 == 1) {
            [self.arrJobPlace addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"blank", nil]];
        }
        if ([[self.dataParam objectForKey:@"workPlace"] length] > 2) {
            [self.arrJobPlace insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"return", nil] atIndex:0];
        }
        if ([[self.dataParam objectForKey:@"jobType"] length] > 0) {
            [self.arrJobType insertObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"return", nil] atIndex:0];
        }
    }
    else if (request.tag == 3) {
        NSArray *arrayPic = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayPic.count > 0) {
            
            self.dataPic = [arrayPic objectAtIndex:0];
            AdAlert *adAlert = [[AdAlert alloc]initWithData:self.dataPic];
            [adAlert show:self];
        }
    }else if (request.tag == 4){
        //PaMain
        NSDictionary *paMainData = [[Common getArrayFromXml:requestData tableName:@"PaMain"] objectAtIndex:0];
        NSDictionary *jobIntentionData = [[Common getArrayFromXml:requestData tableName:@"JobIntention"] objectAtIndex:0];
        NSString *workPlace = jobIntentionData[@"JobPlace"];
        self.subsiteID = [NSString stringWithString:paMainData[@"dcSubSiteID"]];
        NSString *salaryID = jobIntentionData[@"dcSalaryID"];
        NSString *jobTypeID = jobIntentionData[@"JobType"];
        [self getJobSearch:workPlace jobTypeID:jobTypeID salaryID:salaryID];
    }
}

- (void)WKFilterItemClick:(WKFilterType)filterType selectedItem:(NSDictionary *)selectedItem {
    [self filterClose];
    self.viewPopFilter = nil;
    NSString *title = @"";
    NSString *titleId = @"";
    if (filterType == WKFilterTypeRegion) {
        if ([[selectedItem objectForKey:@"return"] isEqualToString:@"1"]) {
            [self.arrJobPlaceSelect removeObjectAtIndex:self.arrJobPlaceSelect.count - 1];
            title = [[self.arrJobPlaceSelect objectAtIndex:self.arrJobPlaceSelect.count - 1] objectForKey:@"value"];
            titleId = [[self.arrJobPlaceSelect objectAtIndex:self.arrJobPlaceSelect.count - 1] objectForKey:@"id"];
        }
        else {
            title = [[selectedItem objectForKey:@"Description"] length] > 0 ? [selectedItem objectForKey:@"Description"] : [selectedItem objectForKey:@"Name"];
            titleId = [[selectedItem objectForKey:@"Description"] length] > 0 ? [selectedItem objectForKey:@"TitleID"] : [NSString stringWithFormat:@"%@##@@%@##@@%@", [self.dataParam valueForKey:@"workPlace"], [selectedItem objectForKey:@"ID"], [selectedItem objectForKey:@"Name"]];
            [self.arrJobPlaceSelect addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"value", titleId, @"id", nil]];
        }
        [self.dataParam setValue:titleId forKey:@"workPlace"];
    }
    else if (filterType == WKFilterTypeJobType) {
        if ([[selectedItem objectForKey:@"return"] isEqualToString:@"1"]) {
            [self.arrJobTypeSelect removeObjectAtIndex:self.arrJobTypeSelect.count - 1];
            if (self.arrJobTypeSelect.count == 0) {
                title = @"职位类别";
                titleId = @"";
            }
            else {
                title = [[self.arrJobTypeSelect objectAtIndex:self.arrJobTypeSelect.count - 1] objectForKey:@"value"];
                titleId = [[self.arrJobTypeSelect objectAtIndex:self.arrJobTypeSelect.count - 1] objectForKey:@"id"];
            }
        }
        else {
            title = [selectedItem objectForKey:@"Description"];
            titleId = [selectedItem objectForKey:@"TitleID"];
            if (self.arrJobTypeSelect == nil) {
                self.arrJobTypeSelect = [[NSMutableArray alloc] init];
            }
            [self.arrJobTypeSelect addObject:[NSDictionary dictionaryWithObjectsAndKeys:title, @"value", titleId, @"id", nil]];
        }
        [self.dataParam setValue:titleId forKey:@"jobType"];
    }
    else if (filterType == WKFilterTypeSalary) {
        title = [selectedItem objectForKey:@"Description"];
        titleId = [selectedItem objectForKey:@"TitleID"];
        if (titleId.length == 0) {
            title = @"月薪范围";
        }
        [self.dataParam setValue:titleId forKey:@"salary"];
    }
    for (UIView *view in self.viewFilter.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag == filterType) {
                [(UIButton *)view setTitle:title forState:UIControlStateNormal];
                [self resizeFilterButton:(UIButton *)view];
                break;
            }
        }
    }
    self.page = 1;
    [self getData];
}

- (void)WKFilterOtherClick:(NSArray *)selectedItems {
    [self filterClose];
    [self.viewPopFilterOther setTag:0];
    [self.dataParam setValue:[selectedItems objectAtIndex:0] forKey:@"isOnline"];
    [self.dataParam setValue:[selectedItems objectAtIndex:1] forKey:@"education"];
    [self.dataParam setValue:[selectedItems objectAtIndex:2] forKey:@"experience"];
    [self.dataParam setValue:[selectedItems objectAtIndex:3] forKey:@"employType"];
    [self.dataParam setValue:[selectedItems objectAtIndex:4] forKey:@"companySize"];
    [self.dataParam setValue:[selectedItems objectAtIndex:5] forKey:@"welfare"];
    self.page = 1;
    [self getData];
}

- (void)WKFilterViewClose {
    [self filterClose];
    self.viewPopFilter = nil;
    [self.viewPopFilterOther setTag:0];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    KeywordViewController *keywordCtrl = [[KeywordViewController alloc] init];
    keywordCtrl.keyWord = self.txtKeyword.text;
    [keywordCtrl setDelegate:self];
    WKNavigationController *keywordNav = [[WKNavigationController alloc] initWithRootViewController:keywordCtrl];
    [self presentViewController:keywordNav animated:NO completion:nil];
    return false;
}

- (void)KeyWordSelect:(NSString *)keyword {
    [self.txtKeyword setText:keyword];
    self.keyword = keyword;
    [self defaultSearch];
}

- (void)defaultSearch {
    if (self.keyword == nil) {
        self.keyword = @"";
    }
    if (self.provinceId == nil) {
        self.provinceId = [USER_DEFAULT objectForKey:@"provinceId"];
        self.province = [USER_DEFAULT objectForKey:@"province"];
    }
    [self genProvince];
    self.arrJobPlaceSelect = [NSMutableArray arrayWithObject:[NSDictionary dictionaryWithObjectsAndKeys:self.province, @"value", self.provinceId, @"id", nil]];
    self.page = 1;
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"jobType", self.provinceId, @"workPlace", @"", @"salary", @"", @"experience", @"", @"education", @"", @"employType", self.keyword, @"keyWord", [NSString stringWithFormat:@"%ld", self.page], @"pageNumber", @"", @"companySize", @"", @"welfare", @"", @"isOnline", self.provinceId, @"subsiteID", nil];
    
    for (UIView *view in self.viewFilter.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            if (view.tag == WKFilterTypeRegion) {
                [(UIButton *)view setTitle:self.province forState:UIControlStateNormal];
                [self resizeFilterButton:(UIButton *)view];
            }
            else if (view.tag == WKFilterTypeJobType) {
                [(UIButton *)view setTitle:@"职位类别" forState:UIControlStateNormal];
                [self resizeFilterButton:(UIButton *)view];
            }
            else if (view.tag == WKFilterTypeSalary) {
                [(UIButton *)view setTitle:@"月薪范围" forState:UIControlStateNormal];
                [self resizeFilterButton:(UIButton *)view];
            }
            else if (view.tag == WKFilterTypeOther) {
                self.viewPopFilterOther = nil;
            }
        }
    }
    [self getData];
}

#pragma mark - 导航栏左侧按钮

- (void)genProvince {
    
    UIButton *btnProvince = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [btnProvince setTitle:self.province forState:UIControlStateNormal];
    [btnProvince setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnProvince.titleLabel setFont:DEFAULTFONT];
    [btnProvince setImage:[UIImage imageNamed:@"img_arrowdownclear.png"] forState:UIControlStateNormal];
    [btnProvince.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnProvince setTitleEdgeInsets:UIEdgeInsetsMake(0, - btnProvince.imageView.image.size.width, 0, btnProvince.imageView.image.size.width)];
    [btnProvince setImageEdgeInsets:UIEdgeInsetsMake(12, btnProvince.titleLabel.bounds.size.width, 12, -btnProvince.titleLabel.bounds.size.width)];
    [btnProvince addTarget:self action:@selector(provinceClick:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnProvince];
}

- (void)nearClick {
    if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        [self.view.window makeToast:@"请在“设置”-->“隐私”-->“定位服务”中开启定位权限"];
        return;
    }
    NearSearchViewController *nearSearchCtrl = [[NearSearchViewController alloc] init];
    [self.navigationController pushViewController:nearSearchCtrl animated:YES];
}

- (void)provinceClick:(UIButton *)button {
    [self.view setTag:1];
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeProvince value:@""];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    NSString *province = [data objectForKey:@"value"];
    province = [province stringByReplacingOccurrencesOfString:@"省" withString:@""];
    province = [province stringByReplacingOccurrencesOfString:@"市" withString:@""];
    self.province = province;
    self.provinceId = [data objectForKey:@"id"];
    [self defaultSearch];
}

#pragma mark - GetJobListBySearch 获取推荐的职位

- (void)getJobSearch:(NSString *)regionID jobTypeID:(NSString *)jobTypeID salaryID:(NSString *)salaryID{
    NSMutableDictionary *paramDict = [NSMutableDictionary dictionary];
    [paramDict setValue:@"1" forKey:@"pageNumber"];
    [paramDict setObject:[NSString juedeString:regionID] forKey:@"workPlace"];
    [paramDict setObject:self.subsiteID forKey:@"subsiteID"];
    [paramDict setObject:[NSString juedeString:jobTypeID] forKey:@"jobType"];
    [paramDict setObject:[NSString juedeString:salaryID] forKey:@"salary"];
    [paramDict setObject:@"" forKey:@"keyWord"];
    [paramDict setObject:@"" forKey:@"companySize"];
    [paramDict setObject:@"" forKey:@"education"];
    [paramDict setObject:@"" forKey:@"employType"];
    [paramDict setObject:@"" forKey:@"experience"];
    [paramDict setObject:@"" forKey:@"isOnline"];
    [paramDict setObject:@"" forKey:@"welfare"];
    

    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"GetJobListBySearch" tableName:@"dtJobList" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [self.insertJobApplyDataArr removeAllObjects];
        if (requestData.count>=4) {
            for(int i =0 ; i< 4;i ++){
                NSDictionary *tempDict = requestData[i];
                InsertJobApplyModel *model = [InsertJobApplyModel buideModel:tempDict];
                model.isSeleted = YES;
                [self.insertJobApplyDataArr addObject:model];
            }
        }else{
            for (NSDictionary *tempDict in requestData) {
                InsertJobApplyModel *model = [InsertJobApplyModel buideModel:tempDict];
                model.isSeleted = YES;
                [self.insertJobApplyDataArr addObject:model];
            }
        }
        
        if(self.insertJobApplyDataArr.count == 0){
            return ;
        }
        RecommendJobView *recommendView = [[RecommendJobView alloc]initWithData:self.insertJobApplyDataArr];
        self.recommendView = recommendView;
        __weak typeof (self)weakself = self;
        self.recommendView.applyFor = ^{
            BOOL haveApply = NO;// 默认没有申请的职位
            for(InsertJobApplyModel *mode in weakself.insertJobApplyDataArr){
                haveApply = haveApply || mode.isSeleted;
            }
            if (haveApply == NO) {
                [RCToast showMessage:@"请至少选择一个职位"];
            }else{
                
                [weakself insertJobApply];
            }
        };
        [self.recommendView show];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
    }];
}

#pragma mark - 获取完整简历
- (void)getCvList{
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil];
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"GetCvList" tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        
        if(requestData.count > 0){// 简历数目大于0
            for (NSDictionary *dict in requestData) {
                // 获取是完整的简历 Valid = 1
                BOOL validBool = [dict[@"Valid"] boolValue];
                if (validBool) {
                    self.cvMainID = [NSString stringWithString:dict[@"ID"]];
                    [self getCvInfo];
                    return ;
                }
            }
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        
    }];
}

#pragma mark - 获取简历详情
- (void)getCvInfo{
    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainID, @"cvMainId", nil];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvInfo" Params:paramDict viewController:self];
    [request setTag:4];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

#pragma mark - InsertJobApply立即申请

- (void)insertJobApply{
    
    [SVProgressHUD show];
    NSArray *tempArr = [NSArray arrayWithArray:self.insertJobApplyDataArr];
    for (InsertJobApplyModel *model in tempArr) {
        if (!model.isSeleted) {
            [self.insertJobApplyDataArr removeObject:model];
        }
    }
    NSString *strJobIDs ;
    for (int i = 0; i < self.insertJobApplyDataArr.count; i ++) {
        InsertJobApplyModel *model = self.insertJobApplyDataArr[i];

        if (i == 0) {
            strJobIDs = model.ID;
        }else{
            strJobIDs = [NSString stringWithFormat:@"%@,%@",strJobIDs,model.ID];
        }
    }
    
    NSDictionary *paramDict = @{@"strCvMainID":self.cvMainID,
                                @"PaMainID":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"],
                                @"strJobIDs":strJobIDs,
                                @"subsiteID":self.subsiteID
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_INSERTJOBAPPLY tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        [self.recommendView dissmiss];
        [RCToast showMessage:@"申请成功！"];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
    }];
}
@end
