//
//  CvOperate.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/10.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CvOperate.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "WKPopView.h"
#import "WKLabel.h"
#import "InterviewSendViewController.h"
#import "ChatCpViewController.h"

@interface CvOperate ()<NetWebServiceRequestDelegate, WKPopViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *applyId;
@property (nonatomic, strong) WKPopView *popView;
@property (nonatomic, strong) UITextField *txtReason;
@property CvOperateType operateType;
@end

@implementation CvOperate

- (instancetype)init:(NSString *)cvMainId paName:(NSString *)paName viewController:(UIViewController *)viewController {
    if (self == [super init]) {
        self.cvMainId = cvMainId;
        self.paName = paName;
        self.viewController = viewController;
    }
    return self;
}

- (void)replyCv:(NSString *)applyId replyType:(NSString *)replyType {
    if (applyId.length == 0) {
        return;
    }
    self.operateType = ([replyType isEqualToString:@"1"] ? CvOperateTypeReplyPass : CvOperateTypeReplyDeny);
    self.applyId = applyId;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"ReplyApplyCv" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", applyId, @"applyID", replyType, @"intReply", nil] viewController:self.viewController];
    [request setTag:CvOperateNetReply];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)getValidJob {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpJobListByCvSearch" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", nil] viewController:self.viewController];
    [request setTag:CvOperateNetValidJob];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)gotoChat:(NSString *)jobId {
    ChatCpViewController *chatCtrl = [[ChatCpViewController alloc] init];
    chatCtrl.title = self.paName;
    chatCtrl.cvMainId = self.cvMainId;
    chatCtrl.caMainId = CAMAINID;
    chatCtrl.jobId = jobId;
    [self.viewController.navigationController pushViewController:chatCtrl animated:YES];
}

- (void)gotoFavorite:(NSString *)jobId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"InsertCvFavorate" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.cvMainId, @"cvMainID", jobId, @"jobID", nil] viewController:self.viewController];
    [request setTag:CvOperateNetFavorite];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)gotoInvitation:(NSString *)jobId {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"InsertCvIntention" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.cvMainId, @"cvMainID", jobId, @"jobID", nil] viewController:self.viewController];
    [request setTag:CvOperateNetInvitation];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)reasonClick:(UIButton *)button {
    [self.viewController.view.window endEditing:YES];
    [self.txtReason setText:@""];
    UIView *viewContent = button.superview;
    NSInteger originTag = button.tag;
    for (UIView *view in viewContent.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *btnReason = (UIButton *)view;
            [btnReason setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btnReason setBackgroundColor:SEPARATECOLOR];
            [btnReason setTag:0];
        }
    }
    if (originTag == 0) {
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [button setBackgroundColor:GREENCOLOR];
        [button setTag:1];
    }
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    if (self.operateType == CvOperateTypeReplyDeny) { //答复不符合
        UIView *viewContent = [[self.popView viewWithTag:POPVIEWTAG] viewWithTag:POPVIEWCONTENTTAG];
        NSString *reason = self.txtReason.text;
        if (reason.length == 0) {
            for (UIView *view in viewContent.subviews) {
                if ([view isKindOfClass:[UIButton class]]) {
                    UIButton *btnReason = (UIButton *)view;
                    if (btnReason.tag == 1) {
                        reason = btnReason.titleLabel.text;
                        break;
                    }
                }
            }
        }
        
        if (reason.length == 0) {
            [self.viewController.view.window makeToast:@"请选择或填写不合适原因"];
            return;
        }
        if (reason.length > 50) {
            [self.viewController.view.window makeToast:@"不合适原因不能超过50个字符"];
            return;
        }
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UpDateJobApplyReason" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", reason, @"strReason", self.applyId, @"intApplyID", nil] viewController:self.viewController];
        [request setTag:CvOperateNetReplyReason];
        [request setDelegate:self];
        [request startSynchronous];
        self.runningRequest = request;
        [self.popView cancelClick];
    }
    else if (self.operateType == CvOperateTypeChat || self.operateType == CvOperateTypeInterview) { //下载简历
        [self.popView cancelClick];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCvContact" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"cpMainID", CAMAINCODE, @"Code", self.cvMainId, @"intCvMainID", nil] viewController:self.viewController];
        [request setTag:CvOperateNetDownload];
        [request setDelegate:self];
        [request startSynchronous];
        self.runningRequest = request;
    }
    else {
        [self.popView cancelClick];
    }
}

- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect {
    NSDictionary *data = [arraySelect objectAtIndex:0];
    if (self.operateType == CvOperateTypeChat) {
        [self gotoChat:[data objectForKey:@"id"]];
    }
    else if (self.operateType == CvOperateTypeFavorite) {
        [self gotoFavorite:[data objectForKey:@"id"]];
    }
    else if (self.operateType == CvOperateTypeInvitation) {
        [self gotoInvitation:[data objectForKey:@"id"]];
    }
}

- (void)interview {
    [self.popView cancelClick];
    self.operateType = CvOperateTypeInterview;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpInterviewSend" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CPMAINID, @"intCpMainID", CAMAINCODE, @"Code", self.cvMainId, @"intCvMainID", nil] viewController:self.viewController];
    [request setTag:CvOperateNetInterview];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)beginChat {
    self.operateType = CvOperateTypeChat;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"CheckChatPrivi" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", CPMAINID, @"cpMainID", self.cvMainId, @"cvMainId", nil] viewController:self.viewController];
    [request setTag:CvOperateNetChatPrivi];
    [request setDelegate:self];
    [request startSynchronous];
    self.runningRequest = request;
}

- (void)invitation {
    if ([[USER_DEFAULT objectForKey:@"cpMemberType"] integerValue] < 2) {
        [self.viewController.view.window makeToast:@"您的企业还未认证，请先到电脑端完成企业认证"];
        return;
    }
    self.operateType = CvOperateTypeInvitation;
    [self getValidJob];
}

- (void)favorite {
    self.operateType = CvOperateTypeFavorite;
    [self getValidJob];
}

