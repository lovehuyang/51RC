//
//  KeywordViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/4.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "KeywordViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "WKLabel.h"
#import "FMDatabase.h"

@interface KeywordViewController ()<UITextFieldDelegate, NetWebServiceRequestDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UITextField *txtKeyword;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) NSMutableArray *arrayHistory;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UITableView *tableViewHistory;
@property (nonatomic, strong) UIView *viewHot;
@end

@implementation KeywordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    self.txtKeyword = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 110, 30)];
    [self.txtKeyword setText:self.keyWord];
    [self.txtKeyword setDelegate:self];
    [self.txtKeyword setBackgroundColor:[UIColor whiteColor]];
    [self.txtKeyword setPlaceholder:@"请填写关键词"];
    [self.txtKeyword setFont:DEFAULTFONT];
    [self.txtKeyword setClearButtonMode:UITextFieldViewModeWhileEditing];
    [self.txtKeyword.layer setCornerRadius:15];
    [self.txtKeyword setReturnKeyType:UIReturnKeySearch];
    [self.txtKeyword addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    [self.txtKeyword becomeFirstResponder];
    
    UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 40, 15)];
    UIImageView *imgSearch = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, 15, 15)];
    [imgSearch setImage:[UIImage imageNamed:@"job_search.png"]];
    [imgSearch setContentMode:UIViewContentModeScaleAspectFit];
    [viewLeft addSubview:imgSearch];
    
    [self.txtKeyword setLeftViewMode:UITextFieldViewModeAlways];
    [self.txtKeyword setLeftView:viewLeft];
    
    self.navigationItem.titleView = self.txtKeyword;
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, VIEW_H(self.txtKeyword))];
    [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:DEFAULTFONT];
    [btnCancel addTarget:self action:@selector(cancelKeyword:) forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT)) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setTag:0];
    [self.tableView setHidden:YES];
    [self.view addSubview:self.tableView];
    
    self.tableViewHistory = [[UITableView alloc] initWithFrame:self.tableView.frame style:UITableViewStylePlain];
    [self.tableViewHistory setDelegate:self];
    [self.tableViewHistory setDataSource:self];
    [self.tableViewHistory setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableViewHistory setTag:1];
    [self.tableViewHistory setHidden:YES];
    [self.view addSubview:self.tableViewHistory];
    
    [self getHistory];
    [self getHot];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (NSMutableArray *)arrayHistory{
    if (!_arrayHistory) {
        _arrayHistory = [NSMutableArray array];
    }
    return _arrayHistory;
}
#pragma mark - 获取搜索记录
- (void)getHistory {
    [self.arrayHistory removeAllObjects];
    
    if ([USER_DEFAULT objectForKey:@"paSearchHistory"] ) {
        self.arrayHistory = [[USER_DEFAULT objectForKey:@"paSearchHistory"] mutableCopy];
    }
    
    if (self.arrayHistory.count > 0) {
        [self.tableViewHistory setHidden:NO];
        [self.viewHot setHeight:YES];
    }else{
        [self.tableViewHistory setHidden:YES];
        [self.viewHot setHeight:NO];
    }
    
     [self.tableViewHistory reloadData];
}

