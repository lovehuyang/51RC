//
//  InterviewViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/20.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "InterviewViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "WKPopView.h"
#import "WKTextView.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "UIView+Toast.h"
#import "WKTableView.h"
#import "WKNavigationController.h"
#import "JobViewController.h"

@interface InterviewViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate, WKPopViewDelegate, UITextViewDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) WKTextView *txtRemark;
@property NSInteger replyStatus;
@property NSInteger interViewId;
@property NSInteger page;
@end

@implementation InterviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n多申请职位可以增加就业机会哦~"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    [self.view addSubview:self.tableView];
    
    self.arrData = [[NSMutableArray alloc] init];
    self.page = 1;
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetInterview" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.page], @"page", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
        [self.arrData addObjectsFromArray:arrayData];
        [self.tableView reloadData];
        if (arrayData.count < 20) {
            if (self.page == 1) {
                [self.tableView.mj_footer removeFromSuperview];
                if (arrayData.count == 0) {
                    [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
                }
            }
            else {
                [self.tableView.mj_footer endRefreshingWithNoMoreData];
            }
        }
        else {
            [self.tableView.mj_footer endRefreshing];
        }
    }
    else {
        self.page = 1;
        [self.arrData removeAllObjects];
        [self getData];
        [self.view makeToast:@"答复面试通知成功"];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrData.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[data objectForKey:@"LogoUrl"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [cell.contentView addSubview:imgLogo];
    
    Boolean hasReply = ![[data objectForKey:@"Reply"] isEqualToString:@"0"];
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30 - 75 - 15;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo), maxWidth + (hasReply ? 0 : 90), 25) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 5, 15, 15)];
        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
        [cell.contentView addSubview:imgOnline];
    }
    
    if (![[data objectForKey:@"JobValid"] boolValue]) {
        UIImageView *imgJobExpired = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imgJobExpired setImage:[UIImage imageNamed:@"pa_jobexpired.png"]];
        [cell.contentView addSubview:imgJobExpired];
    }
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth, 25) content:[data objectForKey:@"cpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, VIEW_Y(lbCompany), 85, 25) content:[Common stringFromDateString:[data objectForKey:@"AddDate"] formatType:@"MM-dd HH:mm"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentLeft];
    [cell.contentView addSubview:lbDate];
    
    if (![[data objectForKey:@"Reply"] isEqualToString:@"0"]) {
        NSString *statusString = @"";
        UIColor *statusColor;
        switch ([[data objectForKey:@"Reply"] intValue]) {
            case 1:
                statusColor = GREENCOLOR;
                statusString = @"赴约";
                break;
            case 2:
                statusColor = NAVBARCOLOR;
                statusString = @"不赴约";
                break;
            default:
                break;
        }
        WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 77, VIEW_Y(lbJob) + 5, 50, 15) content:statusString size:10 color:statusColor];
        [lbStatus setTextAlignment:NSTextAlignmentCenter];
        [lbStatus.layer setBorderColor:[statusColor CGColor]];
        [lbStatus.layer setBorderWidth:1];
        [lbStatus.layer setCornerRadius:5];
        [cell.contentView addSubview:lbStatus];
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(imgLogo) + 15, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    UIButton *btnJob = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_Y(viewSeparate))];
    [btnJob setBackgroundColor:[UIColor clearColor]];
    [btnJob setTag:indexPath.section];
    [btnJob addTarget:self action:@selector(jobClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnJob];
    
    //面试时间
    WKLabel *lbTimeTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(viewSeparate) + 15, 500, 20) content:@"面试时间：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [lbTimeTitle setFrame:CGRectMake((IS_IPHONE_6Plus ? 100 : 85) - VIEW_W(lbTimeTitle), VIEW_Y(lbTimeTitle), VIEW_W(lbTimeTitle), VIEW_H(lbTimeTitle))];
    [cell.contentView addSubview:lbTimeTitle];
    
    WKLabel *lbTime = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbTimeTitle), VIEW_Y(lbTimeTitle), SCREEN_WIDTH - VIEW_BX(lbTimeTitle) - 15, 20) content:[data objectForKey:@"InterviewDate"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbTime];
    
    //面试地点
    WKLabel *lbAddressTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbTime) + 15, 500, 20) content:@"面试地点：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [lbAddressTitle setFrame:CGRectMake((IS_IPHONE_6Plus ? 100 : 85) - VIEW_W(lbAddressTitle), VIEW_Y(lbAddressTitle), VIEW_W(lbAddressTitle), VIEW_H(lbAddressTitle))];
    [cell.contentView addSubview:lbAddressTitle];
    
    WKLabel *lbAddress = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbAddressTitle), VIEW_Y(lbAddressTitle), SCREEN_WIDTH - VIEW_BX(lbAddressTitle) - 15, 20) content:[data objectForKey:@"InterViewPlace"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbAddress];
    
    //联系人
    WKLabel *lbLinkmanTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbAddress) + 15, 500, 20) content:@"联系人：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [lbLinkmanTitle setFrame:CGRectMake((IS_IPHONE_6Plus ? 100 : 85) - VIEW_W(lbLinkmanTitle), VIEW_Y(lbLinkmanTitle), VIEW_W(lbLinkmanTitle), VIEW_H(lbLinkmanTitle))];
    [cell.contentView addSubview:lbLinkmanTitle];
    
    WKLabel *lbLinkman = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbLinkmanTitle), VIEW_Y(lbLinkmanTitle), SCREEN_WIDTH - VIEW_BX(lbLinkmanTitle) - 15, 20) content:[data objectForKey:@"LinkMan"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbLinkman];
    
    //联系电话
    WKLabel *lbPhoneTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(lbLinkman) + 15, 500, 20) content:@"联系电话：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
    [lbPhoneTitle setFrame:CGRectMake((IS_IPHONE_6Plus ? 100 : 85) - VIEW_W(lbPhoneTitle), VIEW_Y(lbPhoneTitle), VIEW_W(lbPhoneTitle), VIEW_H(lbPhoneTitle))];
    [cell.contentView addSubview:lbPhoneTitle];
    
    WKLabel *lbPhone = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbPhoneTitle), VIEW_Y(lbPhoneTitle), SCREEN_WIDTH - VIEW_BX(lbPhoneTitle) - 15, 20) content:[data objectForKey:@"Telephone"] size:DEFAULTFONTSIZE color:nil spacing:0];
    [cell.contentView addSubview:lbPhone];
    
    float heightForCell = VIEW_BY(lbPhone) + 15;
    if ([[data objectForKey:@"Remark"] length] > 0) {
        //备注
        WKLabel *lbRemarkTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, heightForCell, 500, 20) content:@"备注：" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:0];
        [lbRemarkTitle setFrame:CGRectMake((IS_IPHONE_6Plus ? 100 : 85) - VIEW_W(lbRemarkTitle), VIEW_Y(lbRemarkTitle), VIEW_W(lbRemarkTitle), VIEW_H(lbRemarkTitle))];
        [cell.contentView addSubview:lbRemarkTitle];
        
        WKLabel *lbRemark = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_BX(lbRemarkTitle), VIEW_Y(lbRemarkTitle), SCREEN_WIDTH - VIEW_BX(lbRemarkTitle) - 15, 20) content:[data objectForKey:@"Remark"] size:DEFAULTFONTSIZE color:nil spacing:0];
        [cell.contentView addSubview:lbRemark];

        heightForCell = VIEW_BY(lbRemark) + 15;
    }
    
    if ([[data objectForKey:@"Reply"] isEqualToString:@"0"]) {
        UIView *viewSeparate2 = [[UIView alloc] initWithFrame:CGRectMake(15, heightForCell, SCREEN_WIDTH - 30, 1)];
        [viewSeparate2 setBackgroundColor:SEPARATECOLOR];
        [cell.contentView addSubview:viewSeparate2];
        
        UIButton *btnReply = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewSeparate2), SCREEN_WIDTH, 40)];
        [btnReply setTitle:@"答复" forState:UIControlStateNormal];
        [btnReply setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [btnReply.titleLabel setFont:BIGGERFONT];
        [btnReply setTag:[[data objectForKey:@"ID"] integerValue]];
        [btnReply addTarget:self action:@selector(replyInterview:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnReply];
        
        heightForCell = VIEW_BY(btnReply);
    }
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForCell)];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

