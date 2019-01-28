//
//  IntentionModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/10.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "IntentionModifyViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "MultiSelectViewController.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"

@interface IntentionModifyViewController ()<MultiSelectDelegate, NetWebServiceRequestDelegate, WKPopViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@end

@implementation IntentionModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"求职意向";
    [Common changeFontSize:self.view];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveJobIntention)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    [self fillData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)fillData {
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [self.dataCv objectForKey:@"ID"], @"cvMainId", ([[self.dataPa objectForKey:@"dcCareerStatus"] length] > 0 ? [self.dataPa objectForKey:@"dcCareerStatus"] : @""), @"careerStatus", [self.dataJobIntention objectForKey:@"RelatedWorkYears"], @"workYears", [self.dataJobIntention objectForKey:@"EmployType"], @"employType", [self.dataJobIntention objectForKey:@"dcSalaryID"], @"salary", [self.dataJobIntention objectForKey:@"JobType"], @"jobType", [self.dataJobIntention objectForKey:@"JobPlace"], @"jobPlace", [self.dataJobIntention objectForKey:@"Industry"], @"industry", [self.dataPa objectForKey:@"IsNegotiable"], @"negotiable", nil];
    
    [self.btnCareerStatus setTitle:[self.dataPa objectForKey:@"CareerStatus"] forState:UIControlStateNormal];
    NSString *workYears = @"";
    if ([[self.dataJobIntention objectForKey:@"RelatedWorkYears"] isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([[self.dataJobIntention objectForKey:@"RelatedWorkYears"] isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([[self.dataJobIntention objectForKey:@"RelatedWorkYears"] length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", [self.dataJobIntention objectForKey:@"RelatedWorkYears"]];
    }
    [self.btnWorkYears setTitle:workYears forState:UIControlStateNormal];
    [self.btnEmployType setTitle:[self.dataCv objectForKey:@"EmployTypeName"] forState:UIControlStateNormal];
    NSString *salary = @"";
    if ([[self.dataJobIntention objectForKey:@"Salary"] length] > 0) {
        salary = [NSString stringWithFormat:@"%@ %@", [self.dataJobIntention objectForKey:@"Salary"], ([[self.dataJobIntention objectForKey:@"IsNegotiable"] boolValue] ? @"可面议" : @"不可面议")];
    }
    [self.btnSalary setTitle:salary forState:UIControlStateNormal];
    [self.btnJobPlace setTitle:[self.dataJobIntention objectForKey:@"JobPlaceName"] forState:UIControlStateNormal];
    [self.btnJobType setTitle:[self.dataJobIntention objectForKey:@"JobTypeName"] forState:UIControlStateNormal];
    [self.btnIndustry setTitle:[self.dataJobIntention objectForKey:@"IndustryName"] forState:UIControlStateNormal];
}

- (IBAction)careerStatusClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCareerStatus value:[self.dataParam objectForKey:@"careerStatus"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)workYearsClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRelationWorkYears value:[self.dataParam objectForKey:@"workYears"]];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)employTypeClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeEmployType value:[self.dataParam objectForKey:@"employType"]];
    [popView setTag:2];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)salaryClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSalary value:[self.dataParam objectForKey:@"salary"]];
    [popView setTag:3];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)jobPlaceClick:(UIButton *)sender {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    multiSelectCtrl.selId = [self.dataParam objectForKey:@"jobPlace"];
    multiSelectCtrl.selValue = self.btnJobPlace.titleLabel.text;
    multiSelectCtrl.selectType = MultiSelectTypeRegion;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (IBAction)jobTypeClick:(UIButton *)sender {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    multiSelectCtrl.selId = [self.dataParam objectForKey:@"jobType"];
    multiSelectCtrl.selValue = self.btnJobType.titleLabel.text;
    multiSelectCtrl.selectType = MultiSelectTypeJobType;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (IBAction)industryClick:(UIButton *)sender {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    multiSelectCtrl.selId = [self.dataParam objectForKey:@"industry"];
    multiSelectCtrl.selValue = self.btnIndustry.titleLabel.text;
    multiSelectCtrl.selectType = MultiSelectTypeIndustry;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)saveJobIntention {
    if ([[self.dataParam valueForKey:@"careerStatus"] length] == 0) {
        [self.view makeToast:@"请选择求职状态"];
        return;
    }
    if ([[self.dataParam valueForKey:@"workYears"] length] == 0) {
        [self.view makeToast:@"请选择相关工作经验"];
        return;
    }
    if ([[self.dataParam valueForKey:@"employType"] length] == 0) {
        [self.view makeToast:@"请选择期望工作性质"];
        return;
    }
    if ([[self.dataParam valueForKey:@"salary"] length] == 0) {
        [self.view makeToast:@"请选择期望月薪"];
        return;
    }
    if ([[self.dataParam valueForKey:@"jobPlace"] length] == 0) {
        [self.view makeToast:@"请选择期望工作地点"];
        return;
    }
    if ([[self.dataParam valueForKey:@"jobType"] length] == 0) {
        [self.view makeToast:@"请选择期望职位类别"];
        return;
    }
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ModifyJobIntention" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect {
    NSLog(@"%@", arraySelect);
    if (selectType == MultiSelectTypeRegion) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"jobPlace"];
        [self.btnJobPlace setTitle:[arraySelect objectAtIndex:1] forState:UIControlStateNormal];
    }
    else if (selectType == MultiSelectTypeJobType) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"jobType"];
        [self.btnJobType setTitle:[arraySelect objectAtIndex:1] forState:UIControlStateNormal];
    }
    else if (selectType == MultiSelectTypeIndustry) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"industry"];
        [self.btnIndustry setTitle:[arraySelect objectAtIndex:1] forState:UIControlStateNormal];
    }
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    if (popView.tag == 0) { //求职状态
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"careerStatus"];
        [self.btnCareerStatus setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 1) { //相关工作经验
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"workYears"];
        [self.btnWorkYears setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 2) { //期望工作性质
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"employType"];
        [self.btnEmployType setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 3) { //期望月薪
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"salary"];
        NSDictionary *dataNegotiable = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[dataNegotiable objectForKey:@"id"] forKey:@"negotiable"];
        [self.btnSalary setTitle:[NSString stringWithFormat:@"%@ %@", [data objectForKey:@"value"], ([[dataNegotiable objectForKey:@"id"] isEqualToString:@"0"] ? @"不可面议" : @"可面议")] forState:UIControlStateNormal];
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.navigationController popViewControllerAnimated:NO];
    [self.delegate intentionModifySuccess];
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
