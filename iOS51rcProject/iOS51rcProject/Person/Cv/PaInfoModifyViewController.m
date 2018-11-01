//
//  PaInfoModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/10.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "PaInfoModifyViewController.h"
#import "NetWebServiceRequest.h"
#import "CommonMacro.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "WKPopView.h"
#import "AccountManagerViewController.h"

@interface PaInfoModifyViewController ()<NetWebServiceRequestDelegate, UITextFieldDelegate, WKPopViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) UITextField *activeTextfield;
@end

@implementation PaInfoModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"基本信息";
    [Common changeFontSize:self.view];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(savePaInfo)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    [self fillData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 添加对键盘的监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [self.runningRequest cancel];
}

- (void)keyBoardWillShow:(NSNotification *)note {
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (self.activeTextfield) {
        if (SCREEN_HEIGHT - VIEW_BY(self.activeTextfield) < keyBoardHeight) {
            [UIView animateWithDuration:animationTime animations:^{
                CGRect frameView = self.view.frame;
                frameView.origin.y = SCREEN_HEIGHT - VIEW_BY(self.activeTextfield) - keyBoardHeight;
                [self.view setFrame:frameView];
            }];
        }
    }
}

- (void)keyBoardWillHide:(NSNotification *) note {
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationTime animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
}

- (void)fillData {
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [self.dataCv objectForKey:@"ID"], @"cvMainId", ([[self.dataPa objectForKey:@"Gender"] length] == 0 ? @"" : ([[self.dataPa objectForKey:@"Gender"] boolValue] ? @"1" : @"0")), @"gender", [self.dataPa objectForKey:@"BirthDay"], @"birth", [self.dataPa objectForKey:@"LivePlace"], @"livePlace", [self.dataPa objectForKey:@"AccountPlace"], @"accountPlace", [self.dataPa objectForKey:@"GrowPlace"], @"growPlace", [self.dataPa objectForKey:@"Name"], @"name", [self.dataPa objectForKey:@"Mobile"], @"mobile", nil];

    NSString *gender, *birth;
    if ([[self.dataPa objectForKey:@"LivePlace"] length] > 0) {
        gender = ([[self.dataPa objectForKey:@"Gender"] boolValue] ? @"女" : @"男");
        birth = [NSString stringWithFormat:@"%@年%@月", [[self.dataPa objectForKey:@"BirthDay"] substringToIndex:4], [[self.dataPa objectForKey:@"BirthDay"] substringFromIndex:4]];
    }
    else {
        gender = @"";
        birth = @"";
    }
    [self.txtName setText:[self.dataPa objectForKey:@"Name"]];
    [self.btnGender setTitle:gender forState:UIControlStateNormal];
    [self.btnBirth setTitle:birth forState:UIControlStateNormal];
    [self.btnLivePlace setTitle:[self.dataPa objectForKey:@"LiveRegion"] forState:UIControlStateNormal];
    [self.btnAccountPlace setTitle:[self.dataPa objectForKey:@"AccountRegion"] forState:UIControlStateNormal];
    [self.btnGrowPlace setTitle:[self.dataPa objectForKey:@"GrowRegion"] forState:UIControlStateNormal];
    [self.txtMobile setText:[self.dataPa objectForKey:@"Mobile"]];
    [self.txtEmail setText:[self.dataPa objectForKey:@"Email"]];
}

- (IBAction)genderClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeGender value:[self.dataParam objectForKey:@"gender"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)birthClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeBirth value:[self.dataParam objectForKey:@"birth"]];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)livePlaceClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL3 value:[self.dataParam objectForKey:@"livePlace"]];
    [popView setTag:2];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)accountPlaceClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL2 value:[self.dataParam objectForKey:@"accountPlace"]];
    [popView setTag:3];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)growPlaceClick:(UIButton *)sender {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL2 value:[self.dataParam objectForKey:@"growPlace"]];
    [popView setTag:4];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (IBAction)userNameModifyClick:(UIButton *)sender {
    [self.view endEditing:YES];
    AccountManagerViewController *accountCtrl = [[AccountManagerViewController alloc] init];
    accountCtrl.url = @"/personal/sys/username";
    accountCtrl.title = @"修改用户名";
    [self.navigationController pushViewController:accountCtrl animated:YES];
}

