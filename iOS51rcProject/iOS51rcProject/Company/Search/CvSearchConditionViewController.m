//
//  CvSearchConditionViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CvSearchConditionViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "MultiSelectViewController.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "CvSearchListViewController.h"

@interface CvSearchConditionViewController ()<UITextFieldDelegate, MultiSelectDelegate, WKPopViewDelegate, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrayJob;
@end

@implementation CvSearchConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSearch.layer setCornerRadius:5];
    self.constraintScrollBottom.constant = TAB_BAR_HEIGHT;
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
              CAMAINID, @"caMainID",
              CAMAINCODE, @"Code",
              CPMAINID, @"cpMainID",
              @"", @"strKeyWord",
              [USER_DEFAULT objectForKey:@"provinceId"], @"strRegionID",
              @"", @"strJobTypeID",
              [USER_DEFAULT objectForKey:@"provinceId"], @"strLivePlace",
              @"", @"strdcIndustryId",
              @"", @"strdcIndustryIDExpect",
              @"", @"strJobTypeExpect",
              @"", @"strCollege",
              @"", @"strMajorName",
              @"", @"strAccount",
              @"", @"strAge",
              @"", @"strHeight",
              @"", @"strMobilePlace",
              @"", @"strSessionId",
              @"1", @"strPageNo",
              @"", @"strCvMainID",
              @"", @"strSalary",
              @"", @"strExperience",
              @"", @"strEducation",
              @"", @"strLanguage",
              @"", @"strSubNodeNum",
              @"", @"strMajor",
              @"", @"strSex",
              @"", @"strGraduation",
              @"", @"strEmployType",
              @"0", @"intJobID", nil];
    
    [self.txtJobPlaceExpect setText:[USER_DEFAULT objectForKey:@"province"]];
    [self.txtLivePlace setText:[USER_DEFAULT objectForKey:@"province"]];
    [self.btnClear.imageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.txtJob setText:@""];
    [self.dataParam setObject:@"0" forKey:@"intJobID"];
    [self getJob];
    [self fillHistory];
}

- (void)getJob {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpJobListByCvSearch" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillHistory {
    for (UIView *view in self.viewHistory.subviews) {
        [view removeFromSuperview];
    }
    NSArray *arrayHistory = [USER_DEFAULT objectForKey:@"cpSearchHistory"];
    if (arrayHistory.count == 0) {
        [self.constraintHistoryHeight setConstant:0];
    }
    else {
        float heightForView = 0;
        for (NSInteger i = 0; i < arrayHistory.count; i++) {
            NSDictionary *data = [arrayHistory objectAtIndex:i];
            UIButton *btnHistory = [[UIButton alloc] initWithFrame:CGRectMake(15, heightForView, VIEW_W(self.viewHistory) - 80, 50)];
            [btnHistory setTag:i];
            [btnHistory addTarget:self action:@selector(historyClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewHistory addSubview:btnHistory];
            
            UIImageView *imgHistory = [[UIImageView alloc] initWithFrame:CGRectMake(0, 15, 20, 20)];
            [imgHistory setImage:[UIImage imageNamed:@"job_history"]];
            [btnHistory addSubview:imgHistory];
            
            WKLabel *lbHistory = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgHistory) + 5, 0, VIEW_W(btnHistory) - VIEW_BX(imgHistory) - 5, VIEW_H(btnHistory)) content:[data objectForKey:@"text"] size:DEFAULTFONTSIZE color:nil];
            [btnHistory addSubview:lbHistory];
            
            UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(self.viewHistory) - 65, VIEW_Y(btnHistory), 50, VIEW_H(btnHistory))];
            [btnDel setTag:i];
            [btnDel setImage:[UIImage imageNamed:@"job_trash.png"] forState:UIControlStateNormal];
            [btnDel.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [btnDel setImageEdgeInsets:UIEdgeInsetsMake(15, 0, 15, 0)];
            [btnDel addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewHistory addSubview:btnDel];
            
            UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(VIEW_X(btnHistory), VIEW_BY(btnHistory), VIEW_W(btnHistory), 1)];
            [self.viewHistory addSubview:viewSeparate];
            
            heightForView = VIEW_BY(viewSeparate);
        }
        [self.constraintHistoryHeight setConstant:heightForView];
    }
}

