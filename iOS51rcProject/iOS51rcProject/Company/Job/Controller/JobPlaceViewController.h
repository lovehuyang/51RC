//
//  JobPlaceViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/21.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol JobPlaceViewDelegate <NSObject>

- (void)JobPlaceViewConfirm:(NSString *)region regionId:(NSString *)regionId address:(NSString *)address lat:(NSString *)lat lng:(NSString *)lng;
@end

@interface JobPlaceViewController : WKViewController

@property Boolean isCompany;
@property (nonatomic, strong) NSString *regionId;
@property (nonatomic, strong) NSString *region;
@property (nonatomic, strong) NSString *address;
@property (nonatomic, strong) NSString *lat;
@property (nonatomic, strong) NSString *lng;
@property (strong, nonatomic) IBOutlet UIView *viewMap;
@property (strong, nonatomic) IBOutlet UITextField *txtRegion;
@property (strong, nonatomic) IBOutlet UITextField *txtAddress;
@property (nonatomic, assign) id<JobPlaceViewDelegate> delegate;
@property (strong, nonatomic) IBOutlet UILabel *lbTips;
@property (strong, nonatomic) IBOutlet UIView *viewAddress;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *constraintViewHeight;
@end
