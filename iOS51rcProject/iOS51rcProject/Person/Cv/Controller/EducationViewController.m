//
//  EducationViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/13.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "EducationViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "EducationModifyViewController.h"
#import "NetWebServiceRequest.h"

@interface EducationViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation EducationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"教育背景";
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetEducation" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", nil] viewController:self];
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
    
    WKLabel *lbCollege = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(20, VIEW_BY(viewTop) + 20, SCREEN_WIDTH - 40 - 60, 20) content:[data objectForKey:@"GraduateCollage"] size:BIGGERFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbCollege];
    
    WKLabel *lbEdit = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 60, VIEW_Y(lbCollege), 40, 20) content:@"编辑" size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbEdit setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbEdit];
    
    WKLabel *lbGraduation = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCollege), VIEW_BY(lbCollege) + 5, SCREEN_WIDTH - 30, 20) content:[NSString stringWithFormat:@"%@年%@月毕业", [[data objectForKey:@"Graduation"] substringToIndex:4], [[data objectForKey:@"Graduation"] substringFromIndex:4]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbGraduation];
    
    WKLabel *lbOther = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbGraduation), VIEW_BY(lbGraduation) + 5, SCREEN_WIDTH - 30, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@（%@）", [data objectForKey:@"Major"], [data objectForKey:@"MajorName"], [data objectForKey:@"DegreeName"], [data objectForKey:@"EduTypeName"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [cell.contentView addSubview:lbOther];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbOther) + 20)];
    
    if ([[data objectForKey:@"Details"] length] > 0) {
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbGraduation), VIEW_BY(lbOther) + 5, SCREEN_WIDTH - 30, 20) content:[data objectForKey:@"Details"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [cell.contentView addSubview:lbDetail];
        
        [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDetail) + 20)];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    EducationModifyViewController *educationModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"educationModifyView"];
    educationModifyCtrl.dataEducation = data;
    educationModifyCtrl.cvMainId = [data objectForKey:@"cvMainID"];
    [self.navigationController pushViewController:educationModifyCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    self.arrayData = [Common getArrayFromXml:requestData tableName:@"Education"];
    if (self.arrayData.count == 0) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if (self.arrayData.count >= 5) {
        self.navigationItem.rightBarButtonItem = NULL;
    }
    else {
        UIBarButtonItem *btnAdd = [[UIBarButtonItem alloc] initWithTitle:@"+添加" style:UIBarButtonItemStylePlain target:self action:@selector(addEducation)];
        [btnAdd setTintColor:[UIColor whiteColor]];
        self.navigationItem.rightBarButtonItem = btnAdd;
    }
    [self.tableView reloadData];
}

- (void)addEducation {
    EducationModifyViewController *educationModifyCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"educationModifyView"];
    educationModifyCtrl.cvMainId = self.cvMainId;
    [self.navigationController pushViewController:educationModifyCtrl animated:YES];
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