- (void)historyClick:(UIButton *)button {
    NSMutableArray *arrayHistory = [[USER_DEFAULT objectForKey:@"cpSearchHistory"] mutableCopy];
    NSDictionary *data = [arrayHistory objectAtIndex:button.tag];
    self.dataParam = [[data objectForKey:@"value"] mutableCopy];
    [self searchClick:nil];
    [arrayHistory removeObjectAtIndex:button.tag];
    [arrayHistory insertObject:data atIndex:0];
    [USER_DEFAULT setObject:arrayHistory forKey:@"cpSearchHistory"];
}

- (void)delClick:(UIButton *)button {
    NSMutableArray *arrayHistory = [[USER_DEFAULT objectForKey:@"cpSearchHistory"] mutableCopy];
    [arrayHistory removeObjectAtIndex:button.tag];
    [USER_DEFAULT setObject:arrayHistory forKey:@"cpSearchHistory"];
    [self fillHistory];
}

- (IBAction)clearClick:(id)sender {
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      CAMAINID, @"caMainID",
                      CAMAINCODE, @"Code",
                      CPMAINID, @"cpMainID",
                      @"", @"strKeyWord",
                      @"", @"strRegionID",
                      @"", @"strJobTypeID",
                      @"", @"strLivePlace",
                      @"", @"strdcIndustryId",
                      @"", @"strdcIndustryIDExpect",
                      @"", @"strJobTypeExpect",
                      @"", @"strCollege",
                      @"", @"strMajorName",
                      @"", @"strAccount",
                      @"", @"strAge",
                      @"", @"strHeight",
                      @"", @"strMobilePlace",
                      @"", @"strSessionId",
                      @"1", @"strPageNo",
                      @"", @"strCvMainID",
                      @"", @"strSalary",
                      @"", @"strExperience",
                      @"", @"strEducation",
                      @"", @"strLanguage",
                      @"", @"strSubNodeNum",
                      @"", @"strMajor",
                      @"", @"strSex",
                      @"", @"strGraduation",
                      @"", @"strEmployType",
                      @"0", @"intJobID", nil];
    [self clearText:self.view];
}

- (void)clearText:(UIView *)parentView {
    for (UIView *view in parentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            [textField setText:@""];
        }
        else if ([view isKindOfClass:[UIView class]]) {
            [self clearText:view];
        }
    }
}

