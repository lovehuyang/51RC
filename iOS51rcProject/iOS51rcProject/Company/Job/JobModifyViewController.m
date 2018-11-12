//
//  JobModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  新增职位页面
//  职位修改页面

#import "JobModifyViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "ResponsibilityViewController.h"
#import "DemandViewController.h"
#import "WelfareViewController.h"
#import "JobTagViewController.h"
#import "JobPlaceViewController.h"
#import "JobPushViewController.h"

@interface JobModifyViewController ()<UITextFieldDelegate, WKPopViewDelegate, NetWebServiceRequestDelegate, ResponsibilityViewDelegate, DemandViewDelegate, WelfareViewDelegate, JobTagViewDelegate, JobPlaceViewDelegate, JobPushViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) NSMutableDictionary *jobData;
@property (nonatomic, strong) NSDictionary *companyData;
@property (nonatomic, strong) NSArray *arrayTemplate;
@property (nonatomic , strong) NSDictionary *welfareDict;// 未使用模板时福利待遇默认选择以前选择过的
@end

@implementation JobModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [Common changeFontSize:self.view];
    if (self.jobId == nil) {
        self.jobId = @"0";
        self.title = @"新增职位";
        [self getWelfare];
    }
    else {
        [self.viewTemplate removeFromSuperview];
        [self.constraintsJobTypeTop setConstant:0];
        self.title = @"职位修改";
    }
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"发布" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:2];
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *mDate = [calender dateByAddingComponents:comps toDate:[NSDate date] options:0];
    self.txtIssueEnd.text = [Common stringFromDate:mDate formatType:@"yyyy-MM-dd"];
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      CAMAINID, @"caMainID",
                      CAMAINCODE, @"Code",
                      CPMAINID, @"cpMainID",
                      self.jobId, @"intJobId",
                      @"", @"strJobName",
                      @"", @"JobTypeID",
                      @"", @"dcJobTypeMinorID",
                      @"", @"NeedNum",
                      @"", @"dcSalaryID",
                      @"", @"dcSalaryMaxID",
                      @"", @"EmployType",
                      @"", @"RegionID",
                      @"", @"Lat",
                      @"", @"Lng",
                      @"", @"Responsibility",
                      @"", @"Demand",
                      @"", @"EducationID",
                      @"", @"MinExperience",
                      @"99", @"MinAge",
                      @"99", @"MaxAge",
                      @"", @"Negotiable",
                      @"", @"Welfare",
                      @"", @"Tags",
                      @"", @"Address",
                      self.txtIssueEnd.text, @"IssueEnd",
                      @"", @"strEMailSendFreq", nil];
    [self.txtAge setText:@"不限"];
    [self getCpData];
}

#pragma mark - 获取公司概况信息
- (void)getCpData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 福利待遇
- (void)getWelfare{
    // 获取以往简历中用户经常选择的福利待遇标签
    NSDictionary *paramDict = @{@"caMainID":CAMAINID,@"Code":CAMAINCODE};
    [AFNManager requestCpWithMethod:POST ParamDict:paramDict url:URL_GETJOBWELFAREBYCAMAINID tableName:@"ds" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [self dealWelfare:requestData];
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        
    }];
}

