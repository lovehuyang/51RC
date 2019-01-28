//
//  EducationModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/11.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "EducationModifyViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "MajorViewController.h"
#import "LongVoiceInputController.h"

@interface EducationModifyViewController ()<WKPopViewDelegate, MajorViewDelete, NetWebServiceRequestDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@end

@implementation EducationModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"教育背景";
    [Common changeFontSize:self.view];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveEducation)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    [self.txtDetail.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [self.txtDetail.layer setBorderWidth:1];
    [self.txtDetail.layer setCornerRadius:5];
    [self.btnDelete setBackgroundColor:UIColorWithRGBA(182, 182, 182, 1)];
    UIButton *speakBtn = [UIButton new];
    [speakBtn setImage:[UIImage imageNamed:@"huatong"] forState:UIControlStateNormal];
    [speakBtn setTitle:@"不喜欢打字，我要语音填写" forState:UIControlStateNormal];
    [self.bgView addSubview:speakBtn];
    speakBtn.sd_layout
    .leftSpaceToView(self.bgView, 20)
    .rightSpaceToView(self.bgView, 20)
    .topSpaceToView(self.txtDetail, 0)
    .heightIs(30);
    speakBtn.titleLabel.font = DEFAULTFONT;
    [speakBtn setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
    speakBtn.layer.cornerRadius = 5;
    speakBtn.layer.borderWidth = 1;
    speakBtn.layer.borderColor = SEPARATECOLOR.CGColor;
    [speakBtn addTarget:self action:@selector(speakBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", @"0", @"educationId", @"", @"college", @"", @"graduation", @"", @"majorId", @"", @"majorName", @"", @"degree", @"", @"eduType", @"", @"details", nil];
    
    if (self.dataEducation == nil) {
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
    [self.dataParam setValue:[self.dataEducation objectForKey:@"ID"] forKey:@"educationId"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"GraduateCollage"] forKey:@"college"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"Details"] forKey:@"details"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"MajorName"] forKey:@"majorName"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"Graduation"] forKey:@"graduation"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"Degree"] forKey:@"degree"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"EduType"] forKey:@"eduType"];
    [self.dataParam setValue:[self.dataEducation objectForKey:@"dcMajorID"] forKey:@"majorId"];
    
    [self.txtCollege setText:[self.dataEducation objectForKey:@"GraduateCollage"]];
    [self.txtDetail setText:[self.dataEducation objectForKey:@"Details"]];
    [self.btnMajorName setTitle:[self.dataEducation objectForKey:@"MajorName"] forState:UIControlStateNormal];
    [self.btnGraduation setTitle:[NSString stringWithFormat:@"%@年%@月", [[self.dataEducation objectForKey:@"Graduation"] substringToIndex:4], [[self.dataEducation objectForKey:@"Graduation"] substringFromIndex:4]] forState:UIControlStateNormal];
    [self.btnDegree setTitle:[self.dataEducation objectForKey:@"DegreeName"] forState:UIControlStateNormal];
    [self.btnEduType setTitle:[self.dataEducation objectForKey:@"EduTypeName"] forState:UIControlStateNormal];
    [self.btnMajor setTitle:[self.dataEducation objectForKey:@"Major"] forState:UIControlStateNormal];
}