- (IBAction)moreClick:(UIButton *)sender {
    if (sender.tag == 0) {
        self.constraintViewBottom.constant = 0.f;
        [UIView animateWithDuration:0.5 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [sender setTag:1];
            [sender setTitle:@"收起更多搜索条件" forState:UIControlStateNormal];
        }];
    }
    else {
        self.constraintViewBottom.constant = -1047.f;
        [UIView animateWithDuration:0.1 animations:^{
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [sender setTag:0];
            [sender setTitle:@"展开更多搜索条件" forState:UIControlStateNormal];
        }];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 0 || textField.tag == 11 || textField.tag == 16 || textField.tag == 23) {
        return YES;
    }
    [self.view endEditing:YES];
    self.currentTextField = textField;
    if (textField == self.txtJobPlaceExpect || textField == self.txtLivePlace) {
        [self jobPlaceMultiClick:textField];
    }
    else if (textField == self.txtJobType || textField == self.txtJobTypeExpect) {
        [self jobTypeMultiClick:textField];
    }
    else if (textField == self.txtIndustry || textField == self.txtIndustryExpect) {
        [self jobIndustryMultiClick:textField];
    }
    else if (textField == self.txtExperience) {
        [self experienceClick];
    }
    else if (textField == self.txtLowerNumber) {
        [self lowerNumberClick];
    }
    else if (textField == self.txtEmployType) {
        [self employTypeClick];
    }
    else if (textField == self.txtSalaryExpect) {
        [self salaryClick];
    }
    else if (textField == self.txtDegree) {
        [self degreeClick];
    }
    else if (textField == self.txtMajor) {
        [self majorClick];
    }
    else if (textField == self.txtGraduation) {
        [self graducationClick];
    }
    else if (textField == self.txtLanguage) {
        [self languageClick];
    }
    else if (textField == self.txtAccountPlace || textField == self.txtMobilePlace) {
        [self accountPlaceClick];
    }
    else if (textField == self.txtAge) {
        [self ageClick];
    }
    else if (textField == self.txtHeight) {
        [self heightClick];
    }
    else if (textField == self.txtGender) {
        [self genderClick];
    }
    else if (textField == self.txtOnline) {
        [self onlineClick];
    }
    else if (textField == self.txtJob) {
        [self jobClick];
    }
    return NO;
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)jobPlaceMultiClick:(UITextField *)textField {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    if (textField.tag == 1) {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strRegionID"];
    }
    else {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strLivePlace"];
        multiSelectCtrl.title = @"当前所在地";
    }
    multiSelectCtrl.selValue = textField.text;
    multiSelectCtrl.selectType = MultiSelectTypeRegion;
    multiSelectCtrl.accountType = MultiSelectAccountTypeCompany;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)jobTypeMultiClick:(UITextField *)textField {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    if (textField.tag == 2) {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strJobTypeExpect"];
    }
    else {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strJobTypeID"];
        multiSelectCtrl.title = @"现从事职位";
    }
    multiSelectCtrl.selValue = textField.text;
    multiSelectCtrl.selectType = MultiSelectTypeJobType;
    multiSelectCtrl.accountType = MultiSelectAccountTypeCompany;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)jobIndustryMultiClick:(UITextField *)textField {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    if (textField.tag == 4) {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strdcIndustryIDExpect"];
    }
    else {
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"strdcIndustryId"];
        multiSelectCtrl.title = @"现从事行业";
    }
    multiSelectCtrl.selValue = textField.text;
    multiSelectCtrl.selectType = MultiSelectTypeIndustry;
    multiSelectCtrl.accountType = MultiSelectAccountTypeCompany;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect {
    if (selectType == MultiSelectTypeRegion) {
        if (self.currentTextField == self.txtJobPlaceExpect) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strRegionID"];
        }
        else if (self.currentTextField == self.txtLivePlace) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strLivePlace"];
        }
        else if (self.currentTextField == self.txtMobilePlace) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strMobilePlace"];
        }
    }
    else if (selectType == MultiSelectTypeJobType) {
        if (self.currentTextField == self.txtJobTypeExpect) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strJobTypeExpect"];
        }
        else if (self.currentTextField == self.txtJobType) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strJobTypeID"];
        }
    }
    else if (selectType == MultiSelectTypeIndustry) {
        if (self.currentTextField == self.txtIndustryExpect) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strdcIndustryIDExpect"];
        }
        else if (self.currentTextField == self.txtIndustry) {
            [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strdcIndustryId"];
        }
    }
    [self.currentTextField setText:[arraySelect objectAtIndex:1]];
}

- (void)experienceClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchNeedWorkYears value:[self.dataParam objectForKey:@"strExperience"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)lowerNumberClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeLowerNumber value:[self.dataParam objectForKey:@"strSubNodeNum"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)employTypeClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeEmployType value:[self.dataParam objectForKey:@"strEmployType"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)salaryClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchSalary value:[self.dataParam objectForKey:@"strSalary"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)degreeClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchDegree value:[self.dataParam objectForKey:@"strEducation"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)majorClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeMajor value:[self.dataParam objectForKey:@"strMajor"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)graducationClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchGraducation value:[self.dataParam objectForKey:@"strGraduation"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)languageClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeLanguage value:[self.dataParam objectForKey:@"strLanguage"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)accountPlaceClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL2 value:[self.dataParam objectForKey:@"strAccount"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)ageClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchAge value:[self.dataParam objectForKey:@"strAge"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)heightClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchHeight value:[self.dataParam objectForKey:@"strHeight"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)genderClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeGender value:[self.dataParam objectForKey:@"strSex"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)onlineClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSearchOnline value:[self.dataParam objectForKey:@"strSessionId"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}


