//
//  ChatListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/22.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ChatListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "ChatViewController.h"
#import "WKLoginView.h"

@interface ChatListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) WKLoginView *loginView;
@end

@implementation ChatListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"聊聊";
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    if (!PERSONLOGIN) {
        if (self.loginView == nil) {
            self.loginView = [[WKLoginView alloc] initLoginView:self];
        }
        [self.view addSubview:self.loginView];
        return;
    }
    [self.loginView removeFromSuperview];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetPaChatList" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    self.arrData = [Common getArrayFromXml:requestData tableName:@"Table"];
    [self.tableView reloadData];
    if (self.arrData.count == 0) {
        [[self.tableView viewWithTag:NODATAVIEWTAG] setHidden:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:self.tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
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
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[data objectForKey:@"PhotoUrl"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [imgLogo.layer setMasksToBounds:YES];
    [imgLogo.layer setCornerRadius:(VIEW_W(imgLogo) / 2)];
    [cell.contentView addSubview:imgLogo];
    
    if ([[data objectForKey:@"OnlineStatus"] isEqualToString:@"0"]) {
        UIView *viewMask = [[UIView alloc] initWithFrame:imgLogo.frame];
        [viewMask setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
        [cell.contentView addSubview:viewMask];
    }
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30;
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo), maxWidth - 100, 25) content:[data objectForKey:@"Name"] size:BIGGERFONTSIZE color:nil];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, VIEW_Y(lbCompany), 85, VIEW_H(lbCompany)) content:[Common stringFromDateString:[data objectForKey:@"LastSendDate"] formatType:@"MM-dd HH:mm"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    
    WKLabel *lbMessage = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth - ([[data objectForKey:@"NoViewedNum"] integerValue] > 0 ? 35 : 0), 25) content:[data objectForKey:@"Message"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbMessage setTextAlignment:NSTextAlignmentCenter];
    [cell.contentView addSubview:lbMessage];
    
    if ([[data objectForKey:@"NoViewedNum"] integerValue] > 0) {
        WKLabel *lbCount = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 35, VIEW_Y(lbMessage) + 5, 15, 15) content:[data objectForKey:@"NoViewedNum"] size:10 color:[UIColor whiteColor]];
        [lbCount setBackgroundColor:NAVBARCOLOR];
        [lbCount setTextAlignment:NSTextAlignmentCenter];
        [lbCount.layer setMasksToBounds:YES];
        [lbCount.layer setCornerRadius:VIEW_H(lbCount) / 2];
        [cell.contentView addSubview:lbCount];
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbMessage) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.row];
    ChatViewController *chatCtrl = [[ChatViewController alloc] init];
    chatCtrl.title = [data objectForKey:@"Name"];
    chatCtrl.cvMainId = [data objectForKey:@"cvMainID"];
    chatCtrl.caMainId = [data objectForKey:@"caMainID"];
    [self.navigationController pushViewController:chatCtrl animated:YES];
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
