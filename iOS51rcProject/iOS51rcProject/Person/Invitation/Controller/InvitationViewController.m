//
//  InvitationViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/1.
//  Copyright © 2017年 Lucifer. All rights reserved.
//  邀约页面

#import "InvitationViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import "JobApplyViewController.h"
#import "InterviewViewController.h"
#import "ApplyInvitationViewController.h"
#import "CpViewViewController.h"
#import "YourFoodViewController.h"
#import "AttentionViewController.h"
#import "WKLoginView.h"
#import "PersonNoticeModel.h"

@interface InvitationViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) WKLoginView *loginView;
@end

@implementation InvitationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"邀约";
    [self.view setBackgroundColor:SEPARATECOLOR];
    [Common changeFontSize:self.view];
    [self.markApply.layer setCornerRadius:VIEW_H(self.markApply) / 2];
    [self.markInterview.layer setCornerRadius:VIEW_H(self.markInterview) / 2];
    [self.markInvitation.layer setCornerRadius:VIEW_H(self.markInvitation) / 2];
    [self.markCvView.layer setCornerRadius:VIEW_H(self.markCvView) / 2];
    [self.markAttention.layer setCornerRadius:VIEW_H(self.markAttention) / 2];
    [self.markFood.layer setCornerRadius:VIEW_H(self.markFood) / 2];
    
    [self clearAll];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    if (!PERSONLOGIN) {
        return;
    }
    [self.loginView removeFromSuperview];
    if ([PAMAINID length] > 0) {
        NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPersonNotice" Params:paramDict viewController:self];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    else {
        [self clearAll];
    }
}

