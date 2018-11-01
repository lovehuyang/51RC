//
//  JobListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/30.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKTableView.h"
#import "WKNavigationController.h"
#import "JobViewController.h"

@interface JobListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property NSInteger page;
@end

@implementation JobListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobList" Params:[NSDictionary dictionaryWithObjectsAndKeys:self.companyId, @"cpMainId", [NSString stringWithFormat:@"%ld", self.page], @"page", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    [self.arrData addObjectsFromArray:arrayData];
    [self.tableView reloadData];
    if (arrayData.count < 20) {
        if (self.page == 1) {
            [self.tableView.mj_footer removeFromSuperview];
            if (arrayData.count == 0) {
                [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
            }
        }
        else {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }
    }
    else {
        [self.tableView.mj_footer endRefreshing];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    float maxWidth = SCREEN_WIDTH - 30 - 80;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 15, maxWidth, 20) content:[data objectForKey:@"Name"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, VIEW_Y(lbJob), 65, 20) content:[Common getSalary:[data objectForKey:@"dcSalaryID"] salaryMin:[data objectForKey:@"Salary"] salaryMax:[data objectForKey:@"SalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    
    NSString *experience = [data objectForKey:@"Experience"];
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = [data objectForKey:@"Eudcation"];
    if ([education length] == 0) {
        education = @"学历不限";
    }
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"Region"], experience, education] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDetail];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbDetail), 50, 20) content:[Common stringFromRefreshDate:[data objectForKey:@"RefreshDate"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];

    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    [self.delegate jobClick:[data objectForKey:@"ID"]];
}

- (void)adjustHeight:(float)height {
    CGRect frameTable = self.tableView.frame;
    frameTable.size.height = height;
    [self.tableView setFrame:frameTable];
    
    CGRect frameView = self.view.frame;
    frameView.size.height = height;
    [self.view setFrame:frameView];
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
