//
//  OneMinuteCVViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/26.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "OneMinuteCVViewController.h"
#import "OnMinuteSingleCell.h"
#import "OneMinuteModel.h"
#import "OneMinuteArray.h"
#import "WKPopView.h"
#import "Common.h"
#import "MajorViewController.h"// 专业名称
#import "MultiSelectViewController.h"// 期望职位类别

NSInteger const WKPopViewTag_Gender = 1;//性别
NSInteger const WKPopViewTag_Birthday = 2;//出生年月
NSInteger const WKPopViewTag_Education = 3;// 学历
NSInteger const WKPopViewTag_MajorID = 4;// 专业类别
NSInteger const WKPopViewTag_JobPlace = 5;// 期望工作地点
NSInteger const WKPopViewTag_Salary = 6;// 期望月薪
NSInteger const WKPopViewTag_careerStatus = 7;// 求职状态

@interface OneMinuteCVViewController ()<UITableViewDelegate, UITableViewDataSource,WKPopViewDelegate,MajorViewDelete,MultiSelectDelegate>
{
    BOOL mobileVerify;// 手机号是否认证通过
}
@property (nonatomic , strong) UILabel *tipLab;//
@property (nonatomic , strong) UITableView *tableview;
@property (nonatomic , strong) UIView *footView;// tableview的foot视图
@property (nonatomic , strong) NSArray *dataArr;// 数据源
@property (nonatomic , strong) NSMutableDictionary *dataParam;

@end

@implementation OneMinuteCVViewController
- (instancetype)init{
    if (self = [super init]) {
        self.title = @"一分钟填写简历";
        self.view.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // 接口参数
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"", @"strVerifyCode",
                      [USER_DEFAULT objectForKey:@"provinceId"], @"provinceid",
                      @"", @"Name",// 姓名
                      @"", @"Gender",// 性别
                      @"", @"Birthday",// 出生年月
                      @"", @"JobPlace",// 期望工作地点
                      @"", @"Mobile", // 手机号
                      @"", @"Salary", // 期望月薪
                      @"", @"JobType",// 期望职位类别
                      @"", @"Negotiable",// 是否可以面议
                      @"", @"Education",// 学历
                      @"", @"College",// 毕业院校
                      @"", @"MajorID",// 专业类别
                      @"", @"MajorName",// 专业名称
                      
                      
                      @"", @"intCareerStatus",//求职状态
                      PAMAINID, @"paMainID",
                      [USER_DEFAULT objectForKey:@"paMainCode"], @"strCode",
                      @"0", @"intCvMainID",
                      @"", @"EducationID",
                      @"", @"RelatedWorkYears",
                      nil];
    
    [self getPaMain];
}

- (void)getPaMain{
    [SVProgressHUD show];
    NSDictionary *parmaDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", nil];
    [AFNManager requestWithMethod:POST ParamDict:parmaDict url:URL_GETPAMAIN tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        NSString *mobileVerifyDate = dataDict[@"MobileVerifyDate"];
        if (mobileVerifyDate.length > 0) {
            DLog(@"手机号已经通过认证");
            mobileVerify = YES;
        }else{
            mobileVerify = NO;
        }
        
        [self.view addSubview:self.tipLab];
        [self.view addSubview:self.tableview];
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - 懒加载
- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, VIEW_BY(self.tipLab), SCREEN_WIDTH, SCREEN_HEIGHT - VIEW_BY(self.tipLab)) style:UITableViewStylePlain];
        _tableview.tableFooterView = self.footView;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = SEPARATECOLOR;
    }
    return _tableview;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab= [[UILabel alloc]initWithFrame:CGRectMake(0, HEIGHT_STATUS_NAV, SCREEN_WIDTH, 35)];
        _tipLab.backgroundColor = SEPARATECOLOR;
        _tipLab.text = @"   简历求职第一步，快速填写简历，给你一个满意的工作。";
        _tipLab.font = DEFAULTFONT;
    }
    return _tipLab;
}

