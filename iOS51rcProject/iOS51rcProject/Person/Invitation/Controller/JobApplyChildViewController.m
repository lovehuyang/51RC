//
//  JobApplyChildViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/16.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobApplyChildViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "MJRefresh.h"
#import "UIView+Toast.h"
#import "WKTableView.h"
#import "JobViewController.h"
#import "WKNavigationController.h"
#import "AlertView.h"
#import "OnlineLab.h"

@interface JobApplyChildViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSMutableArray *arrData;
@property (nonatomic, strong) UIButton *activeButton;
@property NSInteger page;
@end

@implementation JobApplyChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有\n多申请职位可以增加就业机会哦~"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.page++;
        [self getData];
    }];
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        self.page = 1;
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
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [NSString stringWithFormat:@"%ld", self.page], @"page", [NSString stringWithFormat:@"%d", self.replyStatus], @"status", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [SVProgressHUD dismiss];
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        if (self.page == 1) {
            [self.arrData removeAllObjects];
        }
        NSArray *arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
        [self.arrData addObjectsFromArray:arrayData];
        
        if (arrayData.count < 20) {
            if (self.page == 1) {
                [self.tableView.mj_footer removeFromSuperview];
                if (arrayData.count == 0) {
                    [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
                }
            }
        }
        [self.tableView reloadData];
        
    }
    else {
        [self.activeButton setTag:1];
        [self.view makeToast:@"提醒企业成功，请耐心等待..."];
        for (UIView *view in self.activeButton.subviews) {
            if ([view isKindOfClass:[UIImageView class]]) {
                UIImageView *imgRemind = (UIImageView *)view;
                [imgRemind setImage:[UIImage imageNamed:@"pa_remind1.png"]];
            }
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    if (![[data objectForKey:@"JobValid"] boolValue]) {
        return;
    }
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = [data objectForKey:@"JobID"];
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
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
    
    //30是左右间距15，50是右侧答复宽度，15是最右边间距
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30 - 50 - 15;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, 10, maxWidth, 20) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [cell.contentView addSubview:onlineLab];
        
        // “聊”图标
//        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 16, 16)];
//        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
//        [cell.contentView addSubview:imgOnline];
    }
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth, 20) content:[data objectForKey:@"cpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"申请时间：%@", [Common stringFromDateString:[data objectForKey:@"AddDate"] formatType:@"MM-dd HH:mm"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDate];
    
    CGRect rectStatus = CGRectMake(SCREEN_WIDTH - 65, 30, 50, 15);
    if ([[data objectForKey:@"Reply"] isEqualToString:@"0"]) {
        Boolean hasRemind = ([[data objectForKey:@"RemindDate"] length] > 0);
        UIButton *btnRemind = [[UIButton alloc] initWithFrame:CGRectMake(rectStatus.origin.x, 0, rectStatus.size.width, VIEW_BY(lbDate))];
        [btnRemind setTag:(hasRemind ? 1 : 0)];
        [btnRemind setTitle:[data objectForKey:@"ID"] forState:UIControlStateNormal];
        [btnRemind setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnRemind addTarget:self action:@selector(remindCompany:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btnRemind];
        
        UIImageView *imgRemind = [[UIImageView alloc] initWithFrame:CGRectMake(12, 12, 26, 26)];
        [imgRemind setImage:[UIImage imageNamed:[NSString stringWithFormat:@"pa_remind%@.png", (hasRemind ? @"1" : @"2")]]];
        [btnRemind addSubview:imgRemind];
        [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDate) + 10)];
        
        rectStatus = CGRectMake(VIEW_X(btnRemind), VIEW_BY(imgRemind) + 10, VIEW_W(btnRemind), 15);
    }
    
    NSString *statusString = @"";
    UIColor *statusColor = NAVBARCOLOR;
    switch ([[data objectForKey:@"Reply"] intValue]) {
        case 0:
            statusColor = TEXTGRAYCOLOR;
            statusString = @"未查看";
            if ([[data objectForKey:@"ViewDate"] length] > 0) {
                statusString = @"待答复";
            }
            break;
        case 1:
            statusColor = GREENCOLOR;
            statusString = @"符合要求";
            break;
        case 2:
            statusString = @"不合适";
            break;
        case 3:
            statusString = @"以后联系";
            break;
        case 4:
            statusString = @"系统回复";
            break;
        case 5:
            statusString = @"不合适";
            break;
        default:
            break;
    }
    WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:rectStatus content:statusString size:10 color:statusColor];
    [lbStatus setTextAlignment:NSTextAlignmentCenter];
    [lbStatus.layer setBorderColor:[statusColor CGColor]];
    [lbStatus.layer setBorderWidth:1];
    [lbStatus.layer setCornerRadius:5];
    [cell.contentView addSubview:lbStatus];
    
    if (self.replyStatus > 2) {
        [lbStatus setHidden:YES];
    }
    
    if (![[data objectForKey:@"JobValid"] boolValue]) {
        UIImageView *imgJobExpired = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [imgJobExpired setImage:[UIImage imageNamed:@"pa_jobexpired.png"]];
        [cell.contentView addSubview:imgJobExpired];
    }
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDate) + 5, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPressEvent:)];
    longPress.minimumPressDuration = 1;
    [cell.contentView addGestureRecognizer:longPress];
    return cell;
}

#pragma mark - 长按手势

- (void)longPressEvent:(UILongPressGestureRecognizer *)longPress{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        
        CGPoint point = [longPress locationInView:_tableView];
        NSIndexPath *indexPath = [_tableView indexPathForRowAtPoint:point]; // 可以获取我们在哪个cell上长按
        if (indexPath != nil) {
            
            AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
            __weak __typeof(alertView)WeakAlertView = alertView;
            [WeakAlertView initWithTitle:@"提示" content:@"确定要删除此申请记录吗？" btnTitleArr:@[@"取消",@"确定"] canDismiss:YES];
            WeakAlertView.clickButtonBlock = ^(UIButton *button) {
                if (button.tag == 101) {
                    [self deleteApply:indexPath];
                }
            };
            [WeakAlertView show];
        }
    }
}

- (void)remindCompany:(UIButton *)button {
    if (button.tag == 1) {
        return;
    }
    self.activeButton = button;
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"RemindJobApply" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", button.titleLabel.text, @"applyID", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

#pragma mark - 删除申请记录
- (void)deleteApply:(NSIndexPath *)indexPath{
    [SVProgressHUD show];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    NSDictionary *paramDict = @{@"applyID":data[@"ID"],
                                @"paMainID":PAMAINID,
                                @"code":[USER_DEFAULT objectForKey:@"paMainCode"]
                                };
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_DELETEJOBAPPLY tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        
        BOOL result = [(NSString *)dataDict isEqualToString:@"1"];
        if (result) {// 删除成功
            [SVProgressHUD dismiss];
            [self.arrData removeObjectAtIndex:indexPath.row];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationMiddle];
            
        }else{// 删除失败
            [SVProgressHUD dismiss];
        }
        DLog(@"");
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

@end