- (void)jobClick {
    if (self.arrayJob.count == 0) {
        [self.view.window makeToast:@"您尚未发布职位"];
        return;
    }
    WKPopView *popView = [[WKPopView alloc] initWithArray:self.arrayJob value:[self.dataParam objectForKey:@"intJobID"]];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    if (self.currentTextField == self.txtAccountPlace || self.currentTextField == self.txtMobilePlace) {
        NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
        [self.currentTextField setText:[dataRegion objectForKey:@"value"]];
        [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"strAccount"];
        return;
    }
    if (self.currentTextField == self.txtAge) {
        if (arraySelect.count == 1) {
            [self.currentTextField setText:[[arraySelect objectAtIndex:0] objectForKey:@"id"]];
            [self.dataParam setValue:[[arraySelect objectAtIndex:0] objectForKey:@"value"] forKey:@"strAge"];
            return;
        }
        NSDictionary *dataMin = [arraySelect objectAtIndex:0];
        NSDictionary *dataMax = [arraySelect objectAtIndex:2];
        NSString *minAge = [dataMin objectForKey:@"id"];
        NSString *maxAge = [dataMax objectForKey:@"id"];
        NSString *valueAge = @"";
        if ([minAge isEqualToString:@"99"] && [maxAge isEqualToString:@"99"]) {
            valueAge = @"不限";
        }
        else if ([minAge isEqualToString:@"99"]) {
            valueAge = [NSString stringWithFormat:@"%@岁及以下", maxAge];
        }
        else if ([maxAge isEqualToString:@"99"]) {
            valueAge = [NSString stringWithFormat:@"%@岁及以上", minAge];
        }
        else {
            if ([minAge integerValue] >= [maxAge integerValue]) {
                [self.view.window makeToast:@"年龄选择错误"];
                return;
            }
            valueAge = [NSString stringWithFormat:@"%@岁至%@岁", minAge, maxAge];
        }
        
        [self.currentTextField setText:valueAge];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@:%@", [dataMin objectForKey:@"id"], [dataMax objectForKey:@"id"]] forKey:@"strAge"];
        return;
    }
    if (self.currentTextField == self.txtMajor) {
        NSDictionary *data = [arraySelect objectAtIndex:arraySelect.count - 1];
        [self.currentTextField setText:[data objectForKey:@"value"]];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strMajor"];
        return;
    }
    if (self.currentTextField == self.txtHeight) {
        if (arraySelect.count == 1) {
            [self.currentTextField setText:[[arraySelect objectAtIndex:0] objectForKey:@"id"]];
            [self.dataParam setValue:[[arraySelect objectAtIndex:0] objectForKey:@"value"] forKey:@"strAge"];
            return;
        }
        NSDictionary *dataMin = [arraySelect objectAtIndex:0];
        NSDictionary *dataMax = [arraySelect objectAtIndex:2];
        NSString *minAge = [dataMin objectForKey:@"id"];
        NSString *maxAge = [dataMax objectForKey:@"id"];
        NSString *valueAge = @"";
        if ([minAge length] == 0 && [maxAge length] == 0) {
            valueAge = @"不限";
        }
        else if ([minAge length] == 0) {
            valueAge = [NSString stringWithFormat:@"%@cm及以下", maxAge];
        }
        else if ([maxAge length] == 0) {
            valueAge = [NSString stringWithFormat:@"%@cm及以上", minAge];
        }
        else {
            if ([minAge integerValue] > [maxAge integerValue]) {
                [self.view.window makeToast:@"身高选择错误"];
                return;
            }
            valueAge = [NSString stringWithFormat:@"%@cm至%@cm", minAge, maxAge];
        }
        
        [self.currentTextField setText:valueAge];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@:%@", [dataMin objectForKey:@"id"], [dataMax objectForKey:@"id"]] forKey:@"strHeight"];
        return;
    }
    NSDictionary *data = [arraySelect objectAtIndex:0];
    [self.currentTextField setText:[data objectForKey:@"value"]];
    if (self.currentTextField == self.txtExperience) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strExperience"];
    }
    else if (self.currentTextField == self.txtLowerNumber) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strSubNodeNum"];
    }
    else if (self.currentTextField == self.txtEmployType) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strEmployType"];
    }
    else if (self.currentTextField == self.txtSalaryExpect) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strSalary"];
    }
    else if (self.currentTextField == self.txtDegree) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strEducation"];
    }
    else if (self.currentTextField == self.txtGraduation) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strGraduation"];
    }
    else if (self.currentTextField == self.txtLanguage) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strLanguage"];
    }
    else if (self.currentTextField == self.txtGender) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strSex"];
    }
    else if (self.currentTextField == self.txtOnline) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strSessionId"];
    }
    else if (self.currentTextField == self.txtJob) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"intJobID"];
        [self searchClick:nil];
    }
}

