//
//  AccountListViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/4.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "AccountListViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "NetWebServiceRequest.h"
#import "WKTableView.h"
#import "PreviewViewController.h"
#import "WKNavigationController.h"
#import "OrderApplyViewController.h"
#import "AccountSafeViewController.h"
#import "AccountInfoViewController.h"

@interface AccountListViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) WKTableView *tableView;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) NSDictionary *companyData;

@end

@implementation AccountListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView = [[WKTableView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT * 2) style:UITableViewStylePlain noDataMsg:@"呀！啥都没有"];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetAccountList" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainId", CAMAINCODE, @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        self.arrData = [Common getArrayFromXml:requestData tableName:@"dtList"];
        self.companyData = [[Common getArrayFromXml:requestData tableName:@"dtCp"] objectAtIndex:0];
        [self.tableView reloadData];
    }
    else {
        [self getData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 50;
    }
    return 10;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        UIView *viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [viewContent setBackgroundColor:[UIColor whiteColor]];
        WKLabel *lbUserCount = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 0, SCREEN_WIDTH, 40) content:[NSString stringWithFormat:@"当前用户数配额为%@个", [self.companyData objectForKey:@"MaxUserNumber"]] size:DEFAULTFONTSIZE color:nil];
        NSMutableAttributedString *userCountString = [[NSMutableAttributedString alloc] initWithString:lbUserCount.text];
        [userCountString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(8, [[self.companyData objectForKey:@"MaxUserNumber"] length])];
        [lbUserCount setAttributedText:userCountString];
        [viewContent addSubview:lbUserCount];
        
        WKButton *btnBuy = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(SCREEN_WIDTH - 100, 0, 85, VIEW_H(lbUserCount)) image:@"cp_accountbuy.png" title:@"购买用户数" fontSize:DEFAULTFONTSIZE color:NAVBARCOLOR bgColor:nil];
        [btnBuy addTarget:self action:@selector(buyClick) forControlEvents:UIControlEventTouchUpInside];
        [viewContent addSubview:btnBuy];
        
        UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbUserCount), SCREEN_WIDTH, 10)];
        [viewTitle setBackgroundColor:SEPARATECOLOR];
        [viewContent addSubview:viewTitle];
        
        return viewContent;
    }
    UIView *viewTitle = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
    [viewTitle setBackgroundColor:SEPARATECOLOR];
    return viewTitle;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.arrData.count;
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
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 15, SCREEN_WIDTH - 80, 10) content:[NSString stringWithFormat:@"\u3000用户名：%@ [%@]\n\u3000\u3000姓名：%@\n电子邮箱：%@\n\u3000手机号：%@", [data objectForKey:@"UserName"], ([[data objectForKey:@"AccountType"] isEqualToString:@"1"] ? @"管理员" : @"普通用户"), [data objectForKey:@"Name"], [data objectForKey:@"EMail"], [data objectForKey:@"Mobile"]] size:DEFAULTFONTSIZE color:nil spacing:10];
    NSMutableAttributedString *detailString = [[NSMutableAttributedString alloc] initWithString:lbDetail.text];
    [detailString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange([lbDetail.text rangeOfString:@"["].location, ([[data objectForKey:@"AccountType"] isEqualToString:@"1"] ? 3 : 4) + 2)];
    [detailString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, detailString.length)];
    [lbDetail setAttributedText:detailString];
    [cell.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    float widthForButton = SCREEN_WIDTH / 2;
    bool canOperate = NO;
    if ([[data objectForKey:@"AccountType"] isEqualToString:@"2"] && [[USER_DEFAULT objectForKey:@"AccountType"] isEqualToString:@"1"]) {
        canOperate = YES;
    }
    if (canOperate) {
        widthForButton = SCREEN_WIDTH / 3;
        WKButton *btnStart;
        if ([[data objectForKey:@"IsPause"] boolValue]) {
            btnStart = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountstart.png" title:@"启用" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
            [btnStart setTag:indexPath.section];
            [btnStart addTarget:self action:@selector(startClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            btnStart = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountpause.png" title:@"暂停" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
            [btnStart setTag:indexPath.section];
            [btnStart addTarget:self action:@selector(pauseClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [cell.contentView addSubview:btnStart];
        UIView *viewSeparateLeft = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnStart), VIEW_Y(btnStart), 1, VIEW_H(btnStart))];
        [viewSeparateLeft setBackgroundColor:SEPARATECOLOR];
        [cell.contentView addSubview:viewSeparateLeft];
    }
    if ([[data objectForKey:@"IsPause"] boolValue]) {
        WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbDetail), 50, 20) content:@"已暂停" size:DEFAULTFONTSIZE color:[UIColor whiteColor]];
        [lbStatus setBackgroundColor:[UIColor grayColor]];
        [lbStatus setTextAlignment:NSTextAlignmentCenter];
        [cell.contentView addSubview:lbStatus];
    }
    WKButton *btnUserSafe = [[WKButton alloc] initImageButtonWithFrame:CGRectMake((canOperate ? widthForButton : 0), VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountsafe.png" title:@"修改用户名密码" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
    [btnUserSafe setTag:indexPath.section];
    [btnUserSafe addTarget:self action:@selector(safeClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnUserSafe];
    
    WKButton *btnUserInfo = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnUserSafe), VIEW_Y(btnUserSafe), VIEW_W(btnUserSafe), VIEW_H(btnUserSafe)) image:@"cp_accountmodify.png" title:@"修改用户信息" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
    [btnUserInfo setTag:indexPath.section];
    [btnUserInfo addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnUserInfo];
    
    UIView *viewSeparateMiddle = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnUserSafe), VIEW_Y(btnUserSafe), 1, VIEW_H(btnUserSafe))];
    [viewSeparateMiddle setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparateMiddle];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(btnUserSafe))];
    return cell;
}

