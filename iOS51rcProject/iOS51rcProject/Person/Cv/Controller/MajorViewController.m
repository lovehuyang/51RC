//
//  MajorViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/12.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "MajorViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "WKLabel.h"
#import "UIView+Toast.h"

@interface MajorViewController ()<UITableViewDelegate, UITableViewDataSource, NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) UITextField *txtMajorName;
@end

@implementation MajorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"确定" style:UIBarButtonItemStylePlain target:self action:@selector(saveMajorName)];
    
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    self.txtMajorName = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 130, 30)];
    [self.txtMajorName setPlaceholder:@"请输入专业名称"];
    [self.txtMajorName setFont:FONT(12)];
    [self.txtMajorName setValue:[NSNumber numberWithInt:10] forKey:@"paddingLeft"];
    [self.txtMajorName setValue:[NSNumber numberWithInt:10] forKey:@"paddingRight"];
    [self.txtMajorName setBackgroundColor:[UIColor whiteColor]];
    [self.txtMajorName.layer setCornerRadius:5];
    [self.txtMajorName addTarget:self action:@selector(textFieldTextChange:) forControlEvents:UIControlEventEditingChanged];
    self.navigationItem.titleView = self.txtMajorName;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - STATUS_BAR_HEIGHT - NAVIGATION_BAR_HEIGHT) style:UITableViewStylePlain];
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.view addSubview:self.tableView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)saveMajorName {
    [self.txtMajorName resignFirstResponder];
    if (self.txtMajorName.text.length == 0) {
        [self.view makeToast:@"请输入专业名称"];
        return;
    }
    [self.delegate majorViewClick:[NSDictionary dictionaryWithObjectsAndKeys:self.txtMajorName.text, @"MajorName", nil]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrayData.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 41;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    WKLabel *lbMajor = [[WKLabel alloc] initWithFixedHeight:CGRectMake(20, 0, 500, 40) content:[data objectForKey:@"MajorName"] size:DEFAULTFONTSIZE color:nil];
    [cell.contentView addSubview:lbMajor];
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbMajor), SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.txtMajorName resignFirstResponder];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.delegate majorViewClick:[self.arrayData objectAtIndex:indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)textFieldTextChange:(UITextField *)textField {
    UITextRange *rang = textField.markedTextRange;
    if (rang != nil) {
        return;
    }
    if (textField.text.length == 0) {
        return;
    }
    [self.runningRequest cancel];
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetMajor" Params:[NSDictionary dictionaryWithObjectsAndKeys:textField.text, @"majorName", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    self.arrayData = [Common getArrayFromXml:requestData tableName:@"Table"];
    [self.tableView reloadData];
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
