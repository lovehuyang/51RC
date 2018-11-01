//
//  CvRecruitmentConditionViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CvRecruitmentConditionViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "CvRecruitmentListViewController.h"
#import "MultiSelectViewController.h"

@interface CvRecruitmentConditionViewController ()<UITextFieldDelegate, WKPopViewDelegate, NetWebServiceRequestDelegate, MultiSelectDelegate>

@property (nonatomic, strong) NSMutableDictionary *dataParam;
@property (nonatomic, strong) UITextField *currentTextField;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrayPlace;
@end

@implementation CvRecruitmentConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.btnSearch.layer setCornerRadius:5];
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      CAMAINID, @"caMainID",
                      CAMAINCODE, @"Code",
                      [USER_DEFAULT objectForKey:@"provinceId"], @"strRegion",
                      @"", @"strRecruitmentPlaceID",
                      @"1", @"PageNo",
                      @"", @"strJobTypeID",
                      @"", @"strKeyWord", nil];
    [self.txtRegion setText:[USER_DEFAULT objectForKey:@"province"]];
    [self getPlace];
}

- (void)getPlace {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpRmPlaceList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [self.dataParam objectForKey:@"strRegion"], @"strRegionID", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)searchClick:(id)sender {
    CvRecruitmentListViewController *cvRecruitmentListCtrl = [[CvRecruitmentListViewController alloc] init];
    [cvRecruitmentListCtrl setDataCondition:self.dataParam];
    [self.navigationController pushViewController:cvRecruitmentListCtrl animated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    self.arrayPlace = [[NSMutableArray alloc] init];
    for (NSDictionary *data in arrayData) {
        [self.arrayPlace addObject:[[NSDictionary alloc] initWithObjectsAndKeys:[data objectForKey:@"Id"], @"id", [data objectForKey:@"PlaceName"], @"value", nil]];
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.tag == 3) {
        return YES;
    }
    [self.view endEditing:YES];
    self.currentTextField = textField;
    if (textField.tag == 0) {
        [self regionClick];
    }
    else if (textField.tag == 1) {
        [self placeClick];
    }
    else if (textField.tag == 2) {
        [self jobTypeClick:textField];
    }
    return NO;
}

- (void)jobTypeClick:(UITextField *)textField {
    MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
    [multiSelectCtrl setDelegate:self];
    multiSelectCtrl.selId = [self.dataParam objectForKey:@"strJobTypeID"];
    multiSelectCtrl.selValue = textField.text;
    multiSelectCtrl.accountType = MultiSelectAccountTypeCompany;
    multiSelectCtrl.selectType = MultiSelectTypeJobType;
    [self.navigationController pushViewController:multiSelectCtrl animated:YES];
}

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect {
    [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"strJobTypeID"];
    [self.currentTextField setText:[arraySelect objectAtIndex:1]];
}

- (void)regionClick {
    WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL2 value:[self.dataParam objectForKey:@"strRegion"]];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)placeClick {
    WKPopView *popView = [[WKPopView alloc] initWithArray:self.arrayPlace value:[self.dataParam objectForKey:@"strRecruitmentPlaceID"]];
    [popView setCancelClear:YES];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:arraySelect.count - 1];
    [self.currentTextField setText:[data objectForKey:@"value"]];
    if (self.currentTextField == self.txtRegion) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strRegion"];
        [self getPlace];
    }
    else if (self.currentTextField == self.txtPlace) {
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"strRecruitmentPlaceID"];
    }
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