- (void)saveEducation {
    [self.view endEditing:YES];
    if (self.txtCollege.text.length == 0) {
        [self.view makeToast:@"请填写学校名称"];
        return;
    }
    if (self.txtCollege.text.length > 50) {
        [self.view makeToast:@"学校名称不能超过50个字"];
        return;
    }
    if ([[self.dataParam valueForKey:@"graduation"] length] == 0) {
        [self.view makeToast:@"请选择毕业时间"];
        return;
    }
    if ([[self.dataParam valueForKey:@"degree"] length] == 0) {
        [self.view makeToast:@"请选择学历"];
        return;
    }
    if ([[self.dataParam valueForKey:@"eduType"] length] == 0) {
        [self.view makeToast:@"请选择学历类型"];
        return;
    }
    if ([[self.dataParam valueForKey:@"majorId"] length] == 0) {
        [self.view makeToast:@"请选择专业"];
        return;
    }
    if ([[self.dataParam valueForKey:@"majorName"] length] == 0) {
        [self.view makeToast:@"请输入专业名称"];
        return;
    }
    [self.dataParam setValue:self.txtCollege.text forKey:@"college"];
    [self.dataParam setValue:self.txtDetail.text forKey:@"details"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ModifyEducation" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)graduationClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeGraduation value:[self.dataParam objectForKey:@"graduation"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)degreeClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeDegree value:[self.dataParam objectForKey:@"degree"]];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)eduTypeClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeEduType value:[self.dataParam objectForKey:@"eduType"]];
    [popView setTag:2];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)majorClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeMajor value:[self.dataParam objectForKey:@"majorId"]];
    [popView setTag:3];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)majorNameClick:(UIButton *)sender {
    [self.view endEditing:YES];
    MajorViewController *majorCtrl = [[MajorViewController alloc] init];
    [majorCtrl setDelegate:self];
    [self.navigationController pushViewController:majorCtrl animated:YES];
}

- (IBAction)educationDelete:(WKButton *)sender {
    [self.view endEditing:YES];
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"确定要删除该教育背景吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteEducation" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [self.dataEducation objectForKey:@"ID"], @"educationId", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertDelete animated:YES completion:nil];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    if (popView.tag == 0) { //毕业时间
        NSDictionary *dataYear = [arraySelect objectAtIndex:0];
        NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"graduation"];
        [self.btnGraduation setTitle:[NSString stringWithFormat:@"%@%@", [dataYear objectForKey:@"value"], [dataMonth objectForKey:@"value"]] forState:UIControlStateNormal];
    }
    else if (popView.tag == 1) { //学历
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"degree"];
        [self.btnDegree setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
        
        if ([[data objectForKey:@"id"] isEqualToString:@"1"] || [[data objectForKey:@"id"] isEqualToString:@"2"]) {
            
            [self.dataParam setValue:@"1" forKey:@"eduType"];
            [self.btnEduType setTitle:@"统招" forState:UIControlStateNormal];
            
            [self.dataParam setValue:@"1106" forKey:@"majorId"];
            [self.btnMajor setTitle:@"未划分专业" forState:UIControlStateNormal];
            
            [self.dataParam setValue:@"无" forKey:@"majorName"];
            [self.btnMajorName setTitle:@"无" forState:UIControlStateNormal];
        }
    }
    else if (popView.tag == 2) { //学历类型
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"eduType"];
        [self.btnEduType setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 3) { //专业
        NSDictionary *data = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"majorId"];
        [self.btnMajor setTitle:[data objectForKey:@"value"] forState:UIControlStateNormal];
    }
}

- (void)majorViewClick:(NSDictionary *)major {
    [self.dataParam setValue:[major objectForKey:@"MajorName"] forKey:@"majorName"];
    [self.btnMajorName setTitle:[major objectForKey:@"MajorName"] forState:UIControlStateNormal];
    if ([[major objectForKey:@"dcMajorId"] length] > 0) {
        [self.dataParam setValue:[major objectForKey:@"dcMajorId"] forKey:@"majorId"];
        [self.btnMajor setTitle:[major objectForKey:@"Major"] forState:UIControlStateNormal];
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
    lvc.title = @"学习经历";
    lvc.detail = self.txtDetail.text;
    lvc.tipStr = @"例如：\n在校期间认真学习专业知识，综合成绩名列前**。\n积极参加学生会组织，加入**部，主要责任：**。\n各方面表现优异，曾获得教学金**次。\n在校期间品学兼优，曾获得**荣誉称号。";
    lvc.detailContent = ^(NSString *inputStr) {
        self.txtDetail.text = inputStr;
    };
    [self.navigationController pushViewController:lvc animated:YES];
}

@end
