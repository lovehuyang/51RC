//
//  JobAttentionViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobAttentionViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "WKButton.h"
#import "WKTableView.h"
#import "UIView+Toast.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "WKApplyView.h"
#import "OnlineLab.h"

@interface JobAttentionViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, WKApplyViewDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) NSMutableArray *arrSelected;
@property (nonatomic, strong) UIView *viewApply;
@property NSInteger page;
@end

@implementation JobAttentionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n关注感兴趣的企业或职位\n求职信息早知道"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    self.viewApply = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(self.tableView), SCREEN_WIDTH, 60)];
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobAttention" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.page], @"page", nil] viewController:self];
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
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(5, 0, 50, 50)];
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
        [btnCheck setImage:[UIImage imageNamed:@"img_checksmall2.png"] forState:UIControlStateNormal];
        [btnCheck.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnCheck setImageEdgeInsets:UIEdgeInsetsMake(35, 0, 35, 0)];
        [cell.contentView addSubview:btnCheck];
        
        if ([self.arrSelected containsObject:[data objectForKey:@"JobID"]]) {
            [btnCheck setTag:1];
             [btnCheck setImage:[UIImage imageNamed:@"img_checksmall1.png"] forState:UIControlStateNormal];
        }
    }
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(btnCheck) - 20 - 75;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(btnCheck) + 5, 10, maxWidth, 20) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [cell.contentView addSubview:onlineLab];
        //"聊"图标
//        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 16, 16)];
//        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
//        [cell.contentView addSubview:imgOnline];
    }
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, 0, 60, 80)];
    [btnCancel setTag:indexPath.row];
    [btnCancel addTarget:self action:@selector(cancelClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"取消关注" forState:UIControlStateNormal];
    [btnCancel setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:DEFAULTFONT];
    [cell.contentView addSubview:btnCancel];
    
    if ([[data objectForKey:@"IsApply"] isEqualToString:@"1"]) {
        WKLabel *lbApply = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbJob) + 2, 50, 16) content:@"已申请" size:12 color:GREENCOLOR];
        [lbApply.layer setBorderColor:[GREENCOLOR CGColor]];
        [lbApply.layer setBorderWidth:1];
        [lbApply.layer setCornerRadius:3];
        [lbApply setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lbApply];
    }
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob) + 5, maxWidth, 20) content:[data objectForKey:@"CpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    NSString *education = [data objectForKey:@"Education"];
    if ([education length] == 0) {
        education = @"学历不限";
    }
    WKLabel *lbSalary = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany) + 5, maxWidth, 20) content:[Common getSalary:[data objectForKey:@"dcSalaryID"] salaryMin:[data objectForKey:@"SalaryMin"] salaryMax:[data objectForKey:@"SalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [cell.contentView addSubview:lbSalary];
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(lbSalary), VIEW_Y(lbSalary), maxWidth, 20) content:[NSString stringWithFormat:@" | %@ | %@ | %@关注", [data objectForKey:@"Region"], education, [Common stringFromDateString:[data objectForKey:@"AddDate"] formatType:@"MM-dd"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    [btnCheck setFrame:CGRectMake(5, 0, 50, VIEW_BY(viewSeparate))];
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

- (void)cancelClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要取消关注该职位吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteAttention" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [data objectForKey:@"ID"], @"id", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertDelete animated:YES completion:nil];
}

- (void)checkClick:(UIButton *)button {
    NSString *jobId = button.titleLabel.text;
    if (button.tag == 0) {
        [button setImage:[UIImage imageNamed:@"img_checksmall1.png"] forState:UIControlStateNormal];
        [button setTag:1];
        if (![self.arrSelected containsObject:jobId]) {
            [self.arrSelected addObject:jobId];
        }
    }
    else {
        [button setImage:[UIImage imageNamed:@"img_checksmall2.png"] forState:UIControlStateNormal];
        [button setTag:0];
        [self.arrSelected removeObject:jobId];
    }
    if (self.arrSelected.count > 0) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameViewApply = self.viewApply.frame;
            frameViewApply.origin.y = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT - VIEW_H(self.viewApply);
            [self.viewApply setFrame:frameViewApply];
            
            CGRect frameTableView = self.tableView.frame;
            frameTableView.size.height = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT - VIEW_H(self.viewApply);
            [self.tableView setFrame:frameTableView];
        }];
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameViewApply = self.viewApply.frame;
            frameViewApply.origin.y = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT;
            [self.viewApply setFrame:frameViewApply];
            
            CGRect frameTableView = self.tableView.frame;
            frameTableView.size.height = SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT * 2 - STATUS_BAR_HEIGHT;
            [self.tableView setFrame:frameTableView];
        }];
    }
}

- (void)applyClick {
    if (self.arrSelected.count == 0) {
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCvListApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:nil];
    [request setTag:3];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)applyJob:(NSString *)cvMainId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"InsertJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"PaMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", cvMainId, @"strCvMainID", [self.arrSelected componentsJoinedByString:@","], @"strJobIDs", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
    [request setTag:4];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)WKApplyViewConfirm:(WKApplyView *)applyView arrayJobId:(NSString *)cvMainId {
    [self applyJob:cvMainId];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if (self.page == 1) {
            [self.arrData removeAllObjects];
        }
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
        [self.view makeToast:@"已取消关注"];
        self.page = 1;
        [self getData];
    }
    else if (request.tag == 3) {
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
    else if (request.tag == 4) {
        [self.view.window makeToast:@"职位申请成功"];
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
