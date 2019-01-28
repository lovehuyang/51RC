//
//  ExperienceModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/11.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ExperienceModifyViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "LongVoiceInputController.h"

@interface ExperienceModifyViewController ()<WKPopViewDelegate, NetWebServiceRequestDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@end

@implementation ExperienceModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"工作经历";
    [self.constraintScrollWidth setConstant:(SCREEN_WIDTH - 85)];
    [Common changeFontSize:self.view];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveExperience)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    [self.txtDetail.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.txtDetail.layer setBorderWidth:1];
    [self.txtDetail.layer setCornerRadius:5];
    [self.btnDelete setBackgroundColor:UIColorWithRGBA(182, 182, 182, 1)];
    UIButton *speakBtn = [UIButton new];
    speakBtn.frame = CGRectMake(VIEW_X(self.txtDetail), VIEW_BY(self.txtDetail), SCREEN_WIDTH - VIEW_X(self.txtDetail) * 2, 30);
    [speakBtn setImage:[UIImage imageNamed:@"huatong"] forState:UIControlStateNormal];
    [speakBtn setTitle:@"不喜欢打字，我要语音填写" forState:UIControlStateNormal];
    [self.scrollView addSubview:speakBtn];
    speakBtn.titleLabel.font = DEFAULTFONT;
    [speakBtn setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    speakBtn.layer.cornerRadius = 5;
    speakBtn.layer.borderWidth = 1;
    speakBtn.layer.borderColor = SEPARATECOLOR.CGColor;
    [speakBtn addTarget:self action:@selector(speakBtnClick) forControlEvents:UIControlEventTouchUpInside];

    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", @"0", @"experienceId", @"", @"companyName", @"", @"industryId", @"", @"companySizeId", @"", @"jobTypeId", @"", @"jobName", @"", @"beginDate", @"", @"endDate", @"", @"subNodeNum", @"", @"description", nil];
    
    if (self.dataExperience == nil) {
        [self.btnDelete setHidden:YES];
    }
    else {
        [self fillData];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)fillData {
    [self.dataParam setValue:[self.dataExperience objectForKey:@"ID"] forKey:@"experienceId"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"CompanyName"] forKey:@"companyName"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"dcIndustryID"] forKey:@"industryId"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"dcCompanySizeID"] forKey:@"companySizeId"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"dcJobtypeID"] forKey:@"jobTypeId"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"JobName"] forKey:@"jobName"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"BeginDate"] forKey:@"beginDate"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"EndDate"] forKey:@"endDate"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"SubNodeNum"] forKey:@"subNodeNum"];
    [self.dataParam setValue:[self.dataExperience objectForKey:@"Description"] forKey:@"description"];
    
    [self.txtCompanyName setText:[self.dataExperience objectForKey:@"CompanyName"]];
    [self.txtJobName setText:[self.dataExperience objectForKey:@"JobName"]];
    [self.txtDetail setText:[self.dataExperience objectForKey:@"Description"]];
    [self.btnIndustry setTitle:[self.dataExperience objectForKey:@"Industry"] forState:UIControlStateNormal];
    [self.btnCompanySize setTitle:[self.dataExperience objectForKey:@"CpmpanySize"] forState:UIControlStateNormal];
    [self.btnJobType setTitle:[self.dataExperience objectForKey:@"JobType"] forState:UIControlStateNormal];
    [self.btnLowerNumber setTitle:[self.dataExperience objectForKey:@"LowerNumber"] forState:UIControlStateNormal];
    [self.btnBeginDate setTitle:[NSString stringWithFormat:@"%@年%@月", [[self.dataExperience objectForKey:@"BeginDate"] substringToIndex:4], [[self.dataExperience objectForKey:@"BeginDate"] substringFromIndex:4]] forState:UIControlStateNormal];
    if ([[self.dataExperience objectForKey:@"EndDate"] isEqualToString:@"999999"]) {
        [self.btnEndDate setTitle:@"至今" forState:UIControlStateNormal];
    }
    else {
        [self.btnEndDate setTitle:[NSString stringWithFormat:@"%@年%@月", [[self.dataExperience objectForKey:@"EndDate"] substringToIndex:4], [[self.dataExperience objectForKey:@"EndDate"] substringFromIndex:4]] forState:UIControlStateNormal];
    }
}