- (void)popDownload:(NSString *)notice {
    NSArray *arrayResult = [notice componentsSeparatedByString:@"$$##"];
    NSString *tipString = @"";
    if (arrayResult.count == 1) {
        tipString = [arrayResult objectAtIndex:0];
        if ([tipString rangeOfString:@"联系方式"].location != NSNotFound) {
            if (self.operateType == CvOperateTypeInterview) {
                tipString = @"此简历位于非开放简历库，由于您不是VIP，您无法发送面试通知。";
            }
            else if (self.operateType == CvOperateTypeChat) {
                tipString = @"此简历位于非开放简历库，由于您不是VIP，您无法与TA主动发起会话。";
            }
        }
        self.operateType = CvOperateTypeNone;
    }
    else {
        tipString = [arrayResult objectAtIndex:1];
    }
    UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 160)];
    
    UIImageView *imgTip = [[UIImageView alloc] initWithFrame:CGRectMake(35, 25, 60, 100)];
    [imgTip setImage:[UIImage imageNamed:@"cp_infotips.png"]];
    [imgTip setContentMode:UIViewContentModeScaleAspectFit];
    [viewContent addSubview:imgTip];
    WKLabel *lbTip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(imgTip) + 15, 20, SCREEN_WIDTH - VIEW_BX(imgTip) - 50, 10) content:tipString size:DEFAULTFONTSIZE color:nil spacing:10];
    [viewContent addSubview:lbTip];
    [lbTip setCenter:CGPointMake(lbTip.center.x, imgTip.center.y)];
    
    self.popView = [[WKPopView alloc] initWithCustomView:viewContent];
    [self.popView setDelegate:self];
    [self.popView showPopView:self.viewController];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == CvOperateNetReply) { //答复简历
        [self.delegate cvOperateFinished];
        if (self.operateType == CvOperateTypeReplyPass) {
            UIView *viewContent = [[UIView alloc] init];
            
            UIView *viewTitle = [[UIView alloc] init];
            [viewContent addSubview:viewTitle];
            
            UIImageView *imgSuccess = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
            [imgSuccess setImage:[UIImage imageNamed:@"cp_success.png"]];
            [viewTitle addSubview:imgSuccess];
            
            WKLabel *lbSuccess = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgSuccess) + 5, 0, 200, VIEW_H(imgSuccess)) content:@"已答复对TA有意" size:BIGGERFONTSIZE color:GREENCOLOR];
            [viewTitle addSubview:lbSuccess];
            
            [viewTitle setFrame:CGRectMake(0, 30, VIEW_BX(lbSuccess), VIEW_H(imgSuccess))];
            
            WKLabel *lbTip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(viewTitle) + 20, SCREEN_WIDTH - 30, 10) content:[NSString stringWithFormat:@"您已答复求职者%@，10积分已放入您的账户，发送面试通知还会赠送10积分哟~（重复不赠送）", self.paName] size:DEFAULTFONTSIZE color:nil spacing:10];
            NSMutableAttributedString *tipString = [[NSMutableAttributedString alloc] initWithString:lbTip.text];
            [tipString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, tipString.length)];
            [tipString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(7, self.paName.length)];
            [tipString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(tipString.length - 35, 2)];
            [tipString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(tipString.length - 13, 2)];
            [lbTip setAttributedText:tipString];
            [viewContent addSubview:lbTip];
            
            UIButton *btnInterview = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbTip) + 20, 120, 40)];
            [btnInterview setTitle:@"发送面试通知" forState:UIControlStateNormal];
            [btnInterview addTarget:self action:@selector(interview) forControlEvents:UIControlEventTouchUpInside];
            [btnInterview.titleLabel setFont:DEFAULTFONT];
            [btnInterview setBackgroundColor:CPNAVBARCOLOR];
            [btnInterview.layer setCornerRadius:5];
            [viewContent addSubview:btnInterview];
            
            [viewContent setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnInterview) + 30)];
            [viewTitle setCenter:CGPointMake(VIEW_W(viewContent) / 2, viewTitle.center.y)];
            [btnInterview setCenter:CGPointMake(VIEW_W(viewContent) / 2, btnInterview.center.y)];
            
            self.popView = [[WKPopView alloc] initWithCustomView:viewContent];
            [self.popView setDelegate:self];
            [self.popView showPopView:self.viewController];
        }
        else {
            UIView *viewContent = [[UIView alloc] init];
            
            WKLabel *lbTitle = [[WKLabel alloc] initWithFrame:CGRectMake(0, 20, SCREEN_WIDTH, 20) content:@"您处理的简历已被放在 “储备人才库” 里啦！" size:BIGGERFONTSIZE color:NAVBARCOLOR];
            [lbTitle setTextAlignment:NSTextAlignmentCenter];
            [viewContent addSubview:lbTitle];
            
            WKLabel *lbTip = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbTitle) + 15, SCREEN_WIDTH - 30, 10) content:[NSString stringWithFormat:@"您已答复求职者%@，10积分已放入您的账户，选择原因还会赠送5积分哟~（重复不赠送）", self.paName] size:DEFAULTFONTSIZE color:nil spacing:10];
            NSMutableAttributedString *tipString = [[NSMutableAttributedString alloc] initWithString:lbTip.text];
            [tipString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, tipString.length)];
            [tipString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(7, self.paName.length)];
            [tipString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(tipString.length - 32, 2)];
            [tipString addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(tipString.length - 12, 1)];
            [lbTip setAttributedText:tipString];
            [viewContent addSubview:lbTip];
            
            WKLabel *lbReason = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, VIEW_BY(lbTip) + 20, SCREEN_WIDTH, 20) content:@"原因是：" size:DEFAULTFONTSIZE color:nil];
            [viewContent addSubview:lbReason];
            
            NSArray *arrayReason = @[@"专业不合适", @"工作履历不符", @"薪资要求过高", @"行业差距较大", @"项目经验偏少", @"岗位已满"];
            float widthForButton = (SCREEN_WIDTH - 90) / 2;
            float heightForView = VIEW_BY(lbReason);
            float heightForButton = 40;
            for (NSInteger index = 0; index < arrayReason.count; index++) {
                CGRect frame = CGRectMake(30, heightForView + 15, widthForButton, heightForButton);
                if (index % 2 == 1) {
                    frame.origin.x = 60 + widthForButton;
                }
                UIButton *btnReason = [[UIButton alloc] initWithFrame:frame];
                [btnReason setTitle:[arrayReason objectAtIndex:index] forState:UIControlStateNormal];
                [btnReason setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                [btnReason.titleLabel setFont:DEFAULTFONT];
                [btnReason setBackgroundColor:SEPARATECOLOR];
                [btnReason addTarget:self action:@selector(reasonClick:) forControlEvents:UIControlEventTouchUpInside];
                [viewContent addSubview:btnReason];
                if (index % 2 == 1) {
                    heightForView = VIEW_BY(btnReason);
                }
            }
            WKLabel *lbCustom = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbReason), heightForView + 25, SCREEN_WIDTH, 20) content:@"自定义" size:DEFAULTFONTSIZE color:nil];
            [viewContent addSubview:lbCustom];
            
            self.txtReason = [[UITextField alloc] initWithFrame:CGRectMake(VIEW_BX(lbCustom) + 10, VIEW_Y(lbCustom) - 10, 200, 40)];
            self.txtReason.layer.borderWidth = 1.0f;
            self.txtReason.layer.borderColor = [SEPARATECOLOR CGColor];
            [self.txtReason setDelegate:self];
            [self.txtReason setReturnKeyType:UIReturnKeyDone];
            [viewContent addSubview:self.txtReason];
            
            WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(self.txtReason) + 15, SCREEN_WIDTH - 30, 10) content:@"但我们会关注您的简历，以后有合适的职位我们会与您联系。" size:DEFAULTFONTSIZE color:nil spacing:10];
            [viewContent addSubview:lbWarning];
            
            [viewContent setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbWarning) + 35)];
            self.popView = [[WKPopView alloc] initWithCustomView:viewContent];
            [self.popView setDelegate:self];
            [self.popView showPopView:self.viewController];
        }
    }
    else if (request.tag == CvOperateNetChatPrivi) {
        if ([result isEqualToString:@"1"]) { //直接进入
            [self gotoChat:@""];
        }
        else if ([result isEqualToString:@"2"]) { //选择职位
            [self getValidJob];
        }
        else {
            [self popDownload:result];
        }
    }
    else if (request.tag == CvOperateNetValidJob) {
        NSString *noJobTips = @"";
        NSString *popTips = @"";
        NSString *popTitle = @"";
        if (self.operateType == CvOperateTypeChat) {
            noJobTips = @"无法和TA聊聊";
            popTitle = @"请选择意向职位";
        }
        else if (self.operateType == CvOperateTypeInvitation) {
            noJobTips = @"无法给TA发送应聘邀请";
            popTitle = @"请选择意向职位";
            popTips = @"发送应聘邀请需要5个积分，求职者72小时内没有申请该职位则返还";
        }
        else if (self.operateType == CvOperateTypeInterview) {
            noJobTips = @"无法给TA发送面试通知";
        }
        else if (self.operateType == CvOperateTypeFavorite) {
            noJobTips = @"无法收藏TA的简历";
            popTitle = @"请选择意向职位";
        }
        NSArray *arrJob = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrJob.count == 0) {
            [self.viewController.view.window makeToast:[NSString stringWithFormat:@"您还没有发布中的职位，%@", noJobTips]];
        }
        else if (arrJob.count == 1 && self.operateType != CvOperateTypeInvitation) {
            NSDictionary *data = [arrJob objectAtIndex:0];
            if (self.operateType == CvOperateTypeChat) {
                [self gotoChat:[data objectForKey:@"ID"]];
            }
            else if (self.operateType == CvOperateTypeFavorite) {
                [self gotoFavorite:[data objectForKey:@"ID"]];
            }
        }
        else {
            Boolean matchJob = NO;
            NSMutableArray *arrayPop = [[NSMutableArray alloc] init];
            for (NSInteger i = 0; i < arrJob.count; i++) {
                NSDictionary *data = [arrJob objectAtIndex:i];
                if ([self.jobId isEqualToString:[data objectForKey:@"ID"]]) {
                    matchJob = YES;
                }
                [arrayPop addObject:[NSDictionary dictionaryWithObjectsAndKeys:[data objectForKey:@"ID"], @"id", [data objectForKey:@"Name"], @"value", nil]];
            }
            if (matchJob) {
                if (self.operateType == CvOperateTypeChat) {
                    [self gotoChat:self.jobId];
                    return;
                }
            }
            WKLabel *lbTips;
            if (popTips.length > 0) {
                lbTips = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 15, SCREEN_WIDTH - 30, 10) content:popTips size:DEFAULTFONTSIZE color:nil spacing:10];
                if (self.operateType == CvOperateTypeInvitation) {
                    NSMutableAttributedString *tipsString = [[NSMutableAttributedString alloc] initWithString:lbTips.text];
                    [tipsString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(8, 1)];
                    [tipsString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, tipsString.length)];
                    [lbTips setAttributedText:tipsString];
                }
            }
            self.popView = [[WKPopView alloc] initWithArray:arrayPop value:@"" title:popTitle tipsLable:lbTips];
            [self.popView setDelegate:self];
            [self.popView showPopView:self.viewController];
        }
    }
    else if (request.tag == CvOperateNetReplyReason) {
        [self.viewController.view.window makeToast:@"答复简历成功"];
    }
    else if (request.tag == CvOperateNetDownload) {
        if (self.operateType == CvOperateTypeChat) {
            [self beginChat];
        }
        else if (self.operateType == CvOperateTypeInterview) {
            [self interview];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(cvOperateFinished)]) {
            [self.delegate cvOperateFinished];
        }
    }
    else if (request.tag == CvOperateNetInvitation) {
        if ([result isEqualToString:@"1"]) {
            [self.viewController.view.window makeToast:@"发送应聘邀请成功"];
        }
        else {
            [self.viewController.view.window makeToast:@"您在30内对该简历发送过应聘邀请，不能重复发送"];
        }
    }
    else if (request.tag == CvOperateNetFavorite) {
        [self.viewController.view.window makeToast:@"简历收藏成功"];
    }
    else if (request.tag == CvOperateNetInterview) {
        NSDictionary *otherData = [[Common getArrayFromXml:requestData tableName:@"dtReceiveSmsNumDt"] objectAtIndex:0];
        if ([[otherData objectForKey:@"CvNotice"] length] > 0) {
            [self popDownload:[otherData objectForKey:@"CvNotice"]];
            return;
        }
        NSArray *arrJob = [Common getArrayFromXml:requestData tableName:@"dtJob"];
        if (arrJob.count == 0) {
            [self.viewController.view.window makeToast:@"您还没有发布中的职位，无法发送面试通知"];
            return;
        }
        InterviewSendViewController *interViewSendCtrl = [[UIStoryboard storyboardWithName:@"Company" bundle:nil] instantiateViewControllerWithIdentifier:@"interviewSendView"];
        interViewSendCtrl.cvMainId = self.cvMainId;
        interViewSendCtrl.paName = self.paName;
        interViewSendCtrl.jobId = self.jobId;
        interViewSendCtrl.arrayJob = [arrJob mutableCopy];
        interViewSendCtrl.arrayTemplate = [[Common getArrayFromXml:requestData tableName:@"dtTemplate"] mutableCopy];
        interViewSendCtrl.otherData = otherData;
        [self.viewController.navigationController pushViewController:interViewSendCtrl animated:YES];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textField convertRect:textField.bounds toView:window];
    float fltBY = rect.origin.y + rect.size.height;
    if (SCREEN_HEIGHT - fltBY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = self.viewController.view.window.frame;
            frameView.origin.y = SCREEN_HEIGHT - fltBY - KEYBOARD_HEIGHT;
            [self.viewController.view.window setFrame:frameView];
        }];
    }
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.viewController.view.window.frame;
        frameView.origin.y = 0;
        [self.viewController.view.window setFrame:frameView];
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
