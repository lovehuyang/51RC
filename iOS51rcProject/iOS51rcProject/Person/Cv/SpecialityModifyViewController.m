//
//  SpecialityModifyViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/17.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "SpecialityModifyViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"

@interface SpecialityModifyViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UITextView *txtSpeciality;
@end

@implementation SpecialityModifyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"工作能力";
    [Common changeFontSize:self.view];
    [self.view setBackgroundColor:SEPARATECOLOR];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveSpeciality)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    self.txtSpeciality = [[UITextView alloc] initWithFrame:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 20, SCREEN_WIDTH - 30, 100)];
    [self.txtSpeciality setBackgroundColor:[UIColor whiteColor]];
    [self.txtSpeciality setText:self.speciality];
    [self.txtSpeciality setFont:DEFAULTFONT];
    [self.txtSpeciality.layer setCornerRadius:5];
    [self.view addSubview:self.txtSpeciality];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)saveSpeciality {
    [self.view endEditing:YES];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ModifySpeciality" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cvMainId, @"cvMainId", self.txtSpeciality.text, @"speciality", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
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
