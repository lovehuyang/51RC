//
//  ExperienceViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/13.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ExperienceViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "ExperienceModifyViewController.h"
#import "NetWebServiceRequest.h"

@interface ExperienceViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation ExperienceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"工作经历";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetExperience" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [viewTop setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewTop];
    
    WKLabel *lbCompanyName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(20, VIEW_BY(viewTop) + 20, SCREEN_WIDTH - 40 - 60, 20) content:[data objectForKey:@"CompanyName"] size:BIGGERFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbCompanyName];
    
    WKLabel *lbEdit = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbCompanyName), 40, 20) content:@"编辑" size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbEdit setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbEdit];
    
    NSString *beginDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"BeginDate"] substringToIndex:4], [[data objectForKey:@"BeginDate"] substringFromIndex:4]];
    NSString *endDate = [NSString stringWithFormat:@"%@年%@月", [[data objectForKey:@"EndDate"] substringToIndex:4], [[data objectForKey:@"EndDate"] substringFromIndex:4]];
    if ([[data objectForKey:@"EndDate"] isEqualToString:@"999999"]) {
        endDate = @"至今";
    }
    WKLabel *lbWorkDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompanyName), VIEW_BY(lbCompanyName) + 5, SCREEN_WIDTH - 30, 20) content:[NSString stringWithFormat:@"%@ 至 %@", beginDate, endDate] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbWorkDate];
    
    WKLabel *lbCpDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbWorkDate) + 5, SCREEN_WIDTH - 30, 20) content:[NSString stringWithFormat:@"%@ | %@", [data objectForKey:@"Industry"], [data objectForKey:@"CpmpanySize"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbCpDetail];
    
    WKLabel *lbOther = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbCpDetail) + 5, SCREEN_WIDTH - 30, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"JobName"], [data objectForKey:@"JobType"], [data objectForKey:@"LowerNumber"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbOther];
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbWorkDate), VIEW_BY(lbOther) + 5, SCREEN_WIDTH - 30, 20) content:[data objectForKey:@"Description"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbDetail];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDetail) + 20)];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    ExperienceModifyViewController *experienceModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"experienceModifyView"];
    experienceModifyCtrl.dataExperience = data;
    experienceModifyCtrl.cvMainId = [data objectForKey:@"cvMainID"];
    [self.navigationController pushViewController:experienceModifyCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    self.arrayData = [Common getArrayFromXml:requestData tableName:@"Experience"];
    if (self.arrayData.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.arrayData.count >= 20) {
        self.navigationItem.rightBarButtonItem = NULL;
    }
    else {
        UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithTitle:@"+添加" style:UIBarButtonItemStylePlain target:self action:@selector(addExperience)];
        [btnAdd setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = btnAdd;
    }
    [self.tableView reloadData];
}

- (void)addExperience {
    ExperienceModifyViewController *experienceModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"experienceModifyView"];
    experienceModifyCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:experienceModifyCtrl animated:YES];
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