- (void)clearAll {
    [self.markApply setHidden:YES];
    [self.markInterview setHidden:YES];
    [self.markInvitation setHidden:YES];
    [self.markCvView setHidden:YES];
    [self.markAttention setHidden:YES];
    [self.markFood setHidden:YES];
    
    [self.msgApply setText:@"暂无新消息"];
    [self.msgInterview setText:@"暂无新消息"];
    [self.msgInvitation setText:@"暂无新消息"];
    [self.msgCvView setText:@"暂无新消息"];
    [self.msgAttention setText:@"暂无新消息"];
    [self.msgFood setText:@"暂无新消息"];
    
    [self.dateApply setHidden:YES];
    [self.dateInterview setHidden:YES];
    [self.dateInvitation setHidden:YES];
    [self.dateCvView setHidden:YES];
    [self.dateAttention setHidden:YES];
    [self.dateFood setHidden:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    NSDictionary *countData = [[Common getArrayFromXml:requestData tableName:@"Table"] objectAtIndex:0];
    PersonNoticeModel *model = [PersonNoticeModel buideModel:countData];
    
    if ([model.JobAppliedCount integerValue] > 0) {
        [self.markApply setHidden:NO];
        [self.dateApply setHidden:NO];
        NSDictionary *applyData = [[Common getArrayFromXml:requestData tableName:@"Table1"] objectAtIndex:0];
        [self.msgApply setText:[NSString stringWithFormat:@"%@答复您的简历为%@", [applyData objectForKey:@"cpName"], ([[applyData objectForKey:@"Reply"] intValue] == 1 ? @"符合要求" : @"不符合要求")]];
        [self.dateApply setText:[Common stringFromDateString:[applyData objectForKey:@"ReplyDate"] formatType:@"MM-dd"]];
    }
    else {
        [self.markApply setHidden:YES];
        [self.dateApply setHidden:YES];
        [self.msgApply setText:@"暂无新消息"];
    }
    
    if ([[Common getArrayFromXml:requestData tableName:@"Table2"] count] > 0) {
        [self.markInterview setHidden:NO];
        [self.dateInterview setHidden:NO];
        NSDictionary *interviewData = [[Common getArrayFromXml:requestData tableName:@"Table2"] objectAtIndex:0];
        [self.msgInterview setText:[NSString stringWithFormat:@"%@邀请您参加面试", [interviewData objectForKey:@"cpName"]]];
        [self.dateInterview setText:[Common stringFromDateString:[interviewData objectForKey:@"AddDate"] formatType:@"MM-dd"]];
        [self.cntInterview setText:model.InterviewCount];
    }
    else {
        [self.markInterview setHidden:YES];
        [self.dateInterview setHidden:YES];
        [self.msgInterview setText:@"暂无新消息"];
    }
    
    if ([[Common getArrayFromXml:requestData tableName:@"Table3"] count] > 0) {
        [self.markInvitation setHidden:NO];
        [self.dateInvitation setHidden:NO];
        NSDictionary *invitationData = [[Common getArrayFromXml:requestData tableName:@"Table3"] objectAtIndex:0];
        [self.msgInvitation setText:[NSString stringWithFormat:@"%@邀请您应聘职位“%@”", [invitationData objectForKey:@"CpName"], [invitationData objectForKey:@"JobName"]]];
        [self.dateInvitation setText:[Common stringFromDateString:[invitationData objectForKey:@"AddDate"] formatType:@"MM-dd"]];
        [self.cntInvitation setText:model.CpInvitationCount];
    }
    else {
        [self.markInvitation setHidden:YES];
        [self.dateInvitation setHidden:YES];
        [self.msgInvitation setText:@"暂无新消息"];
    }
    
    if ([[Common getArrayFromXml:requestData tableName:@"Table5"] count] > 0) {
        [self.markCvView setHidden:NO];
        [self.dateCvView setHidden:NO];
        NSDictionary *cvViewData = [[Common getArrayFromXml:requestData tableName:@"Table5"] objectAtIndex:0];
        [self.msgCvView setText:[NSString stringWithFormat:@"%@浏览了您的简历", [cvViewData objectForKey:@"CpName"]]];
        [self.dateCvView setText:[Common stringFromDateString:[cvViewData objectForKey:@"AddDate"] formatType:@"MM-dd"]];
    }
    else {
        [self.markCvView setHidden:YES];
        [self.dateCvView setHidden:YES];
        [self.msgCvView setText:@"暂无新消息"];
    }
    
    if ([[Common getArrayFromXml:requestData tableName:@"Table6"] count] > 0) {
        [self.markAttention setHidden:NO];
        [self.dateAttention setHidden:NO];
        NSDictionary *attentionData = [[Common getArrayFromXml:requestData tableName:@"Table6"] objectAtIndex:0];
        [self.msgAttention setText:[attentionData objectForKey:@"ModifyDesc"]];
        [self.dateAttention setText:[Common stringFromDateString:[attentionData objectForKey:@"ModifyDate"] formatType:@"MM-dd"]];
    }
    else {
        [self.markAttention setHidden:YES];
        [self.dateAttention setHidden:YES];
        [self.msgAttention setText:@"暂无新消息"];
    }
    
    if ([[Common getArrayFromXml:requestData tableName:@"Table7"] count] > 0) {
        [self.markFood setHidden:NO];
        [self.dateFood setHidden:NO];
        NSDictionary *attentionData = [[Common getArrayFromXml:requestData tableName:@"Table7"] objectAtIndex:0];
        [self.msgFood setText:@"网站为您推荐了合适的职位，邀您申请"];
        [self.dateFood setText:[Common stringFromDateString:[attentionData objectForKey:@"AddDate"] formatType:@"MM-dd"]];
    }
    else {
        [self.markFood setHidden:YES];
        [self.dateFood setHidden:YES];
        [self.msgFood setText:@"暂无新消息"];
    }
}

- (IBAction)itemClick:(UIButton *)sender {
    if (!PERSONLOGIN) {
        UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
        [self presentViewController:loginCtrl animated:YES completion:nil];
        return;
    }
    if (sender.tag == 0) {
        JobApplyViewController *jobApplyCtrl = [[JobApplyViewController alloc] init];
        jobApplyCtrl.title = @"申请的职位";
        [self.navigationController pushViewController:jobApplyCtrl animated:YES];
    }
    else if (sender.tag == 1) {
        InterviewViewController *interviewCtrl = [[InterviewViewController alloc] init];
        interviewCtrl.title = @"面试通知";
        [self.navigationController pushViewController:interviewCtrl animated:YES];
    }
    else if (sender.tag == 2) {
        ApplyInvitationViewController *invitationCtrl = [[ApplyInvitationViewController alloc] init];
        invitationCtrl.title = @"应聘邀请";
        [self.navigationController pushViewController:invitationCtrl animated:YES];
    }
    else if (sender.tag == 3) {
        CpViewViewController *cpViewCtrl = [[CpViewViewController alloc] init];
        cpViewCtrl.title = @"谁在关注我";
        [self.navigationController pushViewController:cpViewCtrl animated:YES];
    }
    else if (sender.tag == 4) {
        AttentionViewController *attentionViewCtrl = [[AttentionViewController alloc] init];
        attentionViewCtrl.title = @"我的关注";
        [self.navigationController pushViewController:attentionViewCtrl animated:YES];
    }
    else if (sender.tag == 5) {
        YourFoodViewController *yourFoodCtrl = [[YourFoodViewController alloc] init];
        yourFoodCtrl.title = @"你的菜儿";
        [self.navigationController pushViewController:yourFoodCtrl animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
