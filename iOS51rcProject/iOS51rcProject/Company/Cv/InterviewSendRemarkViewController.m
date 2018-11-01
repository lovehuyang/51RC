//
//  InterviewSendRemarkViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/18.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "InterviewSendRemarkViewController.h"
#import "WKLabel.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"

@interface InterviewSendRemarkViewController ()

@property (nonatomic, strong) UITextView *txtRemark;
@end

@implementation InterviewSendRemarkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"通知备注";
    [self.view setBackgroundColor:SEPARATECOLOR];
    
    WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 15, SCREEN_WIDTH - 30, 20) content:@"请说明乘车路线，需要携带材料等，最多200个字符" size:DEFAULTFONTSIZE color:nil spacing:5];
    [self.view addSubview:lbWarning];
    
    self.txtRemark = [[UITextView alloc] initWithFrame:CGRectMake(VIEW_X(lbWarning), VIEW_BY(lbWarning) + 10, SCREEN_WIDTH - VIEW_X(lbWarning) * 2, 300)];
    [self.txtRemark setText:self.remark];
    [self.txtRemark setReturnKeyType:UIReturnKeyContinue];
    [self.view addSubview:self.txtRemark];
    
    UIBarButtonItem *btnConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(getResponsibility)];
    [btnConfirm setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnConfirm;
}

- (void)getResponsibility {
    if (self.txtRemark.text.length == 0) {
        [self.view makeToast:@"请填写岗位职责"];
        return;
    }
    [self.delegate InterviewSendRemarkConfirm:self.txtRemark.text];
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
