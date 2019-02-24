//
//  CpModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  企业基本信息页面

#import "CpModifyViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "MultiSelectViewController.h"
#import "JobPlaceViewController.h"
#import "CpBriefViewController.h"

@interface CpModifyViewController ()<WKPopViewDelegate, NetWebServiceRequestDelegate, UITextFieldDelegate, MultiSelectDelegate, JobPlaceViewDelegate, CpBriefViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) UITextField *currentTextField;
@end

@implementation CpModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业基本信息";
    [Common changeFontSize:self.view];
    [self.btnSave.layer setCornerRadius:5];
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainId", CPMAINID, @"cpMainId", CAMAINCODE, @"code", @"", @"companyName", @"", @"industry", @"", @"companyKind", @"", @"companySize", @"", @"regionId", @"", @"address", @"", @"zip", @"", @"homepage", @"", @"brief", @"", @"lat", @"", @"lng", nil];
    [self getData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.forceModify) {
        [self.navigationItem setLeftBarButtonItem:nil];
        [self.navigationItem setHidesBackButton:YES];
    }
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    self.currentTextField = textField;
    if (textField == self.txtCompanyName || textField == self.txtZipCode || textField == self.txtHomepage) {
        return YES;
    }
    if (textField == self.txtIndustry) {
        [self industryClick];
    }
    else if (textField == self.txtCompanyKind) {
        [self kindClick];
    }
    else if (textField == self.txtCompanySize) {
        [self sizeClick];
    }
    else if (textField == self.txtRegion) {
        [self regionClick];
    }
    else if (textField == self.txtBrief) {
        [self briefClick];
    }
    return NO;
}

- (void)industryClick {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    multiSelectCtrl.title = @"所属行业";
    multiSelectCtrl.selId = [self.dataParam objectForKey:@"industry"];
    multiSelectCtrl.selValue = self.txtIndustry.text;
    multiSelectCtrl.selectType = MultiSelectTypeCpIndustry;
    multiSelectCtrl.accountType = MultiSelectAccountTypeCompany;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect {
    if (selectType == MultiSelectTypeCpIndustry) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"industry"];
        [self.txtIndustry setText:[arraySelect objectAtIndex:1]];
    }
}

- (void)kindClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCompanyKind value:[self.dataParam objectForKey:@"companyKind"]];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)sizeClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCompanySize value:[self.dataParam objectForKey:@"companySize"]];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)regionClick {
    JobPlaceViewController *jobPlaceCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"jobPlaceView"];
    jobPlaceCtrl.isCompany = YES;
    jobPlaceCtrl.lat = [self.dataParam objectForKey:@"lat"];
    jobPlaceCtrl.lng = [self.dataParam objectForKey:@"lng"];
    jobPlaceCtrl.region = self.txtRegion.text;
    jobPlaceCtrl.regionId = [self.dataParam objectForKey:@"regionId"];
    jobPlaceCtrl.address = [self.dataParam objectForKey:@"address"];
    [jobPlaceCtrl setDelegate:self];
    [self.navigationController pushViewController:jobPlaceCtrl animated:YES];
}

- (void)briefClick {
    CpBriefViewController *cpBriefCtrl = [[CpBriefViewController alloc] init];
    cpBriefCtrl.brief = self.txtBrief.text;
    [cpBriefCtrl setDelegate:self];
    [self.navigationController pushViewController:cpBriefCtrl animated:YES];
}