- (void)getJobData {
    if ([self.jobId isEqualToString:@"0"]) {
        [self getTemplate];
        
        [self.txtRegion setText:[self.companyData objectForKey:@"Region"]];// 地区
        [self.dataParam setObject:[self.companyData objectForKey:@"dcRegionID"] forKey:@"RegionID"];// 获取地区id
        [self.dataParam setObject:[self.companyData objectForKey:@"Lat"] forKey:@"Lat"];// 经纬度 - 纬度
        [self.dataParam setObject:[self.companyData objectForKey:@"Lng"] forKey:@"Lng"];//  经度
        [self.dataParam setObject:[self.companyData objectForKey:@"Address"] forKey:@"Address"];// 地址
        
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"getJobDetailByID" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.jobId, @"intJobID", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark -  获取所有的模板详情
- (void)getTemplate {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"getJobTemplateList" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:5];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCpMain = [Common getArrayFromXml:requestData tableName:@"TableCp"];
        self.companyData = [arrayCpMain objectAtIndex:0];
        [self getJobData];
    }
    else if (request.tag == 2) {
        NSArray *arrayJob = [Common getArrayFromXml:requestData tableName:@"dtJob"];
        if (arrayJob.count > 0) {
            self.jobData = [[arrayJob objectAtIndex:0] mutableCopy];
            [self fillData];
        }
    }
    else if (request.tag == 3) {
        if ([result isEqualToString:@"-1"]) {
            [self.view.window makeToast:@"该职位不存在可能已被删除！"];
        }
        else if ([result isEqualToString:@"-2"]) {
            [self.view.window makeToast:@"您不能修改其他人的职位！"];
        }
        else if ([result isEqualToString:@"-3"]) {
            [self.view.window makeToast:@"数据异常请稍候重试！"];
        }
        else if ([result isEqualToString:@"-6"]) {
            [self.view.window makeToast:@"职位名称不符合要求！"];
        }
        else if ([result isEqualToString:@"-7"]) {
            [self.view.window makeToast:@"职位名称重复了。同一企业不能存在相同名称的职位，请修改一下职位名称！"];
        }
        else if ([result isEqualToString:@"-4"]) {
            if ([[self.companyData objectForKey:@"MemberType"] isEqualToString:@"1"]) {
                [self.view.window makeToast:@"您最多只能发布3个职位，要发布更多职位，请到电脑端完成企业认证！"];
            }
            else if ([[self.companyData objectForKey:@"MemberType"] isEqualToString:@"2"]) {
                [self.view.window makeToast:[NSString stringWithFormat:@"您最多只能发布%@个职位，要发布更多职位，请申请VIP！", [self.companyData objectForKey:@"MaxJobNumber"]]];
            }
            else if ([[self.companyData objectForKey:@"MemberType"] isEqualToString:@"3"]) {
                [self.view.window makeToast:[NSString stringWithFormat:@"您最多只能发布%@个职位，要发布更多职位，请购买职位并发数！", [self.companyData objectForKey:@"MaxJobNumber"]]];
            }
        }
        else if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"职位信息保存成功！"];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (request.tag == 4) {
        NSArray *arrayJobType = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrayJobType.count > 0) {
            NSDictionary *jobTypeData = [arrayJobType objectAtIndex:0];
            [self.txtResponsibility setText:[jobTypeData objectForKey:@"Responsibility"]];
            [self.txtDemand setText:[jobTypeData objectForKey:@"Demand"]];
            [self.dataParam setObject:[jobTypeData objectForKey:@"Responsibility"] forKey:@"Responsibility"];
            [self.dataParam setObject:[jobTypeData objectForKey:@"Demand"] forKey:@"Demand"];
        }
    }
    else if (request.tag == 5) {// 获取模板
        self.arrayTemplate = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (self.arrayTemplate.count == 0) {
            [self.viewTemplate removeFromSuperview];
            [self.constraintsJobTypeTop setConstant:0];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    self.currentTextField = textField;
    if (textField == self.txtJobName) {
        return YES;
    }
    if (textField == self.txtTemplate) {
        [self templateClick];
    }
    else if (textField == self.txtJobType) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeJobType value:[self.dataParam objectForKey:@"JobTypeID"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtJobTypeMinor) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeJobType value:[self.dataParam objectForKey:@"dcJobTypeMinorID"]];
        [popView setCancelClear:YES];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtNeedNumber) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeNeedNumber value:[self.dataParam objectForKey:@"dcJobTypeMinorID"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtEmployType) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeEmployType value:[self.dataParam objectForKey:@"EmployType"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtRegion) {
        [self regionClick];
    }
    else if (textField == self.txtIssueEnd) {
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 220)];
        [self.datePicker setDate:[Common dateFromString:[self.dataParam objectForKey:@"IssueEnd"]] animated:YES];
        [self.datePicker setDatePickerMode:UIDatePickerModeDate];
        
        NSDate *date = [NSDate date];
        NSCalendar *calendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:date];
        NSInteger year = [components year];
        [self.datePicker setMinimumDate:date];
        [self.datePicker setMaximumDate:[Common dateFromString:[NSString stringWithFormat:@"%ld-12-31", (year + 1)]]];
        
        WKPopView *popView = [[WKPopView alloc] initWithCustomView:self.datePicker];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtDegree) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeJobDegree value:[self.dataParam objectForKey:@"EducationID"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtWorkYears) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeNeedWorkYears value:[self.dataParam objectForKey:@"MinExperience"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtAge) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchAge value:@""];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtResponsibility) {
        ResponsibilityViewController *rCtrl = [[ResponsibilityViewController alloc] init];
        [rCtrl setDelegate:self];
        rCtrl.responsibility = [self.dataParam objectForKey:@"Responsibility"];
        [self.navigationController pushViewController:rCtrl animated:YES];
    }
    else if (textField == self.txtDemand) {
        DemandViewController *demandCtrl = [[DemandViewController alloc] init];
        [demandCtrl setDelegate:self];
        demandCtrl.demand = [self.dataParam objectForKey:@"Demand"];
        [self.navigationController pushViewController:demandCtrl animated:YES];
    }
    else if (textField == self.txtSalary) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeJobSalary value:[self.dataParam objectForKey:@"Negotiable"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtNegotiable) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeNegotiable value:[self.dataParam objectForKey:@"Negotiable"]];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
    else if (textField == self.txtWelfare) {// 福利待遇
        WelfareViewController *welfareCtrl = [[WelfareViewController alloc] init];
        welfareCtrl.selectedWelfareId = [self.dataParam objectForKey:@"Welfare"];
        [welfareCtrl setDelegate:self];
        [self.navigationController pushViewController:welfareCtrl animated:YES];
    }
    else if (textField == self.txtTags) {
        JobTagViewController *jobTagCtrl = [[JobTagViewController alloc] init];
        jobTagCtrl.selectedTag = [self.dataParam objectForKey:@"Tags"];
        [jobTagCtrl setDelegate:self];
        [self.navigationController pushViewController:jobTagCtrl animated:YES];
    }
    else if (textField == self.txtPush) {
        JobPushViewController *jobPushCtrl = [[JobPushViewController alloc] init];
        jobPushCtrl.pushId = [self.dataParam objectForKey:@"strEMailSendFreq"];
        [jobPushCtrl setDelegate:self];
        [self.navigationController pushViewController:jobPushCtrl animated:YES];
    }
    return NO;
}

