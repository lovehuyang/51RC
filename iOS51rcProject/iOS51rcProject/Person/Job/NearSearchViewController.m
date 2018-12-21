//
//  NearSearchViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/8.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "NearSearchViewController.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "Common.h"
#import "CommonMacro.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import "WKLabel.h"
#import "UIImageView+WebCache.h"
#import "WKFilterView.h"
#import "MJRefresh.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "OnlineLab.h"

@interface NearSearchViewController ()<BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKGeneralDelegate, NetWebServiceRequestDelegate, UITableViewDelegate, UITableViewDataSource, WKFilterViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) BMKLocationService *locService;
@property (nonatomic, strong) BMKGeoCodeSearch *searcher;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) WKFilterView *viewPopFilter;
@property (nonatomic, strong) WKFilterView *viewPopFilterOther;
@property (nonatomic, strong) UIView *viewFilter;
@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrJobType;
@property (nonatomic, strong) NSMutableArray *arrJobPlace;
@property (nonatomic, strong) NSMutableArray *arrJobTypeSelect;
@property (nonatomic, strong) NSMutableArray *arrJobPlaceSelect;
@property NSInteger page;
@property int lastPosition;
@end

@implementation NearSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.viewFilter = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT)];
    [self.viewFilter setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.viewFilter];
    
    float heightForFilterButton = SCREEN_WIDTH / 4;
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *btnFilter = [[UIButton alloc] initWithFrame:CGRectMake(i * heightForFilterButton, 0, heightForFilterButton, VIEW_H(self.viewFilter))];
        [btnFilter setTag:(i + 1)];
        if (i == 0) {
            [btnFilter setTag:5];
        }
        NSString *filterTitle = @"";
        if (i == 0) {
            filterTitle = @"3公里";
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
        
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, VIEW_H(btnFilter) - 2, VIEW_W(btnFilter) - 20, 1)];
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
    
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2, SCREEN_WIDTH, SCREEN_HEIGHT - (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2)) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n建议您扩大搜索范围~"];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setDataSource:self];
    [self.tableView setDelegate:self];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    UIView *viewStatusBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT)];
    [viewStatusBar setBackgroundColor:NAVBARCOLOR];
    [self.view addSubview:viewStatusBar];
    
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:@"", @"jobType", @"", @"salary", @"", @"experience", @"", @"education", @"", @"employType", [NSString stringWithFormat:@"%ld", self.page], @"pageNumber", @"", @"companySize", @"", @"welfare", @"", @"isOnline", @"", @"searchFromID", @"", @"lng", @"", @"lat", @"3000", @"Distance", nil];
    if (self.arrJobPlaceSelect == nil) {
        self.arrJobPlaceSelect = [[NSMutableArray alloc] init];
    }
    [self.arrJobPlaceSelect addObject:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"province"], @"value", [USER_DEFAULT objectForKey:@"provinceId"], @"id", nil]];
    self.searcher = [[BMKGeoCodeSearch alloc] init];
    self.searcher.delegate = self;
    
    self.locService = [[BMKLocationService alloc]init];
    self.locService.delegate = self;
    [self.locService startUserLocationService];
}

- (void)getData {
    [self.dataParam setObject:[NSString stringWithFormat:@"%ld", self.page] forKey:@"pageNumber"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobListByMapSearch" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self filterClose];
    self.searcher.delegate = nil;
    self.locService.delegate = nil;
    [self.runningRequest cancel];
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
        self.viewPopFilter = [[WKFilterView alloc] initWithButton:button];
        [self.viewPopFilter setDelegate:self];
        if (button.tag == WKFilterTypeDistance) {
            self.viewPopFilter.arrayData = [NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"1公里", @"Description", @"1000", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"3公里", @"Description", @"3000", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"5公里", @"Description", @"5000", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"", @"Description", @"", @"TitleID", nil],nil];
        }
        else if (button.tag == WKFilterTypeJobType) {
            self.viewPopFilter.arrayData = self.arrJobType;
        }
        else if (button.tag == WKFilterTypeSalary) {
            self.viewPopFilter.arrayData = [NSArray arrayWithObjects:
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"Description", @"", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"1K-2K", @"Description", @"2", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"2K-3K", @"Description", @"4", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"3K-4K", @"Description", @"6", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"4K-5K", @"Description", @"8", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"5K-6K", @"Description", @"9", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"6K-8K", @"Description", @"10", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"8K-10K", @"Description", @"11", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"10K-15K", @"Description", @"12", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"15K-20K", @"Description", @"13", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"20K以上", @"Description", @"14", @"TitleID", nil],
                                            [NSDictionary dictionaryWithObjectsAndKeys:@"面议", @"Description", @"100", @"TitleID", nil], nil];
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
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[data objectForKey:@"LogoUrl"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [cell.contentView addSubview:imgLogo];
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 20;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo) - 5, maxWidth - 70, 20) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [cell.contentView addSubview:onlineLab];
        // “聊”图标
