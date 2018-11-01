//
//  JobPlaceViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/21.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "JobPlaceViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKPopView.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>

@interface JobPlaceViewController ()<UITextFieldDelegate, WKPopViewDelegate, NetWebServiceRequestDelegate, BMKMapViewDelegate, BMKGeoCodeSearchDelegate, BMKLocationServiceDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) BMKMapView *mapView;
@property (nonatomic, strong) BMKGeoCodeSearch *geoCodeSearch;
@property (nonatomic, strong) BMKLocationService *locService;
@end

@implementation JobPlaceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.viewAddress.layer setMasksToBounds:YES];
    if (self.isCompany) {
        self.title = @"企业地址";
        [self.lbTips setText:@"请标注企业详细地址"];
    }
    else {
        self.title = @"工作地点";
        [self.constraintViewHeight setConstant:50];
    }
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    [self.txtRegion setText:self.region];
    [self.txtAddress setText:self.address];
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self.viewMap), VIEW_H(self.viewMap))];
    [self.mapView setZoomLevel:18];
    [self.mapView setDelegate:self];
    [self.viewMap addSubview:self.mapView];
    
    if (self.lng != nil && self.lng.length > 0) {
        [self setMapCenter];
    }
    else if (self.isCompany) {
        self.locService = [[BMKLocationService alloc] init];
        self.locService.delegate = self;
        [self.locService startUserLocationService];
    }
    
    UIImageView *imgAnn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [imgAnn setImage:[UIImage imageNamed:@"ico_mapcenter.png"]];
    [imgAnn setContentMode:UIViewContentModeScaleAspectFit];
    [imgAnn setCenter:CGPointMake(SCREEN_WIDTH / 2, VIEW_H(self.viewMap) / 2)];
    [self.viewMap addSubview:imgAnn];
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    [self.geoCodeSearch setDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.geoCodeSearch.delegate = nil;
    self.locService.delegate = nil;
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetRegionLocByID" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:self.regionId, @"RegionID", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    if (textField == self.txtAddress) {
        return YES;
    }
    if (textField == self.txtRegion) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL3 value:self.regionId];
        [popView setDelegate:self];
        [popView showPopView:self];
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

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
    NSMutableString *regionString = [[NSMutableString alloc] init];
    for (NSDictionary *data in arraySelect) {
        [regionString appendString:[data objectForKey:@"value"]];
    }
    [self.txtRegion setText:regionString];
    self.regionId = [dataRegion objectForKey:@"id"];
    [self getData];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayRegion = [Common getArrayFromXml:requestData tableName:@"ds"];
        if (arrayRegion.count > 0) {
            NSDictionary *regionData = [arrayRegion objectAtIndex:0];
            self.lng = [regionData objectForKey:@"Lng"];
            self.lat = [regionData objectForKey:@"Lat"];
            [self setMapCenter];
        }
    }
    else if (request.tag == 2) {
        NSArray *arrRegion = [result componentsSeparatedByString:@"##$$"];
        if (arrRegion.count > 0) {
            self.regionId = [arrRegion objectAtIndex:0];
            [self.txtRegion setText:[arrRegion objectAtIndex:1]];
            [self.txtAddress setText:[arrRegion objectAtIndex:2]];
        }
    }
}

- (void)setMapCenter {
    CLLocationCoordinate2D coor;
    coor.latitude = [self.lat doubleValue];
    coor.longitude = [self.lng doubleValue];
    [self.mapView setCenterCoordinate:coor];
}

- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
    self.lat = [NSString stringWithFormat:@"%f", userLocation.location.coordinate.latitude];
    self.lng = [NSString stringWithFormat:@"%f", userLocation.location.coordinate.longitude];
    [self setMapCenter];
    [self getMapAddress];
    [self.locService stopUserLocationService];
}

- (void)getMapAddress {
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc] init];
    [reverseGeocodeSearchOption setReverseGeoPoint:self.mapView.centerCoordinate];
    [_geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
}

//根据坐标获取地理位置成功执行此方法
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetRegionInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:result.address, @"address", nil] viewController:nil];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    else {
        [self.txtAddress setText:@""];
    }
}

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
    [self getMapAddress];
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

- (void)saveClick {
    if (self.txtRegion.text.length == 0) {
        [self.view makeToast:@"请选择所在地区"];
        return;
    }
    if (self.txtRegion.text.length == 2) {
        [self.view makeToast:@"请选择详细的所在地区"];
        return;
    }
    if (self.isCompany) {
        if (self.txtAddress.text.length == 0) {
            [self.view makeToast:@"请输入详细地址"];
            return;
        }
        if (self.txtAddress.text.length < 5) {
            [self.view makeToast:@"详细地址不能少于5个字符"];
            return;
        }
        if (self.txtAddress.text.length > 60) {
            [self.view makeToast:@"详细地址不能超过60个字符"];
            return;
        }
    }
    [self.delegate JobPlaceViewConfirm:self.txtRegion.text regionId:self.regionId address:self.txtAddress.text lat:[NSString stringWithFormat:@"%f", self.mapView.centerCoordinate.latitude] lng:[NSString stringWithFormat:@"%f", self.mapView.centerCoordinate.longitude]];
    [self.navigationController popViewControllerAnimated:YES];
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