- (void)regionClick {
    JobPlaceViewController *jobPlaceCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobPlaceView"];
    jobPlaceCtrl.lat = [self.dataParam objectForKey:@"Lat"];
    jobPlaceCtrl.lng = [self.dataParam objectForKey:@"Lng"];
    jobPlaceCtrl.region = self.txtRegion.text;
    jobPlaceCtrl.regionId = [self.dataParam objectForKey:@"RegionID"];
    jobPlaceCtrl.address = [self.dataParam objectForKey:@"Address"];
    [jobPlaceCtrl setDelegate:self];
    [self.navigationController pushViewController:jobPlaceCtrl animated:YES];
}

#pragma mark - 点击从模板中复制
- (void)templateClick {
    if (self.arrayTemplate.count == 0) {
        [self.view.window makeToast:@"您还没有职位模板"];
        return;
    }
    NSMutableArray *arrayPop = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < self.arrayTemplate.count; i++) {
        NSDictionary *data = [self.arrayTemplate objectAtIndex:i];
        [arrayPop addObject:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", i], @"id", [data objectForKey:@"Name"], @"value", nil]];
    }
    WKPopView *popView = [[WKPopView alloc] initWithArray:arrayPop value:self.templateStr];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    if (self.currentTextField == self.txtIssueEnd) {
        NSString *stringIssueEnd = [Common stringFromDate:self.datePicker.date formatType:@"yyyy-MM-dd"];
        [self.dataParam setValue:stringIssueEnd forKey:@"IssueEnd"];
        [self.currentTextField setText:stringIssueEnd];
    }
    [popView cancelClick];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    [self.currentTextField setText:[data objectForKey:@"value"]];
    if (self.currentTextField == self.txtTemplate) {
        self.templateStr = self.currentTextField.text;
        NSInteger index = [[data objectForKey:@"id"] integerValue];
        self.jobData = [[self.arrayTemplate objectAtIndex:index] mutableCopy];
        [self.jobData setObject:self.txtJobName.text forKey:@"Name"];
        [self.jobData setObject:[self.jobData objectForKey:@"DeMand"] forKey:@"Demand"];
        [self.jobData setObject:[self.jobData objectForKey:@"jobTags"] forKey:@"JobTags"];
        [self.jobData setObject:[self.jobData objectForKey:@"dcRegionId"] forKey:@"dcRegionID"];
        [self.jobData setObject:[self.jobData objectForKey:@"dcJobTypeId"] forKey:@"dcJobTypeID"];
        if ([[self.jobData objectForKey:@"dcJobTypeIdMinor"] length] > 0) {
            [self.jobData setObject:[self.jobData objectForKey:@"dcJobTypeIdMinor"] forKey:@"dcJobTypeIDMinor"];
        }
        [self.jobData setObject:[self.jobData objectForKey:@"dcEducationId"] forKey:@"dcEducationID"];
        [self.jobData setObject:[self.jobData objectForKey:@"dcSalaryId"] forKey:@"dcSalaryID"];
        [self.jobData setObject:self.txtIssueEnd.text forKey:@"IssueEnd"];
        [self fillData];
        [self regionClick];
    }
    else if (self.currentTextField == self.txtJobType) {
        data = [arraySelect objectAtIndex:arraySelect.count - 1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"JobTypeID"];
        [self.txtJobType setText:[data objectForKey:@"value"]];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetDcJobTypeTemplate" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [data objectForKey:@"id"], @"dcJobTypeId", nil] viewController:self];
        [request setTag:4];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    else if (self.currentTextField == self.txtJobTypeMinor) {
        data = [arraySelect objectAtIndex:arraySelect.count - 1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"dcJobTypeMinorID"];
        [self.txtJobTypeMinor setText:[data objectForKey:@"value"]];
    }
    else if (self.currentTextField == self.txtNeedNumber) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"NeedNum"];
    }
    else if (self.currentTextField == self.txtEmployType) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"EmployType"];
    }
    else if (self.currentTextField == self.txtRegion) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"RegionID"];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Address"];
    }
    else if (self.currentTextField == self.txtDegree) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"EducationID"];
    }
    else if (self.currentTextField == self.txtWorkYears) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"MinExperience"];
    }
    else if (self.currentTextField == self.txtAge) {
        NSDictionary *dataMax = [arraySelect objectAtIndex:2];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"MinAge"];
        [self.dataParam setValue:[dataMax objectForKey:@"id"] forKey:@"MaxAge"];
        NSString *age;
        if ([[data objectForKey:@"id"] isEqualToString:@"99"] && [[dataMax objectForKey:@"id"] isEqualToString:@"99"]) {
            age = @"不限";
        }
        else if ([[data objectForKey:@"id"] isEqualToString:@"99"]) {
            age = [NSString stringWithFormat:@"%@以下", [dataMax objectForKey:@"value"]];
        }
        else if ([[dataMax objectForKey:@"id"] isEqualToString:@"99"]) {
            age = [NSString stringWithFormat:@"%@以上", [data objectForKey:@"value"]];
        }
        else {
            if ([[data objectForKey:@"value"] integerValue] >= [[dataMax objectForKey:@"value"] integerValue]) {
                [self.view.window makeToast:@"最小年龄不能超过最大年龄"];
                [self.txtAge setText:@""];
                [self.dataParam setValue:@"" forKey:@"MinAge"];
                [self.dataParam setValue:@"" forKey:@"MaxAge"];
                return;
            }
            age = [NSString stringWithFormat:@"%@至%@", [data objectForKey:@"value"], [dataMax objectForKey:@"value"]];
        }
        [self.txtAge setText:age];
    }
    else if (self.currentTextField == self.txtSalary) {
        NSString *salaryId = [data objectForKey:@"id"];
        NSString *salaryIdMax = @"";
        NSString *salary = @"";
        if ([salaryId isEqualToString:@"16"]) {
            salaryIdMax = @"16";
            salary = [data objectForKey:@"value"];
        }
        else {
            NSDictionary *dataMax = [arraySelect objectAtIndex:2];
            salaryIdMax = [dataMax objectForKey:@"id"];
            salary = [NSString stringWithFormat:@"%@-%@", [data objectForKey:@"value"], [dataMax objectForKey:@"value"]];
        }
        NSDictionary *dataNegotiable = [arraySelect objectAtIndex:3];
        [self.dataParam setValue:salaryId forKey:@"dcSalaryID"];
        [self.dataParam setValue:salaryIdMax forKey:@"dcSalaryMaxID"];
        [self.dataParam setValue:[dataNegotiable objectForKey:@"id"] forKey:@"Negotiable"];
        if ([[dataNegotiable objectForKey:@"id"] isEqualToString:@"1"]) {
            salary = [NSString stringWithFormat:@"%@（可面议）", salary];
        }
        [self.txtSalary setText:salary];
    }
    
    [self genSalaryJobString];
}