- (void)startClick:(UIButton *)button {
    [self operateUser:@"确定要启用该用户吗？" index:button.tag];
}

- (void)pauseClick:(UIButton *)button {
    [self operateUser:@"确定要暂停该用户吗？" index:button.tag];
}

- (void)operateUser:(NSString *)title index:(NSInteger)index {
    NSDictionary *data = [self.arrData objectAtIndex:index];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:title preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"ChangeAccountStatus" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainID", CAMAINCODE, @"Code", [data objectForKey:@"ID"], @"caMainIDChange", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)safeClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    AccountSafeViewController *accountSafeCtrl = [[AccountSafeViewController alloc] init];
    accountSafeCtrl.caMainId = [data objectForKey:@"ID"];
    accountSafeCtrl.title = [data objectForKey:@"Name"];
    [self.navigationController pushViewController:accountSafeCtrl animated:YES];
}

- (void)userClick:(UIButton *)button {
    NSDictionary *data = [self.arrData objectAtIndex:button.tag];
    AccountInfoViewController *accountInfoCtrl = [[AccountInfoViewController alloc] init];
    accountInfoCtrl.caMainId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:accountInfoCtrl animated:YES];
}

- (void)buyClick {
    OrderApplyViewController *orderApplyCtrl = [[OrderApplyViewController alloc] init];
    orderApplyCtrl.urlString = [NSString stringWithFormat:@"http://%@/company/order/applysuborder?ordertype=11", [USER_DEFAULT valueForKey:@"subsite"]];
    [self.navigationController pushViewController:orderApplyCtrl animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *data = [self.arrData objectAtIndex:indexPath.section];
    AccountInfoViewController *accountInfoCtrl = [[AccountInfoViewController alloc] init];
    accountInfoCtrl.caMainId = [data objectForKey:@"ID"];
    [self.navigationController pushViewController:accountInfoCtrl animated:YES];
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