- (NSArray *)dataArr{
    if (!_dataArr) {
        _dataArr = [OneMinuteArray createOneMinuteDataWithType:mobileVerify?1:0];
    }
    return _dataArr;
}

- (UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        _footView.backgroundColor = SEPARATECOLOR;
        UIButton *saveBtn = [UIButton new];
        [_footView addSubview:saveBtn];
        saveBtn.sd_layout
        .leftSpaceToView(_footView, 20)
        .rightSpaceToView(_footView, 20)
        .topSpaceToView(_footView, 40)
        .heightIs(35);
        saveBtn.backgroundColor = NAVBARCOLOR;
        saveBtn.sd_cornerRadius = @(5);
        [saveBtn setTitle:@"保存" forState:UIControlStateNormal];
        [saveBtn addTarget:self action:@selector(saveEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
}
#pragma mark - UITableViewDelegate, UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    OnMinuteSingleCell *cell = [[OnMinuteSingleCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil data:self.dataArr[indexPath.row] indexPath:indexPath viewController:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self)weakSelf = self;
    cell.cellDidSelect = ^(UITextField *textField) {
        [weakSelf cellSelectEvent:textField];
    };
    // 获取验证码
    cell.getMobileVerifyCode = ^{
        [weakSelf getMobileVerifyCode];
    };
    
    return cell;
}

- (void)cellSelectEvent:(UITextField *)textField{

    if ([textField.placeholder isEqualToString:@"手机号码"]) {
        [self resetDataValue:textField.text key:@"手机号码"];
        [self.dataParam setObject:textField.text forKey:@"Mobile"];
        
    }else if ([textField.placeholder isEqualToString:@"短信确认码"]) {
        [self resetDataValue:textField.text key:@"短信确认码"];
        [self.dataParam setObject:textField.text forKey:@"strVerifyCode"];
        
    }else  if([textField.placeholder isEqualToString:@"姓名"]){
        [self resetDataValue:textField.text key:@"姓名"];
        [self.dataParam setObject:textField.text forKey:@"Name"];
        
    }else if ([textField.placeholder isEqualToString:@"性别"]) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeGender value:[self.dataParam objectForKey:@"Gender"]];
        [popView setTag:WKPopViewTag_Gender];
        [popView setDelegate:self];
        [popView showPopView:self];
        
    }else if ([textField.placeholder isEqualToString:@"出生年月"]) {
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeBirth value:[self.dataParam objectForKey:@"Birthday"]];
        [popView setTag:WKPopViewTag_Birthday];
        [popView setDelegate:self];
        [popView showPopView:self];
        
    }else if ([textField.placeholder isEqualToString:@"毕业院校"]){
        [self resetDataValue:textField.text key:@"毕业院校"];
        [self.dataParam setObject:textField.text forKey:@"College"];
        
    }else if ([textField.placeholder isEqualToString:@"学历"]){
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeDegree value:[self.dataParam objectForKey:@"Education"]];
        [popView setTag:WKPopViewTag_Education];
        [popView setDelegate:self];
        [popView showPopView:self];
    }else if ([textField.placeholder isEqualToString:@"专业名称"]){
        MajorViewController *majorCtrl = [[MajorViewController alloc] init];
        [majorCtrl setDelegate:self];
        [self.navigationController pushViewController:majorCtrl animated:YES];
        
    }else if ([textField.placeholder isEqualToString:@"专业类别"]){
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeMajor value:[self.dataParam objectForKey:@"MajorID"]];
        [popView setTag:WKPopViewTag_MajorID];
        [popView setDelegate:self];
        [popView showPopView:self];
        
    }else if ([textField.placeholder isEqualToString:@"期望工作地点"]){
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeRegionL3 value:[self.dataParam objectForKey:@"JobPlace"]];
        [popView setTag:WKPopViewTag_JobPlace];
        [popView setDelegate:self];
        [popView showPopView:self];
        
    }else if ([textField.placeholder isEqualToString:@"期望职位类别"]){
        
        [self.view endEditing:YES];
        MultiSelectViewController *multiSelectCtrl = [[MultiSelectViewController alloc] init];
        [multiSelectCtrl setDelegate:self];
        multiSelectCtrl.selId = [self.dataParam objectForKey:@"JobType"];
        multiSelectCtrl.selectType = MultiSelectTypeJobType;
        [self.navigationController pushViewController:multiSelectCtrl animated:YES];
        
    }else if([textField.placeholder isEqualToString:@"期望月薪"]){
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeSalary value:[self.dataParam objectForKey:@"Salary"]];
        [popView setTag:WKPopViewTag_Salary];
        [popView setDelegate:self];
        [popView showPopView:self];
        
    }else if ([textField.placeholder isEqualToString:@"求职状态"]){
        WKPopView *popView = [[WKPopView alloc] initWithPickerType:WKPickerTypeCareerStatus value:[self.dataParam objectForKey:@"intCareerStatus"]];
        [popView setTag:WKPopViewTag_careerStatus];
        [popView setDelegate:self];
        [popView showPopView:self];
    }
}

