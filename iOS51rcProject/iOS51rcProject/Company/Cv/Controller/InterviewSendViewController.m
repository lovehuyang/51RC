//
//  InterviewSendViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/12.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  面试通知页面

#import "InterviewSendViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "WKPopView.h"
#import "UIView+Toast.h"
#import "InterviewSendRemarkViewController.h"

@interface InterviewSendViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate, WKPopViewDelegate, InterviewSendRemarkViewDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableDictionary *dataParam;
@end

@implementation InterviewSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"面试通知";
    [Common changeFontSize:self.view];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"发送" style:UIBarButtonItemStylePlain target:self action:@selector(sendClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    for (NSInteger i = 0; i < self.arrayJob.count; i++) {
        NSMutableDictionary *data = [self.arrayJob objectAtIndex:i];
        [data setObject:[data objectForKey:@"ID"] forKey:@"id"];
        [data setObject:[data objectForKey:@"Name"] forKey:@"value"];
        [self.arrayJob setObject:data atIndexedSubscript:i];
    }
    
    for (NSInteger i = 0; i < self.arrayTemplate.count; i++) {
        NSMutableDictionary *data = [self.arrayTemplate objectAtIndex:i];
        [data setObject:[data objectForKey:@"ID"] forKey:@"id"];
        [data setObject:[data objectForKey:@"Title"] forKey:@"value"];
        [self.arrayTemplate setObject:data atIndexedSubscript:i];
    }
    NSString *jobId, *jobName;
    if (self.jobId == nil) {
        NSDictionary *jobData = [self.arrayJob objectAtIndex:0];
        jobId = [jobData objectForKey:@"id"];
        jobName = [jobData objectForKey:@"value"];
    }
    else {
        for (NSDictionary *data in self.arrayJob) {
            if ([[data objectForKey:@"id"] isEqualToString:self.jobId]) {
                jobName = [data objectForKey:@"value"];
                jobId = [data objectForKey:@"id"];
                break;
            }
        }
        if (jobId == nil) {
            NSDictionary *jobData = [self.arrayJob objectAtIndex:0];
            jobId = [jobData objectForKey:@"id"];
            jobName = [jobData objectForKey:@"value"];
        }
    }
    [self.txtJob setText:jobName];
    
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      CAMAINID, @"caMainID",
                      CAMAINCODE, @"Code",
                      CPMAINID, @"cpMainID",
                      jobId, @"intJobID",
                      self.cvMainId, @"intCvMainID",
                      @"", @"strInterviewDate",
                      @"", @"strInterviewPlace",
                      @"", @"strLinkMan",
                      @"", @"strTel",
                      @"", @"strRemark",
                      @"", @"intSendEms", nil];
    
    
    self.lbTips.text = [NSString stringWithFormat:@"邀请%@参加[%@]职位的面试", self.paName, jobName];
    if ([[self.otherData objectForKey:@"ReceiveNum"] isEqualToString:@"0"]) {
        self.lbSmsTips.text = @"该求职者已设置不接收短信";
        [self.lbSmsTips setTextColor:[UIColor redColor]];
        [self.btnSms setImage:[UIImage imageNamed:@"img_cpcheck2.png"] forState:UIControlStateNormal];
        [self.btnSms setTag:0];
        [self.btnSms setEnabled:NO];
    }
    else {
        self.lbSmsTips.text = [NSString stringWithFormat:@"同时发送短信给求职者(短信已使用%@条，剩余%@条)", [self.otherData objectForKey:@"UseSmsCnt"], [self.otherData objectForKey:@"RemainSmsCnt"]];
    }
    [self getCpInfo];
}