- (void)saveExperience {
    [self.view endEditing:YES];
    if (self.txtCompanyName.text.length == 0) {
        [self.view makeToast:@"请填写企业名称"];
        return;
    }
    if (self.txtCompanyName.text.length > 30) {
        [self.view makeToast:@"企业名称不能超过30个字"];
        return;
    }
    if ([[self.dataParam valueForKey:@"industryId"] length] == 0) {
        [self.view makeToast:@"请选择所属行业"];
        return;
    }
    if ([[self.dataParam valueForKey:@"companySizeId"] length] == 0) {
        [self.view makeToast:@"请选择企业规模"];
        return;
    }
    if (self.txtJobName.text.length == 0) {
        [self.view makeToast:@"请输入职位名称"];
        return;
    }
    if (self.txtJobName.text.length > 20) {
        [self.view makeToast:@"职位名称不能超过20个字"];
        return;
    }
    if ([[self.dataParam valueForKey:@"jobTypeId"] length] == 0) {
        [self.view makeToast:@"请选择职位类别"];
        return;
    }
    if ([[self.dataParam valueForKey:@"subNodeNum"] length] == 0) {
        [self.view makeToast:@"请选择下属人数"];
        return;
    }
    if ([[self.dataParam valueForKey:@"beginDate"] length] == 0) {
        [self.view makeToast:@"请选择入职时间"];
        return;
    }
    if ([[self.dataParam valueForKey:@"endDate"] length] == 0) {
        [self.view makeToast:@"请选择离职时间"];
        return;
    }
    if ([[self.dataParam valueForKey:@"beginDate"] integerValue] > [[self.dataParam valueForKey:@"endDate"] integerValue]) {
        [self.view makeToast:@"入职时间不能大于离职时间"];
        return;
    }
    if (self.txtDetail.text.length == 0) {
        [self.view makeToast:@"请输入工作描述"];
        return;
    }
    [self.dataParam setValue:self.txtCompanyName.text forKey:@"companyName"];
    [self.dataParam setValue:self.txtJobName.text forKey:@"jobName"];
    [self.dataParam setValue:self.txtDetail.text forKey:@"description"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ModifyExperience" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)industryClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeIndustry value:[self.dataParam objectForKey:@"industryId"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)companySizeClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCompanySize value:[self.dataParam objectForKey:@"companySizeId"]];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)jobTypeClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeJobType value:[self.dataParam objectForKey:@"jobTypeId"]];
    [popView setTag:2];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)lowerNumberClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeLowerNumber value:[self.dataParam objectForKey:@"subNodeNumber"]];
    [popView setTag:3];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)beginDateClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeWorkBeginDate value:[self.dataParam objectForKey:@"beginDate"]];
    [popView setTag:4];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)endDateClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeWorkEndDate value:[self.dataParam objectForKey:@"endDate"]];
    [popView setTag:5];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)experienceDelete:(WKButton *)sender {
    [self.view endEditing:YES];
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"确定要删除该工作经历吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteExperience" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [self.dataExperience objectForKey:@"ID"], @"experienceId", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertDelete animated:YES completion:nil];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    if (popView.tag == 0) { //所属行业
        NSDictionary *data = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"industryId"];
        [self.btnIndustry setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 1) { //企业规模
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"companySizeId"];
        [self.btnCompanySize setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 2) { //职位类别
        NSDictionary *data = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"jobTypeId"];
        [self.btnJobType setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 3) { //下属人数
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"subNodeNum"];
        [self.btnLowerNumber setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 4) { //入职时间
        NSDictionary *dataYear = [arraySelect objectAtIndex:0];
        NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"beginDate"];
        [self.btnBeginDate setTitle:[NSString stringWithFormat:@"%@%@", [dataYear objectForKey:@"value"], [dataMonth objectForKey:@"value"]] forState:UIControlStateNormal];
    }
    else if (popView.tag == 5) { //离职时间
        if (arraySelect.count == 1) {
            [self.dataParam setValue:@"999999" forKey:@"endDate"];
            [self.btnEndDate setTitle:@"至今" forState:UIControlStateNormal];
        }
        else {
            NSDictionary *dataYear = [arraySelect objectAtIndex:0];
            NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
            [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"endDate"];
            [self.btnEndDate setTitle:[NSString stringWithFormat:@"%@%@", [dataYear objectForKey:@"value"], [dataMonth objectForKey:@"value"]] forState:UIControlStateNormal];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textView convertRect:textView.bounds toView:window];
    float fltBY = rect.origin.y + rect.size.height;
    if (SCREEN_HEIGHT - fltBY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = self.view.frame;
            frameView.origin.y = SCREEN_HEIGHT - fltBY - KEYBOARD_HEIGHT;
            [self.view setFrame:frameView];
        }];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
    return YES;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 跳转至语音输入页面
- (void)speakBtnClick{
    LongVoiceInputController *lvc = [LongVoiceInputController new];
    lvc.title = @"工作描述";
    lvc.detail = self.txtDetail.text;
    lvc.tipStr = @"例如：\n日常本职工作都能按时或者提前顺利完成。\n除本职工作以外还能主动协助其他部门完成完成部分工作。\n工作态度积极努力，业绩突出并得到领导及同事的一致好评。多次获得优秀员工等荣誉称号。\n始终保持学习的态度，工作能力提升迅速，未来继续努力，为贵公司创造更多的价值。";
    lvc.detailContent = ^(NSString *inputStr) {
        self.txtDetail.text = inputStr;
    };
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