- (void)fillData {
    NSMutableArray *arrayWelfareId = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < 20; i++) {
        if ([[self.jobData objectForKey:[NSString stringWithFormat:@"Welfare%ld", i]] boolValue]) {
            [arrayWelfareId addObject:@"1"];
        }
        else {
            [arrayWelfareId addObject:@"0"];
        }
    }
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      CAMAINID, @"caMainID",
                      CAMAINCODE, @"Code",
                      CPMAINID, @"cpMainID",
                      self.jobId, @"intJobId",
                      [self getString:[self.jobData objectForKey:@"Name"]], @"strJobName",
                      [self getString:[self.jobData objectForKey:@"dcJobTypeID"]], @"JobTypeID",
                      [self getString:[self.jobData objectForKey:@"dcJobTypeIDMinor"]], @"dcJobTypeMinorID",
                      [self getString:[self.jobData objectForKey:@"NeedNumber"]], @"NeedNum",
                      [self getString:[self.jobData objectForKey:@"dcSalaryID"]], @"dcSalaryID",
                      [self getString:[self.jobData objectForKey:@"dcSalaryIdMax"]], @"dcSalaryMaxID",
                      [self getString:[self.jobData objectForKey:@"EmployType"]], @"EmployType",
                      [self getString:[self.jobData objectForKey:@"dcRegionID"]], @"RegionID",
                      [self getString:[self.jobData objectForKey:@"Lat"]], @"Lat",
                      [self getString:[self.jobData objectForKey:@"Lng"]], @"Lng",
                      [self getString:[self.jobData objectForKey:@"Responsibility"]], @"Responsibility",
                      [self getString:[self.jobData objectForKey:@"Demand"]], @"Demand",
                      [self getString:[self.jobData objectForKey:@"dcEducationID"]], @"EducationID",
                      [self getString:[self.jobData objectForKey:@"MinExperience"]], @"MinExperience",
                      [self getString:[self.jobData objectForKey:@"MinAge"]], @"MinAge",
                      [self getString:[self.jobData objectForKey:@"MaxAge"]], @"MaxAge",
                      ([[self.jobData objectForKey:@"Negotiable"] boolValue] ? @"1" : @"0"), @"Negotiable",
                      [arrayWelfareId componentsJoinedByString:@","], @"Welfare",
                      [self getString:[self.jobData objectForKey:@"JobTags"]], @"Tags",
                      [self getString:[self.jobData objectForKey:@"BaiduMapAddress"]], @"Address",
                      [Common stringFromDateString:[self.jobData objectForKey:@"IssueEnd"] formatType:@"yyyy-MM-dd"], @"IssueEnd",
                      [self getString:[Common getPushIdWithBin:[self.jobData objectForKey:@"EMailSendFreq"]]], @"strEMailSendFreq", nil];
    
    self.txtJobName.text = [self.jobData objectForKey:@"Name"];
    self.txtJobType.text = [self.jobData objectForKey:@"JobTypeName"];
    self.txtJobTypeMinor.text = [self.jobData objectForKey:@"JobTypeMinorName"];
    self.txtNeedNumber.text = [self.jobData objectForKey:@"NeedNumName"];
    self.txtEmployType.text = [self.jobData objectForKey:@"EmployTypeName"];
    self.txtRegion.text = [self.jobData objectForKey:@"Region"];
    self.txtIssueEnd.text = [self.dataParam objectForKey:@"IssueEnd"];
    self.txtDegree.text = [self.jobData objectForKey:@"Education"];
    self.txtWorkYears.text = [self.jobData objectForKey:@"ExperienceName"];
    self.txtResponsibility.text = [self.jobData objectForKey:@"Responsibility"];
    self.txtDemand.text = [self.jobData objectForKey:@"Demand"];
    self.txtTags.text = [[self.jobData objectForKey:@"JobTags"] stringByReplacingOccurrencesOfString:@"@" withString:@"+"];
    
    NSString *age = [NSString stringWithFormat:@"%@岁至%@岁", [self.jobData objectForKey:@"MinAge"], [self.jobData objectForKey:@"MaxAge"]];
    if ([[self.jobData objectForKey:@"MinAge"] isEqualToString:@"99"] && [[self.jobData objectForKey:@"MaxAge"] isEqualToString:@"99"]) {
        age = @"不限";
    }
    else if ([[self.jobData objectForKey:@"MaxAge"] isEqualToString:@"99"]) {
        age = [NSString stringWithFormat:@"%@岁以上", [self.jobData objectForKey:@"MinAge"]];
    }
    else if ([[self.jobData objectForKey:@"MinAge"] isEqualToString:@"99"]) {
        age = [NSString stringWithFormat:@"%@岁以下", [self.jobData objectForKey:@"MaxAge"]];
    }
    self.txtAge.text = age;
    
    NSString *salary = [NSString stringWithFormat:@"%@-%@", [self.jobData objectForKey:@"SalaryName"], [self.jobData objectForKey:@"SalaryMaxName"]];
    if ([[self.jobData objectForKey:@"dcSalaryID"] isEqualToString:@"16"]) {
        salary = [NSString stringWithFormat:@"%@以上", [self.jobData objectForKey:@"SalaryName"]];
    }
    if ([[self.jobData objectForKey:@"Negotiable"] boolValue]) {
        salary = [NSString stringWithFormat:@"%@（可面议）", salary];
    }
    if ([[self.jobData objectForKey:@"dcSalaryID"] isEqualToString:@"100"]) {
        salary = @"面议";
    }
    self.txtSalary.text = salary;
    self.txtWelfare.text = [Common getWelfare:arrayWelfareId];
    self.txtPush.text = [Common getPush:[Common getPushIdWithBin:[self.jobData objectForKey:@"EMailSendFreq"]]];
}