//        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 16, 16)];
//        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
//        [cell.contentView addSubview:imgOnline];
    }
    
    WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, VIEW_Y(lbJob), 65, 20) content:[Common getSalary:[data objectForKey:@"dcSalaryID"] salaryMin:[data objectForKey:@"dcSalary"] salaryMax:[data objectForKey:@"dcSalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth - 65, 20) content:[data objectForKey:@"cpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbCompany), 50, 20) content:[Common stringFromRefreshDate:[data objectForKey:@"RefreshDate"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    
    NSString *experience = [data objectForKey:@"ExperienceName"];
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = [data objectForKey:@"EducationName"];
    if ([education length] == 0) {
        education = @"学历不限";
    }
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"RegionName"], experience, education] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = [data objectForKey:@"ID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.arrData.count < 30) {
        return;
    }
    int currentPostion = scrollView.contentOffset.y;
    if (currentPostion - self.lastPosition > 20  && currentPostion > 0) {
        self.lastPosition = currentPostion;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [self.tabBarController.tabBar setHidden:YES];
        [self.viewFilter setHidden:YES];
        [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT)];
        
    }
    else if ((self.lastPosition - currentPostion > 20) && (currentPostion <= scrollView.contentSize.height - scrollView.bounds.size.height - 20)) {
        self.lastPosition = currentPostion;
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [self.tabBarController.tabBar setHidden:NO];
        [self.viewFilter setHidden:NO];
        [self.tableView setFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2, SCREEN_WIDTH, SCREEN_HEIGHT - (STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT * 2) - TAB_BAR_HEIGHT)];
    }
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    CLLocationCoordinate2D loc = userLocation.location.coordinate;
    reverseGeoCodeSearchOption.reverseGeoPoint = loc;
    [self.dataParam setValue:[NSString stringWithFormat:@"%f", loc.latitude] forKey:@"lat"];
    [self.dataParam setValue:[NSString stringWithFormat:@"%f", loc.longitude] forKey:@"lng"];
    [self getData];
    BOOL flag = [self.searcher reverseGeoCode:reverseGeoCodeSearchOption];
    if(flag) {
        [self.locService stopUserLocationService];
    }
}

- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        self.title = result.address;
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.arrData removeAllObjects];
            [self.tableView setContentOffset:CGPointMake(0, 0)];
        }
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"dtJobList"];
        [self.arrData addObjectsFromArray:arrayData];
        [self.tableView reloadData];
        
        if (arrayData.count > 0) {
            [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:YES];
        }
        else {
            [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
        }
        if (arrayData.count < 30) {
            [self.tableView.mj_footer setHidden:YES];
        }
        else {
            [self.tableView.mj_footer setHidden:NO];
            [self.tableView.mj_footer endRefreshing];
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
}

- (void)WKFilterItemClick:(WKFilterType)filterType selectedItem:(NSDictionary *)selectedItem {
    [self filterClose];
    self.viewPopFilter = nil;
    NSString *title = @"";
    NSString *titleId = @"";
    if (filterType == WKFilterTypeDistance) {
        title = [selectedItem objectForKey:@"Description"];
        titleId = [selectedItem objectForKey:@"TitleID"];
        [self.dataParam setValue:titleId forKey:@"Distance"];
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