- (IBAction)searchClick:(id)sender {
    if (sender != nil) {
        if (self.txtAccountPlace.text.length == 0 && self.txtJobPlaceExpect.text.length == 0 && self.txtMobilePlace.text.length == 0) {
            [self.view.window makeToast:@"期望工作地点、当前所在地、手机号所在地必须至少选择一项"];
            return;
        }
        [self.dataParam setValue:self.txtKeyword.text forKey:@"strKeyWord"];
        [self.dataParam setValue:self.txtCollege.text forKey:@"strCollege"];
        [self.dataParam setValue:self.txtMajorName.text forKey:@"strMajorName"];
        [self.dataParam setValue:self.txtCvMainId.text forKey:@"strCvMainID"];
        
        NSArray *arrayCondition = [self getCondition:self.view];
        NSString *conditionString = [arrayCondition componentsJoinedByString:@"+"];
        NSMutableArray *arrayHistory;
        if ([USER_DEFAULT objectForKey:@"cpSearchHistory"] == nil) {
            arrayHistory = [[NSMutableArray alloc] init];
            [arrayHistory addObject:[NSDictionary dictionaryWithObjectsAndKeys:conditionString, @"text", self.dataParam, @"value", nil]];
        }
        else {
            arrayHistory = [[USER_DEFAULT objectForKey:@"cpSearchHistory"] mutableCopy];
            bool repeat = NO;
            for (NSDictionary *data in arrayHistory) {
                if ([[data objectForKey:@"text"] isEqualToString:conditionString]) {
                    repeat = YES;
                    [arrayHistory removeObject:data];
                    [arrayHistory insertObject:data atIndex:0];
                    break;
                }
            }
            if (!repeat) {
                [arrayHistory insertObject:[NSDictionary dictionaryWithObjectsAndKeys:conditionString, @"text", self.dataParam, @"value", nil] atIndex:0];
            }
            
        }
        if (arrayHistory.count > 10) {
            [arrayHistory removeObjectAtIndex:arrayHistory.count - 1];
        }
        [USER_DEFAULT setObject:arrayHistory forKey:@"cpSearchHistory"];
    }
    CvSearchListViewController *searchListCtrl = [[CvSearchListViewController alloc] init];
    searchListCtrl.dataCondition = self.dataParam;
    [self.navigationController pushViewController:searchListCtrl animated:YES];
}

- (NSArray *)getCondition:(UIView *)parentView {
    NSMutableArray *arrayCondition = [[NSMutableArray alloc] init];
    for (UIView *view in parentView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            UITextField *textField = (UITextField *)view;
            if (textField.text.length > 0) {
                [arrayCondition addObject:textField.text];
            }
        }
        else if ([view isKindOfClass:[UIView class]]) {
            [arrayCondition addObjectsFromArray:[self getCondition:view]];
        }
    }
    return arrayCondition;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    self.arrayJob = [[NSMutableArray alloc] init];
    for (NSDictionary *data in arrayData) {
        [self.arrayJob addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[data objectForKey:@"ID"], @"id", [data objectForKey:@"Name"], @"value", nil]];
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
