//
//  YourFoodViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "YourFoodViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKButton.h"
#import "WKTableView.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "WKApplyView.h"
#import "UIView+Toast.h"
#import "OnlineLab.h"

@interface YourFoodViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, WKApplyViewDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrSelected;
@property (nonatomic, strong) UIView *viewApply;
@property NSInteger page;
@end

@implementation YourFoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n多申请职位可以增加就业机会哦~"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    self.viewApply = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, 60)];
    [self.viewApply setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.viewApply];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.viewApply addSubview:viewSeparate];
    
    WKButton *btnApply = [[WKButton alloc] initWithFrame:CGRectMake(25, 10, SCREEN_WIDTH - 50, 40)];
    [btnApply setTitle:@"立即申请" forState:UIControlStateNormal];
    [btnApply addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewApply addSubview:btnApply];
    
    self.arrSelected = [[NSMutableArray alloc] init];
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetYourFood" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.page], @"page", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(5, 15, 50, 50)];
    if (![[data objectForKey:@"Valid"] boolValue]) {
        UIImageView *imgJobExpired = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imgJobExpired setImage:[UIImage imageNamed:@"pa_jobexpired.png"]];
        [cell.contentView addSubview:imgJobExpired];
    }
    else {
        [btnCheck setTag:0];
        [btnCheck setTitle:[data objectForKey:@"JobID"] forState:UIControlStateNormal];
        [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnCheck addTarget:self action:@selector(checkClick:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnCheck];
        
        UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
        [imgCheck setImage:[UIImage imageNamed:@"img_checksmall2.png"]];
        [btnCheck addSubview:imgCheck];
        
        if ([self.arrSelected containsObject:[data objectForKey:@"JobID"]]) {
            [btnCheck setTag:1];
            [imgCheck setImage:[UIImage imageNamed:@"img_checksmall1.png"]];
        }
    }
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(btnCheck) - 20;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(btnCheck) + 5, VIEW_Y(btnCheck) - 5, maxWidth - 80, 20) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [cell.contentView addSubview:onlineLab];
        
        // "聊"图标
//        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 16, 16)];
//        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
//        [cell.contentView addSubview:imgOnline];
    }
    
    WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, VIEW_Y(lbJob), 65, 20) content:[Common getSalary:[data objectForKey:@"dcSalaryID"] salaryMin:[data objectForKey:@"Salary"] salaryMax:[data objectForKey:@"SalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth - 65, 20) content:[data objectForKey:@"CpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbCompany), 50, 20) content:[Common stringFromDateString:[data objectForKey:@"AddDate"] formatType:@"MM-dd"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    
    NSString *experience = [data objectForKey:@"Experience"];
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = [data objectForKey:@"Education"];
    if ([education length] == 0) {
        education = @"学历不限";
    }
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"Region"], experience, education] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
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
    if (![[data objectForKey:@"Valid"] boolValue]) {
        return;
    }
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = [data objectForKey:@"JobID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)checkClick:(UIButton *)button {
    UIImageView *imgCheck;
    for (UIView *view in button.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgCheck = (UIImageView *)view;
        }
    }
    if (imgCheck == nil) {
        return;
    }
    NSString *jobId = button.titleLabel.text;
    if (button.tag == 0) {
        [imgCheck setImage:[UIImage imageNamed:@"img_checksmall1.png"]];
        [button setTag:1];
        if (![self.arrSelected containsObject:jobId]) {
            [self.arrSelected addObject:jobId];
        }
    }
    else {
        [imgCheck setImage:[UIImage imageNamed:@"img_checksmall2.png"]];
        [button setTag:0];
        [self.arrSelected removeObject:jobId];
    }
    if (self.arrSelected.count > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameViewApply = self.viewApply.frame;
            frameViewApply.origin.y = SCREEN_HEIGHT - VIEW_H(self.viewApply);
            [self.viewApply setFrame:frameViewApply];
            
            CGRect frameTableView = self.tableView.frame;
            frameTableView.size.height = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - VIEW_H(self.viewApply);
            [self.tableView setFrame:frameTableView];
        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameViewApply = self.viewApply.frame;
            frameViewApply.origin.y = SCREEN_HEIGHT;
            [self.viewApply setFrame:frameViewApply];
            
            CGRect frameTableView = self.tableView.frame;
            frameTableView.size.height = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT;
            [self.tableView setFrame:frameTableView];
        }];
    }
}

- (void)applyClick {
    if (self.arrSelected.count == 0) {
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
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
    else if (request.tag == 2) {
        NSArray *arrayCv = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayCv.count == 0) {
            [self.view makeToast:@"您还没有完整简历，无法申请职位"];
        }
        else if (arrayCv.count == 1) {
            [self applyJob:[[arrayCv objectAtIndex:0] objectForKey:@"ID"]];
        }
        else {
            WKApplyView *applyView = [[WKApplyView alloc] initWithArrayCv:arrayCv];
            [applyView setDelegate:self];
            [applyView show:self];
        }
    }
    else if (request.tag == 3) {
        [self.view.window makeToast:@"职位申请成功"];
    }
}

- (void)WKApplyViewConfirm:(WKApplyView *)applyView arrayJobId:(NSString *)cvMainId {
    [self applyJob:cvMainId];
}

- (void)applyJob:(NSString *)cvMainId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"PaMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", cvMainId, @"strCvMainID", [self.arrSelected componentsJoinedByString:@","], @"strJobIDs", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
    [request setTag:3];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
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