- (void)ResponsibilityViewConfirm:(NSString *)responsibility {
    [self.txtResponsibility setText:responsibility];
    [self.dataParam setObject:responsibility forKey:@"Responsibility"];
}

- (void)DemandViewConfirm:(NSString *)demand {
    [self.txtDemand setText:demand];
    [self.dataParam setObject:demand forKey:@"Demand"];
}

- (void)WelfareViewConfirm:(NSString *)welfareId welfare:(NSString *)welfare {
    [self.dataParam setObject:welfareId forKey:@"Welfare"];
    [self.txtWelfare setText:welfare];
}

- (void)JobTagViewConfirm:(NSString *)tag {
    [self.dataParam setObject:[tag stringByReplacingOccurrencesOfString:@"+" withString:@"@"] forKey:@"Tags"];
    [self.txtTags setText:tag];
}

- (void)JobPlaceViewConfirm:(NSString *)region regionId:(NSString *)regionId address:(NSString *)address lat:(NSString *)lat lng:(NSString *)lng {
    [self.txtRegion setText:region];
    [self.dataParam setObject:regionId forKey:@"RegionID"];
    [self.dataParam setObject:lat forKey:@"Lat"];
    [self.dataParam setObject:lng forKey:@"Lng"];
    [self.dataParam setObject:address forKey:@"Address"];
    [self genSalaryJobString];
}