- (void)jobClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = [data objectForKey:@"JobID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)replyInterview:(UIButton *)button {
    self.interViewId = button.tag;
    UIView *viewReply = [[UIView alloc] init];
    
    UIButton *btnReply1 = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 46)];
    [btnReply1 setTag:1];
    [btnReply1 addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewReply addSubview:btnReply1];
    
    self.replyStatus = 1;
    UIImageView *imgReply1 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 13, 20, 20)];
    [imgReply1 setTag:101];
    [imgReply1 setImage:[UIImage imageNamed:@"img_check1.png"]];
    [btnReply1 addSubview:imgReply1];
    
    WKLabel *lbReply1 = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgReply1) + 10, 13, 200, 20) content:@"赴约" size:BIGGERFONTSIZE color:nil];
    [btnReply1 addSubview:lbReply1];
    
    UIButton *btnReply2 = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(btnReply1), SCREEN_WIDTH, 46)];
    [btnReply2 setTag:2];
    [btnReply2 addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
    [viewReply addSubview:btnReply2];
    
    UIImageView *imgReply2 = [[UIImageView alloc] initWithFrame:CGRectMake(30, 13, 20, 20)];
    [imgReply2 setTag:102];
    [imgReply2 setImage:[UIImage imageNamed:@"img_check2.png"]];
    [btnReply2 addSubview:imgReply2];
    
    WKLabel *lbReply2 = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgReply2) + 10, 13, 200, 20) content:@"不赴约" size:BIGGERFONTSIZE color:nil];
    [btnReply2 addSubview:lbReply2];
    
    WKTextView *txtRemark = [[WKTextView alloc] initWithFrame:CGRectMake(25, VIEW_BY(btnReply2) + 10, SCREEN_WIDTH - 50, 80)];
    [txtRemark setDelegate:self];
    [txtRemark setTextContainerInset:UIEdgeInsetsMake(10.0f, 5.0f, 10.0f, 5.0f)];
    [txtRemark setPlaceholder:@"给企业留言"];
    [txtRemark.layer setBorderColor:[SEPARATECOLOR CGColor]];
    [txtRemark.layer setBorderWidth:1];
    [viewReply addSubview:txtRemark];
    self.txtRemark = txtRemark;
    
    [viewReply setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(txtRemark) + 10)];
    
    WKPopView *replyPop = [[WKPopView alloc] initWithCustomView:viewReply];
    [replyPop setDelegate:self];
    [replyPop showPopView:self];
}