- (void)savePaInfo {
    [self.view endEditing:YES];
    if (self.txtName.text.length == 0) {
        [self.view makeToast:@"请填写姓名"];
        return;
    }
    if (self.txtName.text.length == 1) {
        [self.view makeToast:@"姓名不能少于1个字"];
        return;
    }
    if (self.txtName.text.length > 6) {
        [self.view makeToast:@"姓名不能超过6个字"];
        return;
    }
    if (![Common isPureChinese:self.txtName.text]) {
        [self.view makeToast:@"请填写中文姓名"];
        return;
    }
    if ([[self.dataParam valueForKey:@"gender"] length] == 0) {
        [self.view makeToast:@"请选择性别"];
        return;
    }
    if ([[self.dataParam valueForKey:@"birth"] length] == 0) {
        [self.view makeToast:@"请选择出生年月"];
        return;
    }
    if ([[self.dataParam valueForKey:@"livePlace"] length] == 0) {
        [self.view makeToast:@"请选择现居住地"];
        return;
    }
    if ([[self.dataParam valueForKey:@"accountPlace"] length] == 0) {
        [self.view makeToast:@"请选择户口所在地"];
        return;
    }
    if ([[self.dataParam valueForKey:@"growPlace"] length] == 0) {
        [self.view makeToast:@"请选择我成长在"];
        return;
    }
    if (![Common checkMobile:self.txtMobile.text]) {
        [self.view makeToast:@"请填写正确的手机号"];
        return;
    }
    [self.dataParam setValue:self.txtName.text forKey:@"name"];
    [self.dataParam setValue:self.txtMobile.text forKey:@"mobile"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ModifyPaInfo" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    if (popView.tag == 0) { //性别
        NSDictionary *dataGender = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[dataGender objectForKey:@"id"] forKey:@"gender"];
        [self.btnGender setTitle:[dataGender objectForKey:@"value"] forState:UIControlStateNormal];
    }
    else if (popView.tag == 1) { //出生年月
        NSDictionary *dataYear = [arraySelect objectAtIndex:0];
        NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"birth"];
        [self.btnBirth setTitle:[NSString stringWithFormat:@"%@%@", [dataYear objectForKey:@"value"], [dataMonth objectForKey:@"value"]] forState:UIControlStateNormal];
    }
    else {
        NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
        if (popView.tag == 2) { //现居住地
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"livePlace"];
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"accountPlace"];
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"growPlace"];
            [self.btnLivePlace setTitle:[dataRegion objectForKey:@"value"] forState:UIControlStateNormal];
            [self.btnAccountPlace setTitle:[dataRegion objectForKey:@"value"] forState:UIControlStateNormal];
            [self.btnGrowPlace setTitle:[dataRegion objectForKey:@"value"] forState:UIControlStateNormal];
        }
        else if (popView.tag == 3) { //户口所在地
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"accountPlace"];
            [self.btnAccountPlace setTitle:[dataRegion objectForKey:@"value"] forState:UIControlStateNormal];
        }
        else if (popView.tag == 4) { //我成长在
            [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"growPlace"];
            [self.btnGrowPlace setTitle:[dataRegion objectForKey:@"value"] forState:UIControlStateNormal];
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    self.activeTextfield = textField;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if ([result isEqualToString:@"0"]) {
        [self.view makeToast:@"基本信息修改失败，请稍后再试"];
    }
    else if ([result isEqualToString:@"-1"]) {
        [self.view makeToast:@"基本信息修改失败，可能是您的手机号在我们黑名单"];
    }
    else {
        [self.navigationController popViewControllerAnimated:NO];
        [self.delegate paInfoModifySuccess];
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
