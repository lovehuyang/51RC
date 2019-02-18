//
//  DemandViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/16.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "DemandViewController.h"
#import "WKLabel.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"

@interface DemandViewController ()

@property (nonatomic, strong) UITextView *txtDemand;
@end

@implementation DemandViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"岗位要求";
    [self.view setBackgroundColor:SEPARATECOLOR];
    
    WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 15, SCREEN_WIDTH - 30, 20) content:@"不要留下电话、手机、传真、电子邮箱、QQ、MSN、网址等联系方式或者企业简介，否则内容可能被删除或者修改" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:5];
    [self.view addSubview:lbWarning];
    
    self.txtDemand = [[UITextView alloc] initWithFrame:CGRectMake(VIEW_X(lbWarning), VIEW_BY(lbWarning) + 10, SCREEN_WIDTH - VIEW_X(lbWarning) * 2, 300)];
    [self.txtDemand setText:self.demand];
    [self.txtDemand setReturnKeyType:UIReturnKeyContinue];
    [self.txtDemand setFont:DEFAULTFONT];
    [self.view addSubview:self.txtDemand];
    
    UIBarButtonItem *btnConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(getDemand)];
    [btnConfirm setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnConfirm;
}

- (void)getDemand {
    if (self.txtDemand.text.length == 0) {
        [self.view makeToast:@"请填写岗位要求"];
        return;
    }
    [self.delegate DemandViewConfirm:self.txtDemand.text];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