#pragma mark - WKPopViewDelegate
- (void)WKPickerViewConfirm:(WKPopView *)popView arraySelect:(NSArray *)arraySelect{
    if (popView.tag == WKPopViewTag_Gender) {// 性别
        NSDictionary *dataGender = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[dataGender objectForKey:@"id"] forKey:@"Gender"];
        [self resetDataValue:dataGender[@"value"] key:@"性别"];
        
    }else if (popView.tag == WKPopViewTag_Birthday){// 出生年月
        NSDictionary *dataYear = [arraySelect objectAtIndex:0];
        NSDictionary *dataMonth = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"Birthday"];
        [self resetDataValue:[NSString stringWithFormat:@"%@%@",dataYear[@"value"],dataMonth[@"value"]] key:@"出生年月"];
        
    }else if(popView.tag == WKPopViewTag_Education){// 学历
       
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Education"];
        [self resetDataValue:[data objectForKey:@"value"] key:@"学历"];
        
        if ([[data objectForKey:@"id"] isEqualToString:@"1"] || [[data objectForKey:@"id"] isEqualToString:@"2"]) {
            
            [self.dataParam setValue:@"1106" forKey:@"MajorID"];
            [self resetDataValue:@"未划分专业" key:@"专业类别"];
            
            [self.dataParam setValue:@"无" forKey:@"MajorName"];
            [self resetDataValue:@"无" key:@"专业名称"];
        }
        
    }else if (popView.tag == WKPopViewTag_MajorID){// 专业类别
        NSDictionary *data = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"MajorID"];
        [self resetDataValue:[data objectForKey:@"value"] key:@"专业类别"];
        
    }else if (popView.tag == WKPopViewTag_JobPlace){// 期望工作地点
        NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
        [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"JobPlace"];
        [self resetDataValue:[dataRegion objectForKey:@"value"] key:@"期望工作地点"];
        
    }else if (popView.tag == WKPopViewTag_Salary){
        NSDictionary *data = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Salary"];
        NSDictionary *dataNegotiable = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[dataNegotiable objectForKey:@"id"] forKey:@"Negotiable"];
        [self resetDataValue:[NSString stringWithFormat:@"%@ %@", [data objectForKey:@"value"], ([[dataNegotiable objectForKey:@"id"] isEqualToString:@"0"] ? @"不可面议" : @"可面议")] key:@"期望月薪"];
        
    }else if (popView.tag == WKPopViewTag_careerStatus){// 求职状态
        NSDictionary *careerStatus = [arraySelect objectAtIndex:0];
        [self.dataParam setValue:[careerStatus objectForKey:@"id"] forKey:@"intCareerStatus"];
        [self resetDataValue:careerStatus[@"value"] key:@"求职状态"];
    }
    [self.tableview reloadData];
}

