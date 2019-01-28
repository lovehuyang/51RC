//
//  CpBriefViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/16.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CpBriefViewController.h"
#import "WKLabel.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"

@interface CpBriefViewController ()

@property (nonatomic, strong) UITextView *txtBrief;
@end

@implementation CpBriefViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业简介";
    [self.view setBackgroundColor:SEPARATECOLOR];
    
    WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 15, SCREEN_WIDTH - 30, 20) content:@"此处不要包含联系方式和职位信息。请将电话、邮箱、传真等填写在联系方式中。发布职位请使用新增职位\n最少20个字符，最多3000个字符" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:5];
    [self.view addSubview:lbWarning];
    
    self.txtBrief = [[UITextView alloc] initWithFrame:CGRectMake(VIEW_X(lbWarning), VIEW_BY(lbWarning) + 10, SCREEN_WIDTH - VIEW_X(lbWarning) * 2, 300)];
    [self.txtBrief setText:self.brief];
    [self.txtBrief setReturnKeyType:UIReturnKeyContinue];
    [self.txtBrief setFont:DEFAULTFONT];
    [self.view addSubview:self.txtBrief];
    
    UIBarButtonItem *btnConfirm = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(getBrief)];
    [btnConfirm setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnConfirm;
}

- (void)getBrief {
    [self.view endEditing:YES];
    if (self.txtBrief.text.length < 20) {
        [self.view makeToast:@"请填写企业简介，最少输入20个字符"];
        return;
    }
    else if (self.txtBrief.text.length > 3000) {
        [self.view makeToast:@"最多输入3000个字符"];
        return;
    }
    [self.delegate CpBriefViewConfirm:self.txtBrief.text];
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