- (void)JobPushViewConfirm:(NSString *)pushId push:(NSString *)push {
    [self.txtPush setText:push];
    [self.dataParam setObject:pushId forKey:@"strEMailSendFreq"];
}

- (void)saveClick {
    if (self.txtJobName.text.length == 0) {
        [self.view.window makeToast:@"请输入职位名称"];
        return;
    }
    if (self.txtJobName.text.length < 2) {
        [self.view.window makeToast:@"职位名称不能少于2个字符"];
        return;
    }
    if (self.txtJobType.text.length == 0) {
        [self.view.window makeToast:@"请选择主要职位类别"];
        return;
    }
    if (self.txtNeedNumber.text.length == 0) {
        [self.view.window makeToast:@"请选择招聘人数"];
        return;
    }
    if (self.txtEmployType.text.length == 0) {
        [self.view.window makeToast:@"请选择招聘方式"];
        return;
    }
    if (self.txtRegion.text.length == 0) {
        [self.view.window makeToast:@"请选择工作地点"];
        return;
    }
    if (self.txtIssueEnd.text.length == 0) {
        [self.view.window makeToast:@"请选择截止日期"];
        return;
    }
    if (self.txtDegree.text.length == 0) {
        [self.view.window makeToast:@"请选择最低学历"];
        return;
    }
    if (self.txtWorkYears.text.length == 0) {
        [self.view.window makeToast:@"请选择相关工作经验"];
        return;
    }
    if (self.txtAge.text.length == 0) {
        [self.view.window makeToast:@"请选择年龄要求"];
        return;
    }
    if (self.txtResponsibility.text.length == 0) {
        [self.view.window makeToast:@"请输入岗位职责"];
        return;
    }
    if (self.txtDemand.text.length == 0) {
        [self.view.window makeToast:@"请输入岗位要求"];
        return;
    }
    if (self.txtSalary.text.length == 0) {
        [self.view.window makeToast:@"请选择月薪范围"];
        return;
    }
    [self.dataParam setObject:self.txtJobName.text forKey:@"strJobName"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"SaveJobInfo" Params:self.dataParam viewController:self];
    [request setTag:3];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (NSString *)getString:(NSString *)s {
    if (s == nil) {
        s = @"";
    }
    return s;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - 处理福利待遇数据
- (void)dealWelfare:(NSArray *)requestData{
    
    if(requestData.count == 1){
        
        NSDictionary *dict = [requestData firstObject];
        NSDictionary *welfareDict = [Common welfare:dict];
        self.welfareDict = [NSDictionary dictionaryWithDictionary:welfareDict];
        [self fillWelfare];
    }else if(requestData.count == 2){
        NSDictionary *dict1 = [requestData firstObject];
        NSDictionary *dict2 = [requestData lastObject];
        NSDictionary *welfareDict = [Common welfare:dict1 dict2:dict2];
        self.welfareDict = [NSDictionary dictionaryWithDictionary:welfareDict];
        [self fillWelfare];
    }else if (requestData.count == 0){
        // 没有设置福利待遇
        self.welfareDict = nil;
    }
}

#pragma mark - 自动填写福利待遇信息
- (void)fillWelfare{
    if (self.welfareDict) {
        NSString *welfareStr = [Common getWelfareIdSelected:self.welfareDict];
        [self.dataParam setObject:welfareStr forKey:@"Welfare"];
        NSArray *welfareArr = [welfareStr componentsSeparatedByString:@","];
        self.txtWelfare.text = [Common getWelfare:welfareArr];
    }
}

#pragma mark - 获取平均工资
- (void)genSalaryJobString{
    
    NSString *reginStr = self.dataParam[@"RegionID"];
    NSString *jobTypeIdStr = self.dataParam[@"JobTypeID"];
    if (reginStr == nil || jobTypeIdStr == nil) {
        return;
    }
    NSDictionary *paramDict = @{@"RegionID":reginStr,@"JobTypeID":jobTypeIdStr};
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETSALARYJOBSTRING tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}
@end