- (void)replyClick:(UIButton *)button {
    self.replyStatus = button.tag;
    UIImageView *imgReply1 = (UIImageView *)[self.view viewWithTag:101];
    UIImageView *imgReply2 = (UIImageView *)[self.view viewWithTag:102];
    if (button.tag == 1) {
        [imgReply1 setImage:[UIImage imageNamed:@"img_check1.png"]];
        [imgReply2 setImage:[UIImage imageNamed:@"img_check2.png"]];
    }
    else {
        [imgReply1 setImage:[UIImage imageNamed:@"img_check2.png"]];
        [imgReply2 setImage:[UIImage imageNamed:@"img_check1.png"]];
    }
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    if (self.replyStatus == 2 && [self.txtRemark.text length] == 0) {
        [self.view makeToast:@"请输入不赴约的理由"];
        return;
    }
    [popView cancelClick];
    
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"ReplyInterView" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.interViewId], @"interviewId", [NSString stringWithFormat:@"%ld", self.replyStatus], @"reply", self.txtRemark.text, @"replyMessage", [USER_DEFAULT valueForKey:@"provinceId"], @"provinceId", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rect = [textView convertRect:textView.bounds toView:window];
    float fltBY = rect.origin.y + rect.size.height;
    if (SCREEN_HEIGHT - fltBY < KEYBOARD_HEIGHT) {
        [UIView animateWithDuration:0.5 animations:^{
            CGRect frameView = self.view.frame;
            frameView.origin.y = SCREEN_HEIGHT - fltBY - KEYBOARD_HEIGHT;
            [self.view setFrame:frameView];
        }];
    }
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView {
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
    return YES;
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