#pragma mark - 修改数据源的值
- (void)resetDataValue:(NSString *)value key:(NSString *)key {
    for (id object in self.dataArr) {
        if ([object isKindOfClass:[OneMinuteModel class]]) {
            OneMinuteModel *model = (OneMinuteModel *)object;
            if ([model.placeholderStr containsString:key]) {
                model.contentStr = value;
            }
        }else if([object isKindOfClass:[NSArray class]]){
            NSArray *dataArr = (NSArray *)object;
            for (id object2 in dataArr) {
                OneMinuteModel *model2 = (OneMinuteModel *)object2;
                if ([model2.placeholderStr containsString:key]) {
                    model2.contentStr = value;
                }
            }
        }
    }
}

#pragma mark - 取数据源的值
- (NSString *)getDataWithKey:(NSString *)key {
    NSString *value = nil;
    for (id object in self.dataArr) {
        if ([object isKindOfClass:[OneMinuteModel class]]) {
            OneMinuteModel *model = (OneMinuteModel *)object;
            if ([model.placeholderStr containsString:key]) {
                value = model.contentStr;;
            }
        }else if([object isKindOfClass:[NSArray class]]){
            NSArray *dataArr = (NSArray *)object;
            for (id object2 in dataArr) {
                OneMinuteModel *model2 = (OneMinuteModel *)object2;
                if ([model2.placeholderStr containsString:key]) {
                    value = model2.contentStr;
                }
            }
        }
    }
    return value;
}

#pragma mark - MajorViewDelete - 专业名称

- (void)majorViewClick:(NSDictionary *)major {// 专业名称
    [self.dataParam setValue:[major objectForKey:@"MajorName"] forKey:@"MajorName"];
    [self resetDataValue:[major objectForKey:@"MajorName"] key:@"专业名称"];
    if ([[major objectForKey:@"dcMajorId"] length] > 0) {
        [self.dataParam setValue:[major objectForKey:@"dcMajorId"] forKey:@"MajorID"];
        [self resetDataValue:[major objectForKey:@"Major"] key:@"专业类别"];
    }
    [self.tableview reloadData];
}

#pragma mark - MultiSelectDelegate - 期望职位类别
- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect{
    if (selectType == MultiSelectTypeJobType) {
        [self.dataParam setValue:[arraySelect objectAtIndex:0] forKey:@"JobType"];
        [self resetDataValue:[arraySelect objectAtIndex:1] key:@"期望职位类别"];
    }
    [self.tableview reloadData];
}

#pragma mark - 获取验证码
- (void)getMobileVerifyCode{
    
    if ([[self getDataWithKey:@"手机号码"] length]) {
        NSDictionary *paramDict = @{@"paMainID":PAMAINID,
                                    @"strCode":[USER_DEFAULT valueForKey:@"paMainCode"],
                                    @"strMobile":[self getDataWithKey:@"手机号码"],
                                    @"strWebSiteName":[USER_DEFAULT valueForKey:@"subsitename"]
                                    };
        [SVProgressHUD show];
        [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETMOBILECERCODE tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
            [SVProgressHUD dismiss];
            NSInteger result = [(NSString *)dataDict integerValue];
            if (result == 1) {
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_ONEMINUTEGETVERIFYCODE object:nil];
            }else{
                NSString *resultStr = [Common oneminuteMobileCerCodeResult:result];
                [RCToast showMessage:resultStr];
            }
        } failureBlock:^(NSInteger errCode, NSString *msg) {
            [SVProgressHUD dismiss];
            [RCToast showMessage:msg];
        }];
        
    }else{
        [RCToast showMessage:@"请输入手机号码"];
    }
}

#pragma mark - 保存
- (void)saveEvent{
    
}

@end
