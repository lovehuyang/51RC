//
//  SysViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "SysViewController.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "AccountViewController.h"
#import "CpModifyViewController.h"
#import "CpLogoViewController.h"
#import "CpEnvironmentViewController.h"

@interface SysViewController ()

@property float heightForScroll;
@end

@implementation SysViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:SEPARATECOLOR];
    self.heightForScroll = STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT + 10;
    [self initButton:0];
    [self initButton:1];
    [self initButton:2];
    [self initButton:3];
}

- (void)initButton:(NSInteger)tag {
    NSString *title;
    switch (tag) {
        case 0:
            title = @"企业基本信息";
            break;
        case 1:
            title = @"企业Logo";
            break;
        case 2:
            title = @"企业环境照片";
            break;
        case 3:
            title = @"用户管理";
            break;
        default:
            break;
    }
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll, SCREEN_WIDTH, 50)];
    [btn setBackgroundColor:[UIColor whiteColor]];
    [btn setTag:tag];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
    [btn.titleLabel setFont:DEFAULTFONT];
    [btn.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [btn addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIImageView *imgArrow = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 36, 20, 6, 10)];
    [imgArrow setImage:[UIImage imageNamed:@"img_arrowright.png"]];
    [btn addSubview:imgArrow];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(btn) - 1, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [btn addSubview:viewSeparate];
    self.heightForScroll = VIEW_BY(btn);
    
    [self.view addSubview:btn];
}

- (void)buttonClick:(UIButton *)button {
    if (button.tag == 0) {
        CpModifyViewController *cpModifyCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cpModifyView"];
        [self.navigationController pushViewController:cpModifyCtrl animated:YES];
    }
    else if (button.tag == 1) {
        CpLogoViewController *cpLogoCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"cpLogoView"];
        [self.navigationController pushViewController:cpLogoCtrl animated:YES];
    }
    else if (button.tag == 2) {
        CpEnvironmentViewController *cpEnvironmentCtrl = [[CpEnvironmentViewController alloc] init];
        [self.navigationController pushViewController:cpEnvironmentCtrl animated:YES];
    }
    else if (button.tag == 3) {
        AccountViewController *accountCtrl = [[AccountViewController alloc] init];
        [self.navigationController pushViewController:accountCtrl animated:YES];
    }
}

@end
