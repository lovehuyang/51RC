//
//  MapViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/3.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "MapViewController.h"
#import "CommonMacro.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    BMKMapView *viewMap = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [viewMap setZoomLevel:18];
    self.view = viewMap;
    
    CLLocationCoordinate2D coor;
    coor.latitude = [self.lat doubleValue];
    coor.longitude = [self.lng doubleValue];
    [viewMap setCenterCoordinate:coor];
    
    BMKPointAnnotation *point = [[BMKPointAnnotation alloc] init];
    [point setCoordinate:coor];
    //[point setTitle:self.title];
    //[point setSubtitle:self.pointTitle];
    
    [viewMap addAnnotation:point];
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
