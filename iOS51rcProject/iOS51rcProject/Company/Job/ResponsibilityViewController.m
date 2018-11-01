//
//  ResponsibilityViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/16.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "ResponsibilityViewController.h"
#import "WKLabel.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"

@interface ResponsibilityViewController ()

@property (nonatomic, strong) UITextView *txtResponsibility;
@end

@implementation ResponsibilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"岗位职责";
    [self.view setBackgroundColor:SEPARATECOLOR];
    
    WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 15, SCREEN_WIDTH - 30, 20) content:@"不要留下电话、手机、传真、电子邮箱、QQ、MSN、网址等联系方式或者企业简介，否则内容可能被删除或者修改" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:5];
    [self.view addSubview:lbWarning];
    
    self.txtResponsibility = [[UITextView alloc] initWithFrame:CGRectMake(VIEW_X(lbWarning), VIEW_BY(lbWarning) + 10, SCREEN_WIDTH - VIEW_X(lbWarning) * 2, 300)];
    [self.txtResponsibility setText:self.responsibility];
    [self.txtResponsibility setReturnKeyType:UIReturnKeyContinue];
    [self.txtResponsibility setFont:DEFAULTFONT];
    [self.view addSubview:self.txtResponsibility];
    
    UIBarButtonItem *btnConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(getResponsibility)];
    [btnConfirm setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnConfirm;
}

- (void)getResponsibility {
    if (self.txtResponsibility.text.length == 0) {
        [self.view makeToast:@"请填写岗位职责"];
        return;
    }
    [self.delegate ResponsibilityViewConfirm:self.txtResponsibility.text];
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