- (void)getCpInfo {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpMainInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"CaMainID", CAMAINCODE, @"Code", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    [self.view endEditing:YES];
    if (textField == self.txtTemplate) {
        [self templateClick];
        return NO;
    }
    else if (textField == self.txtJob) {
        [self jobClick];
        return NO;
    }
    else if (textField == self.txtRemark) {
        [self remarkClick];
        return NO;
    }
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)templateClick {
    if (self.arrayTemplate.count == 0) {
        [self.view makeToast:@"没有面试通知模板"];
        return;
    }
    WKPopView *popView = [[WKPopView alloc] initWithArray:self.arrayTemplate value:@""];
    [popView setTag:0];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)jobClick {
    if (self.arrayJob.count == 0) {
        [self.view makeToast:@"没有发布中的职位"];
        return;
    }
    WKPopView *popView = [[WKPopView alloc] initWithArray:self.arrayJob value:@""];
    [popView setTag:1];
    [popView setDelegate:self];
    [popView showPopView:self];
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    if (popView.tag == 0) {
        [self.txtTime setText:[data objectForKey:@"InterviewDate"]];
        [self.txtPlace setText:[data objectForKey:@"InterViewPlace"]];
        [self.txtLinkman setText:[data objectForKey:@"LinkMan"]];
        [self.txtTelephone setText:[data objectForKey:@"Telephone"]];
        [self.txtRemark setText:[data objectForKey:@"Remark"]];
        [self.txtTemplate setText:[data objectForKey:@"value"]];
    }
    else {
        [self.dataParam setObject:[data objectForKey:@"id"] forKey:@"intJobID"];
        [self.txtJob setText:[data objectForKey:@"value"]];
        self.lbTips.text = [NSString stringWithFormat:@"邀请%@参加[%@]职位的面试", self.paName, [data objectForKey:@"value"]];
    }
}

- (void)remarkClick {
    InterviewSendRemarkViewController *interviewSendRemarkCtrl = [[InterviewSendRemarkViewController alloc] init];
    interviewSendRemarkCtrl.remark = self.txtRemark.text;
    [interviewSendRemarkCtrl setDelegate:self];
    [self.navigationController pushViewController:interviewSendRemarkCtrl animated:YES];
}

- (void)InterviewSendRemarkConfirm:(NSString *)remark {
    [self.txtRemark setText:remark];
}

- (IBAction)smsClick:(UIButton *)sender {
    if (sender.tag == 1) {
        [sender setImage:[UIImage imageNamed:@"img_cpcheck2.png"] forState:UIControlStateNormal];
        [sender setTag:0];
    }
    else {
        [sender setImage:[UIImage imageNamed:@"img_cpcheck1.png"] forState:UIControlStateNormal];
        [sender setTag:1];
    }
}

- (void)sendClick {
    if (self.txtJob.text.length == 0) {
        [self.view makeToast:@"请选择职位"];
        return;
    }
    else if (self.txtTime.text.length == 0) {
        [self.view makeToast:@"请填写面试时间"];
        return;
    }
    else if (self.txtPlace.text.length == 0) {
        [self.view makeToast:@"请填写面试地点"];
        return;
    }
    else if (self.txtLinkman.text.length == 0) {
        [self.view makeToast:@"请填写联系人"];
        return;
    }
    else if (self.txtTelephone.text.length == 0) {
        [self.view makeToast:@"请填写联系电话"];
        return;
    }
    [self.dataParam setObject:self.txtTime.text forKey:@"strInterviewDate"];
    [self.dataParam setObject:self.txtPlace.text forKey:@"strInterviewPlace"];
    [self.dataParam setObject:self.txtLinkman.text forKey:@"strLinkMan"];
    [self.dataParam setObject:self.txtTelephone.text forKey:@"strTel"];
    [self.dataParam setObject:self.txtRemark.text forKey:@"strRemark"];
    [self.dataParam setObject:(self.btnSms.tag == 0 ? @"0" : @"1") forKey:@"intSendEms"];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"SendCvInterview" Params:self.dataParam viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        if ([result isEqualToString:@"-5"] || [result isEqualToString:@"-6"]) {
            [self.view.window makeToast:@"您无法向该简历发送面试通知，可能个人已将简历隐藏"];
        }
        else if ([result isEqualToString:@"-7"]) {
            [self.view.window makeToast:@"发送面试通知失败，您30天之内已经向该简历发送过面试通知"];
        }
        else if ([result isEqualToString:@"-8"]) {
            [self.view.window makeToast:@"发送面试通知失败"];
        }
        else {
            [self.view.window makeToast:@"面试通知发送成功，同时还给绑定微信的求职者发送了微信通知，赠送您10积分" duration:4 position:self];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else if (request.tag == 2) {
        NSDictionary *companyData = [[Common getArrayFromXml:requestData tableName:@"TableCp"] objectAtIndex:0];
        NSDictionary *accountData = [[Common getArrayFromXml:requestData tableName:@"TableCa"] objectAtIndex:0];
        [self.txtPlace setText:[companyData objectForKey:@"Address"]];
        [self.txtLinkman setText:[accountData objectForKey:@"Name"]];
        [self.txtTelephone setText:([[accountData objectForKey:@"Telephone"] length] > 0 ? [accountData objectForKey:@"Telephone"] : [accountData objectForKey:@"Mobile"])];
    }
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
