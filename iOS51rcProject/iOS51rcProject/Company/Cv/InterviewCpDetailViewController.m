//
//  InterviewCpDetailViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "InterviewCpDetailViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"

@interface InterviewCpDetailViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@end

@implementation InterviewCpDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"面试通知";
    [self.view setBackgroundColor:SEPARATECOLOR];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpInterviewDetail" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", self.interViewId, @"intInterviewID", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillData:(NSDictionary *)data {
    for (UIView *view in self.view.subviews) {
        [view removeFromSuperview];
    }
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT))];
    [scrollView setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:scrollView];
    
    UIView *viewTop = [[UIView alloc] init];
    [viewTop setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:viewTop];
    
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 20, SCREEN_WIDTH, 20) content:[[data objectForKey:@"paName"] stringByReplacingOccurrencesOfString:@"$$##" withString:@""] size:BIGGERFONTSIZE color:nil];
    [viewTop addSubview:lbName];
    
    NSString *status = @"未答复";
    UIColor *statusColor = [UIColor blackColor];
    UIColor *statusBgColor = UIColorWithRGBA(202, 202, 202, 1);
    if ([[data objectForKey:@"Reply"] integerValue] == 1) {
        status = @"赴约";
        statusColor = [UIColor whiteColor];
        statusBgColor = GREENCOLOR;
    }
    else if ([[data objectForKey:@"Reply"] integerValue] == 2) {
        status = @"不赴约";
        statusColor = [UIColor whiteColor];
        statusBgColor = UIColorWithRGBA(243, 82, 78, 1);
    }
    WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, VIEW_Y(lbName), 60, 20) content:status size:SMALLERFONTSIZE color:statusColor];
    [lbStatus setTextAlignment:NSTextAlignmentCenter];
    [lbStatus setBackgroundColor:statusBgColor];
    [viewTop addSubview:lbStatus];
    
    NSString *workYears = @"";
    if ([[data objectForKey:@"RelatedWorkYears"] isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([[data objectForKey:@"RelatedWorkYears"] isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([[data objectForKey:@"RelatedWorkYears"] length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", [data objectForKey:@"RelatedWorkYears"]];
    }
    WKLabel *lbPaInfo = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbStatus) + 15, SCREEN_WIDTH - VIEW_X(lbName) * 2, 20) content:[NSString stringWithFormat:@"%@ | %@岁 | %@ | %@工作经验 | %@", ([[data objectForKey:@"Gender"] boolValue] ? @"女" : @"男"), [data objectForKey:@"Age"], [data objectForKey:@"DegreeName"], workYears, [data objectForKey:@"LivePlaceName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewTop addSubview:lbPaInfo];
    [viewTop setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbPaInfo) + 15)];
    
    UIView *viewMessage = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewTop), 0, 0)];
    if ([[data objectForKey:@"ReplyMessage"] length] > 0) {
        viewMessage = [[UIView alloc] init];
        [viewMessage setBackgroundColor:[UIColor whiteColor]];
        [scrollView addSubview:viewMessage];
        
        WKLabel *lbMessage = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), 20, SCREEN_WIDTH - VIEW_X(lbName) * 2, 10) content:[NSString stringWithFormat:@"%@：%@", ([[data objectForKey:@"Reply"] integerValue] == 1 ? @"留言" : @"不赴约理由"), [data objectForKey:@"ReplyMessage"]] size:DEFAULTFONTSIZE color:nil spacing:10];
        [viewMessage addSubview:lbMessage];
        [viewMessage setFrame:CGRectMake(0, VIEW_BY(viewTop) + 15, SCREEN_WIDTH, VIEW_BY(lbMessage) + 15)];
    }
    
    UIView *viewMiddle = [[UIView alloc] init];
    [viewMiddle setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:viewMiddle];
    
    WKLabel *lbInterviewDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), 15, 200, 20) content:@"面试时间：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbInterviewDateTitle];
    
    WKLabel *lbInterviewDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbInterviewDateTitle), VIEW_Y(lbInterviewDateTitle), SCREEN_WIDTH - VIEW_BX(lbInterviewDateTitle) - VIEW_X(lbName), 20) content:[data objectForKey:@"InterviewDate"] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbInterviewDate];
    
    WKLabel *lbInterviewJobTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbInterviewDate) + 15, 200, 20) content:@"面试职位：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbInterviewJobTitle];
    
    WKLabel *lbInterviewJob = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbInterviewJobTitle), VIEW_Y(lbInterviewJobTitle), SCREEN_WIDTH - VIEW_BX(lbInterviewJobTitle) - VIEW_X(lbName), 20) content:[NSString stringWithFormat:@"%@（%@）", [data objectForKey:@"JobName"], [data objectForKey:@"JobRegionName"]] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbInterviewJob];
    
    WKLabel *lbLinkmanTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbInterviewJob) + 15, 200, 20) content:@"联系人：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [lbLinkmanTitle setFrame:CGRectMake(VIEW_X(lbLinkmanTitle), VIEW_Y(lbLinkmanTitle), VIEW_W(lbInterviewJobTitle), VIEW_H(lbLinkmanTitle))];
    [lbLinkmanTitle setTextAlignment:NSTextAlignmentRight];
    [viewMiddle addSubview:lbLinkmanTitle];
    
    WKLabel *lbLinkman = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLinkmanTitle), VIEW_Y(lbLinkmanTitle), SCREEN_WIDTH - VIEW_BX(lbLinkmanTitle) - VIEW_X(lbName), 20) content:[data objectForKey:@"LinkMan"] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbLinkman];
    
    WKLabel *lbTelephoneTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbLinkman) + 15, 200, 20) content:@"联系电话：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbTelephoneTitle];
    
    WKLabel *lbTelephone = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbTelephoneTitle), VIEW_Y(lbTelephoneTitle), SCREEN_WIDTH - VIEW_BX(lbTelephoneTitle) - VIEW_X(lbName), 20) content:[data objectForKey:@"Telephone"] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewMiddle addSubview:lbTelephone];
    
    if ([[data objectForKey:@"Remark"] length] > 0) {
        WKLabel *lbRemarkTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbTelephone) + 15, 200, 20) content:@"备注：" size:DEFAULTFONTSIZE color:nil spacing:5];
        [lbRemarkTitle setFrame:CGRectMake(VIEW_X(lbRemarkTitle), VIEW_Y(lbRemarkTitle), VIEW_W(lbInterviewJobTitle), VIEW_H(lbRemarkTitle))];
        [lbRemarkTitle setTextAlignment:NSTextAlignmentRight];
        [viewMiddle addSubview:lbRemarkTitle];
        
        WKLabel *lbRemark = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbRemarkTitle), VIEW_Y(lbRemarkTitle), SCREEN_WIDTH - VIEW_BX(lbRemarkTitle) - VIEW_X(lbName), 20) content:[data objectForKey:@"Remark"] size:DEFAULTFONTSIZE color:nil spacing:5];
        [viewMiddle addSubview:lbRemark];
        [viewMiddle setFrame:CGRectMake(0, VIEW_BY(viewMessage) + 15, SCREEN_WIDTH, VIEW_BY(lbRemark) + 15)];
    }
    else {
        [viewMiddle setFrame:CGRectMake(0, VIEW_BY(viewMessage) + 15, SCREEN_WIDTH, VIEW_BY(lbTelephone) + 15)];
    }
    
    UIView *viewDate = [[UIView alloc] init];
    [viewDate setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:viewDate];
    
    WKLabel *lbAddDateTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), 15, 200, 20) content:@"通知时间：" size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewDate addSubview:lbAddDateTitle];
    
    WKLabel *lbAddDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbAddDateTitle), VIEW_Y(lbAddDateTitle), SCREEN_WIDTH - VIEW_BX(lbAddDateTitle) - VIEW_X(lbName), 20) content:[Common stringFromDateString:[data objectForKey:@"AddDate"] formatType:@"yyyy-MM-dd"] size:DEFAULTFONTSIZE color:nil spacing:5];
    [viewDate addSubview:lbAddDate];
    [viewDate setFrame:CGRectMake(0, VIEW_BY(viewMiddle) + 15, SCREEN_WIDTH, VIEW_BY(lbAddDate) + 15)];
    
    UIView *viewBottom = [[UIView alloc] init];
    [viewBottom setBackgroundColor:[UIColor whiteColor]];
    [scrollView addSubview:viewBottom];
    
    NSDate *addDate = [Common dateFromString:[data objectForKey:@"AddDate"]];
    NSDate *nowDate = [[NSDate alloc] init];
    NSTimeInterval tiNowDate = [nowDate timeIntervalSince1970] * 1;
    NSTimeInterval tiAddDate = [addDate timeIntervalSince1970] * 1;
    NSTimeInterval interval = tiNowDate - tiAddDate;
    int intervalDay = (int)interval / (24 * 3600);
    if ([[data objectForKey:@"Result"] length] == 0) {
        if ([[data objectForKey:@"Reply"] integerValue] == 1 || intervalDay >= 1) {
            UIButton *btnNoPass = [[UIButton alloc] initWithFrame:CGRectMake(30, 15, (SCREEN_WIDTH - 80) / 2, 40)];
            [btnNoPass setBackgroundColor:UIColorWithRGBA(100, 39, 197, 1)];
            [btnNoPass setTitle:@"不录用" forState:UIControlStateNormal];
            [btnNoPass setTag:0];
            [btnNoPass.titleLabel setFont:DEFAULTFONT];
            [btnNoPass.titleLabel setTextColor:[UIColor whiteColor]];
            [btnNoPass addTarget:self action:@selector(passClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewBottom addSubview:btnNoPass];
            
            UIButton *btnPass = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnNoPass) + 20, VIEW_Y(btnNoPass), VIEW_W(btnNoPass), VIEW_H(btnNoPass))];
            [btnPass setBackgroundColor:GREENCOLOR];
            [btnPass setTitle:@"录用" forState:UIControlStateNormal];
            [btnPass setTag:1];
            [btnPass.titleLabel setFont:DEFAULTFONT];
            [btnPass.titleLabel setTextColor:[UIColor whiteColor]];
            [btnPass addTarget:self action:@selector(passClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewBottom addSubview:btnPass];
            [viewBottom setFrame:CGRectMake(0, VIEW_BY(viewDate) + 15, SCREEN_WIDTH, VIEW_BY(btnPass) + 15)];
        }
        else {
            viewBottom = nil;
        }
    }
    else if ([[data objectForKey:@"Result"] boolValue]) {
        WKLabel *lbResult = [[WKLabel alloc] initWithFixedHeight:CGRectMake(20, 15, 500, 40) content:[NSString stringWithFormat:@"录用[%@]", [Common stringFromDateString:[data objectForKey:@"ResultDate"] formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:GREENCOLOR];
        [viewBottom addSubview:lbResult];
        [viewBottom setFrame:CGRectMake(0, VIEW_BY(viewDate) + 15, SCREEN_WIDTH, VIEW_BY(lbResult) + 15)];
    }
    else if (![[data objectForKey:@"Result"] boolValue]) {
        WKLabel *lbResult = [[WKLabel alloc] initWithFixedHeight:CGRectMake(20, 15, 500, 40) content:[NSString stringWithFormat:@"不录用[%@]", [Common stringFromDateString:[data objectForKey:@"ResultDate"] formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
        [viewBottom addSubview:lbResult];
        [viewBottom setFrame:CGRectMake(0, VIEW_BY(viewDate) + 15, SCREEN_WIDTH, VIEW_BY(lbResult) + 15)];
    }
    if (viewBottom == nil) {
        [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(viewDate))];
    }
    else {
        [scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(viewBottom))];
    }
}

- (void)passClick:(UIButton *)button {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UpdateCpInterviewReply" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", self.interViewId, @"strInterviewID", [NSString stringWithFormat:@"%ld", button.tag], @"strResult", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table1"];
        if (arrayData.count > 0) {
            [self fillData:[arrayData objectAtIndex:0]];
        }
    }
    else {
        [self getData];
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