- (IBAction)saveClick:(UIButton *)sender {
    [self.dataParam setObject:self.txtCompanyName.text forKey:@"companyName"];
    [self.dataParam setObject:self.txtZipCode.text forKey:@"zip"];
    [self.dataParam setObject:self.txtHomepage.text forKey:@"homepage"];
    
    if ([[self.dataParam objectForKey:@"companyName"] length] == 0) {
        [self.view makeToast:@"请填写企业名称"];
        return;
    }
    if ([[self.dataParam objectForKey:@"industry"] length] == 0) {
        [self.view makeToast:@"请选择所属行业"];
        return;
    }
    if ([[self.dataParam objectForKey:@"companyKind"] length] == 0) {
        [self.view makeToast:@"请选择企业性质"];
        return;
    }
    if ([[self.dataParam objectForKey:@"companySize"] length] == 0) {
        [self.view makeToast:@"请选择企业规模"];
        return;
    }
    if ([[self.dataParam objectForKey:@"zip"] length] > 0) {
        if ([[self.dataParam objectForKey:@"zip"] length] != 6) {
            [self.view makeToast:@"请填写正确的邮政编码"];
            return;
        }
        else if (![Common isPureInt:[self.dataParam objectForKey:@"zip"]]) {
            [self.view makeToast:@"请填写正确的邮政编码"];
            return;
        }
    }
    if ([[self.dataParam objectForKey:@"homepage"] length] > 50) {
        [self.view makeToast:@"企业主页不能超过50个字符"];
        return;
    }
    if ([[self.dataParam objectForKey:@"regionId"] length] == 0 || [[self.dataParam objectForKey:@"regionId"] length] == 2) {
        [self.view makeToast:@"请选择详细的企业所在地区"];
        return;
    }
    if (self.txtBrief.text.length == 0) {
        [self.view makeToast:@"请填写企业简介"];
        return;
    }
    [self.dataParam setObject:self.txtBrief.text forKey:@"brief"];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"SaveCpMainInfo" Params:self.dataParam viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCpMain = [Common getArrayFromXml:requestData tableName:@"TableCp"];
        NSDictionary *companyData = [arrayCpMain objectAtIndex:0];
        
        if ([[companyData objectForKey:@"MemberType"] integerValue] > 1) {
            [self.lbCompanyName setText:@"企业名称（您的企业已认证）"];
            [self.txtCompanyName setEnabled:NO];
        }
        [self.txtCompanyName setText:[companyData objectForKey:@"Name"]];
        [self.txtZipCode setText:[companyData objectForKey:@"Zip"]];
        [self.txtHomepage setText:[companyData objectForKey:@"HomePage"]];
        if (self.txtHomepage.text.length == 0) {
            [self.txtHomepage setText:@"http://"];
        }
        else if ([self.txtHomepage.text rangeOfString:@"http://"].location == NSNotFound) {
            [self.txtHomepage setText:[NSString stringWithFormat:@"http://%@", [companyData objectForKey:@"HomePage"]]];
        }
        
        [self.txtIndustry setText:[companyData objectForKey:@"Industry"]];
        [self.txtCompanyKind setText:[companyData objectForKey:@"CompanyKind"]];
        [self.txtCompanySize setText:[companyData objectForKey:@"CompanySize"]];
        [self.txtRegion setText:[companyData objectForKey:@"Region"]];
        [self.txtBrief setText:[companyData objectForKey:@"Brief"]];
        
        if ([[companyData objectForKey:@"dcIndustryID"] length] > 0) {
            [self.dataParam setObject:[[companyData objectForKey:@"dcIndustryID"] stringByReplacingOccurrencesOfString:@"," withString:@" "] forKey:@"industry"];
            [self.dataParam setObject:[companyData objectForKey:@"dcCompanyKindID"] forKey:@"companyKind"];
            [self.dataParam setObject:[companyData objectForKey:@"dcCompanySizeID"] forKey:@"companySize"];
            [self.dataParam setObject:[companyData objectForKey:@"dcRegionID"] forKey:@"regionId"];
            [self.dataParam setObject:[companyData objectForKey:@"Lng"] forKey:@"lng"];
            [self.dataParam setObject:[companyData objectForKey:@"Lat"] forKey:@"lat"];
            [self.dataParam setObject:[companyData objectForKey:@"Address"] forKey:@"address"];
        }
    }
    else if (request.tag == 2) {
        if ([result isEqualToString:@"1"]) {
            [self.view.window makeToast:@"企业基本信息修改成功"];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if ([result isEqualToString:@"-99"]) {
            [self.view makeToast:@"企业名称重复，无法修改"];
        }
        else {
            [self.view makeToast:@"企业基本信息修改失败，请稍后再试"];
        }
    }
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    if (popView.tag == 0) {
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"companyKind"];
        [self.txtCompanyKind setText:[data objectForKey:@"value"]];
    }
    else if (popView.tag == 1) {
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"companySize"];
        [self.txtCompanySize setText:[data objectForKey:@"value"]];
    }
    else if (popView.tag == 2) {
        NSDictionary *data = [arraySelect objectAtIndex:arraySelect.count - 1];
        NSMutableString *stringRegion = [[NSMutableString alloc] init];
        for (NSDictionary *region in arraySelect) {
            [stringRegion appendString:[region objectForKey:@"value"]];
        }
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"regionId"];
        [self.txtRegion setText:stringRegion];
    }
}

- (void)JobPlaceViewConfirm:(NSString *)region regionId:(NSString *)regionId address:(NSString *)address lat:(NSString *)lat lng:(NSString *)lng {
    [self.txtRegion setText:region];
    [self.dataParam setValue:regionId forKey:@"regionId"];
    [self.dataParam setValue:address forKey:@"address"];
    [self.dataParam setValue:lat forKey:@"lat"];
    [self.dataParam setValue:lng forKey:@"lng"];
}

- (void)CpBriefViewConfirm:(NSString *)brief {
    [self.txtBrief setText:brief];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textField convertRect:textField.bounds toView:window];
    float fltBY = rect.origin.y + rect.size.height;
    if (SCREEN_HEIGHT - fltBY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = self.view.frame;
            frameView.origin.y = SCREEN_HEIGHT - fltBY - KEYBOARD_HEIGHT;
            [self.view setFrame:frameView];
        }];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
    return YES;
}

@end