- (void)getHot {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetHotJobType" Params:[NSDictionary dictionaryWithObjectsAndKeys:[USER_DEFAULT objectForKey:@"provinceId"], @"intSiteID", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)fillHot:(NSArray *)arrayHot {
    self.viewHot = [[UIView alloc] initWithFrame:CGRectMake(15, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + 15, SCREEN_WIDTH - 30, 1)];
    if (self.arrayHistory.count > 0) {
        [self.viewHot setHidden:YES];
    }
    [self.view addSubview:self.viewHot];
    
    UIImageView *imgHot = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    [imgHot setImage:[UIImage imageNamed:@"job_hot.png"]];
    [imgHot setContentMode:UIViewContentModeScaleAspectFit];
    [self.viewHot addSubview:imgHot];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgHot) + 5, VIEW_Y(imgHot), 200, 20) content:@"热门招聘" size:DEFAULTFONTSIZE color:nil];
    [self.viewHot addSubview:lbTitle];
    
    float widthForHot = 0;
    float heightForHot = VIEW_BY(lbTitle) + 10;
    for (NSDictionary *data in arrayHot) {
        WKLabel *lbHot = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForHot, heightForHot, 200, 35) content:[data objectForKey:@"JobName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [lbHot setTextAlignment:NSTextAlignmentCenter];
        [lbHot.layer setMasksToBounds:YES];
        [lbHot.layer setBorderWidth:1];
        [lbHot.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [lbHot.layer setCornerRadius:5];
        CGRect frameHot = lbHot.frame;
        frameHot.size.width = frameHot.size.width + 35;
        [lbHot setFrame:frameHot];
        
        if (VIEW_BX(lbHot) > VIEW_W(self.viewHot)) {
            frameHot.origin.y = VIEW_BY(lbHot) + 10;
            frameHot.origin.x = 0;
        }
        [lbHot setFrame:frameHot];
        
        widthForHot = VIEW_BX(lbHot) + 10;
        heightForHot = VIEW_Y(lbHot);
        
        [self.viewHot addSubview:lbHot];
        
        UIButton *btnHot = [[UIButton alloc] initWithFrame:lbHot.frame];
        [btnHot setTitle:[data objectForKey:@"JobName"] forState:UIControlStateNormal];
        [btnHot setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnHot addTarget:self action:@selector(hotClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewHot addSubview:btnHot];
    }
    [self.viewHot setFrame:CGRectMake(VIEW_X(self.viewHot), VIEW_Y(self.viewHot), VIEW_W(self.viewHot), heightForHot + 25)];
}

- (void)hotClick:(UIButton *)button {
    [self.delegate KeyWordSelect:button.titleLabel.text];
    [self cancelKeyword:button.titleLabel.text];
}

- (void)cancelKeyword:(id)keyWord {
    if ([keyWord isKindOfClass:[NSString class]]) {
        if (![keyWord isEqualToString:@""]) {
            [self.arrayHistory removeObject:keyWord];
            [self.arrayHistory addObject:keyWord];
            if (self.arrayHistory.count > 6) {
                [self.arrayHistory removeObjectAtIndex:0];
            }
            [USER_DEFAULT setObject:self.arrayHistory forKey:@"paSearchHistory"];
        }
    }
    [self.txtKeyword resignFirstResponder];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return 50;
    }
    return 0;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        UIView *viewTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        [viewTop setBackgroundColor:[UIColor whiteColor]];
        
        WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(20, 0, 200, 50) content:@"搜索记录" size:DEFAULTFONTSIZE color:nil];
        [viewTop addSubview:lbTitle];
        
        UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 120, 0, 100, 50)];
        [btnDel setTitle:@"清空" forState:UIControlStateNormal];
        [btnDel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnDel.titleLabel setFont:DEFAULTFONT];
        [btnDel setImage:[UIImage imageNamed:@"job_trash.png"] forState:UIControlStateNormal];
        [btnDel setImageEdgeInsets:UIEdgeInsetsMake(17, 20, 17, 0)];
        [btnDel.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnDel addTarget:self action:@selector(clearHistory) forControlEvents:UIControlEventTouchUpInside];
        [viewTop addSubview:btnDel];
        
        return viewTop;
    }
    return NULL;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 0) {
        return self.arrayData.count;
    }
    else {
        return self.arrayHistory.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    if (tableView.tag == 0) {
        NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
        WKLabel *lbKeyword = [[WKLabel alloc] initWithFixedHeight:CGRectMake(20, 0, 500, 40) content:[data objectForKey:@"KeyWord"] size:DEFAULTFONTSIZE color:nil];
        [cell.contentView addSubview:lbKeyword];
        
        WKLabel *lbResult = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 130, 0, 120, 40) content:[NSString stringWithFormat:@"约%@个搜索结果", [data objectForKey:@"SearchResult"]] size:SMALLERFONTSIZE color:TEXTGRAYCOLOR];
        [lbResult setTextAlignment:NSTextAlignmentRight];
        [cell.contentView addSubview:lbResult];
        
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbKeyword), SCREEN_WIDTH, 1)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [cell.contentView addSubview:viewSeparate];
    }
    else {
        UIImageView *imgHistory = [[UIImageView alloc] initWithFrame:CGRectMake(20, 12, 16, 16)];
        [imgHistory setImage:[UIImage imageNamed:@"job_history.png"]];
        [cell.contentView addSubview:imgHistory];
        
        WKLabel *lbKeyword = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgHistory) + 5, 0, 500, 40) content:[self.arrayHistory objectAtIndex:(self.arrayHistory.count - 1 - indexPath.row)] size:DEFAULTFONTSIZE color:nil];
        [cell.contentView addSubview:lbKeyword];
        
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbKeyword), SCREEN_WIDTH, 1)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [cell.contentView addSubview:viewSeparate];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *keyWord = @"";
    if (tableView.tag == 0) {
        NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
        keyWord = [data objectForKey:@"KeyWord"];
    }
    else {
        keyWord = [self.arrayHistory objectAtIndex:(self.arrayHistory.count - 1 - indexPath.row)];
    }
    [self.delegate KeyWordSelect:keyWord];
    [self cancelKeyword:keyWord];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self fillHot:[Common getArrayFromXml:requestData tableName:@"Table"]];
    }
    else if (request.tag == 2) {
        self.arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
        [self.tableView reloadData];
    }
}

- (void)textFieldTextChange:(UITextField *)textField {
    UITextRange *rang = textField.markedTextRange;
    if (rang != nil) {
        return;
    }
    if (textField.text.length == 0) {
        if (self.arrayHistory.count == 0) {
            [self.viewHot setHidden:NO];
        }
        else {
            [self.tableViewHistory setHidden:NO];
        }
        [self.tableView setHidden:YES];
        return;
    }
    [self.viewHot setHidden:YES];
    [self.tableViewHistory setHidden:YES];
    [self.tableView setHidden:NO];
    
    [self.runningRequest cancel];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetSearchKeyWords" Params:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"strKeyWord", nil] viewController:nil];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.delegate KeyWordSelect:textField.text];
    [self cancelKeyword:textField.text];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    [self getHistory];

    return YES;
}

#pragma mark - 清除搜索记录
- (void)clearHistory {
    [USER_DEFAULT removeObjectForKey:@"paSearchHistory"];
    [USER_DEFAULT synchronize];
    [self getHistory];
}

@end
