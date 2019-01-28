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
#import "SpeechButton.h"
#import "SpeechViewController.h"
#import "WKNavigationController.h"
#import <CoreLocation/CoreLocation.h>

NSInteger const WKPopViewTag_Gender = 1;//性别
NSInteger const WKPopViewTag_Birthday = 2;//出生年月
NSInteger const WKPopViewTag_Education = 3;// 学历
NSInteger const WKPopViewTag_MajorID = 4;// 专业类别
NSInteger const WKPopViewTag_JobPlace = 5;// 期望工作地点
NSInteger const WKPopViewTag_Salary = 6;// 期望月薪
NSInteger const WKPopViewTag_careerStatus = 7;// 求职状态

@interface OneMinuteCVViewController ()<UITableViewDelegate, UITableViewDataSource,WKPopViewDelegate,MajorViewDelete,MultiSelectDelegate,CLLocationManagerDelegate>
{
    BOOL mobileVerify;// 手机号是否认证通过
    NSInteger birthMonth;// 出生月份
    NSInteger birthYear;// 出生年份
    NSString *moblieNumber;// 手机号
    NSString *intCareerStatus;// 求职状态
    NSArray *regionData;// 省市id
}
@property (nonatomic , strong) UILabel *tipLab;//
@property (nonatomic , strong) UITableView *tableview;
@property (nonatomic , strong) UIView *footView;// tableview的foot视图
@property (nonatomic , strong) NSArray *dataArr;// 数据源
@property (nonatomic , strong) NSMutableDictionary *dataParam;
@property (nonatomic , copy) NSDictionary *paMainDict;// getPaMain接口返回的数据

@property (nonatomic, strong) CLLocationManager *locationManager;// 位置

@end

@implementation OneMinuteCVViewController
- (instancetype)init{
    if (self = [super init]) {
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"一分钟填写简历";
    self.view.backgroundColor = [UIColor whiteColor];
    
    regionData = [Common getRegion];
    
    // 接口参数
    self.dataParam = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"", @"strVerifyCode",
                      [USER_DEFAULT objectForKey:@"provinceId"], @"provinceid",
                      @"", @"Name",// 姓名
                      @"", @"Gender",// 性别
                      @"", @"Birthday",// 出生年月
                      @"3201", @"JobPlace",// 期望工作地点.默认济南3201
                      @"", @"Mobile", // 手机号
                      @"", @"Salary", // 期望月薪
                      @"", @"JobType",// 期望职位类别
                      @"1", @"Negotiable",// 是否可以面议
                      @"", @"Education",// 学历id
                      @"", @"College",// 毕业院校
                      @"", @"MajorID",// 专业类别
                      @"", @"MajorName",// 专业名称
                      @"", @"intCareerStatus",//求职状态
                      PAMAINID, @"paMainID",
                      [USER_DEFAULT objectForKey:@"paMainCode"], @"strCode",
                      self.intCvMainID, @"intCvMainID",
                      @"0", @"EducationID",// 教育背景id
                      @"", @"RelatedWorkYears",// 工作经验
                      nil];
    [self.view addSubview:self.tipLab];
    [self.view addSubview:self.tableview];
//    [self setupAddHuaTongButton];// 语音输入按钮
    [self getPaMain];
}

//开始定位
- (void)startLocation {
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc]init];
        self.locationManager.delegate = self;
        [self.locationManager requestAlwaysAuthorization];
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;// 定位精度（枚举）
        [self.locationManager startUpdatingLocation];// 开启定位
    }
}
//定位代理经纬度回调
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation *currentLocation = locations.lastObject;
    NSLog(@"位置信息：纬度：%f - 经度%f", currentLocation.coordinate.latitude , currentLocation.coordinate.longitude);
    
    //反地理编码
    CLGeocoder *geocoder = [[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (placemarks.count > 0) {
            CLPlacemark *placeMark = placemarks.firstObject;
            NSString *city = placeMark.locality;
            if (!city) {
                //四大直辖市的城市信息无法通过locality获得，只能通过获取省份的方法来获得（如果city为空，则可知为直辖市）
                city = placeMark.administrativeArea;
            }
            
            NSString *locationStr = [[NSString alloc]initWithFormat:@"%@ - %@ - %@ - %@ - %@",placeMark.country,placeMark.locality, placeMark.subLocality,placeMark.thoroughfare,placeMark.name];
            DLog(@"%@",locationStr);
            
            [self resetDataValue:placeMark.subLocality?placeMark.subLocality:city key:@"工作地点"];
            // 参数字典添加位置
            NSString *cityId = @"3201";// 默认济南3201
            for (NSDictionary *dict in regionData) {
                NSString *subCity = dict[@"value"];
                if ([subCity containsString:city] || [city containsString:subCity]) {
                    cityId = dict[@"id"];
                    break;
                }
            }
            
            [self.dataParam setValue:cityId forKey:@"JobPlace"];
            [self.tableview reloadData];
        }
    }];
}

- (void)getPaMain{
    [SVProgressHUD show];
    NSDictionary *parmaDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", nil];
    [AFNManager requestWithMethod:POST ParamDict:parmaDict url:URL_GETPAMAIN tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        self.paMainDict = [NSDictionary dictionaryWithDictionary:dataDict];
        NSString *mobileVerifyDate = dataDict[@"MobileVerifyDate"];
        // 参数字典添加手机号
        [self.dataParam setValue:dataDict[@"Mobile"] forKey:@"Mobile"];
        // 参数字典添加姓名
        [self.dataParam setValue:dataDict[@"Name"] forKey:@"Name"];
        // 参数字典添加求职状态
        intCareerStatus = dataDict[@"dcCareerStatus"];
        [self.dataParam setValue:dataDict[@"dcCareerStatus"] forKey:@"intCareerStatus"];
        NSString *birthStr = dataDict[@"BirthDay"];
        // 参数字典添加出生年月
        [self.dataParam setValue:dataDict[@"BirthDay"] forKey:@"Birthday"];
        
        if (birthStr != nil && birthStr.length > 0) {
            NSRange range1 = NSMakeRange(0, 4);
            NSRange range2 = NSMakeRange(4, 2);
            birthYear = [[birthStr substringWithRange:range1] integerValue];// 赋值给出生月份变量
            birthMonth = [[birthStr substringWithRange:range2] integerValue];// 赋值给年份变量
        }
        
        // 参数字典添加性别
        [self.dataParam setValue:[dataDict[@"Gender"] boolValue]?@"1":@"0" forKey:@"Gender"];
        
        if (mobileVerifyDate.length > 0) {
            DLog(@"手机号已经通过认证");
            mobileVerify = YES;
            [self GetIpMobilePlace:dataDict[@"Mobile"]];
        
        }else{// 手机号未通过认证
            [SVProgressHUD dismiss];
            mobileVerify = NO;
            [self createDataArr:dataDict];
            [self.tableview reloadData];
            [self startLocation];
            [self setupAddHuaTongButton];
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
    }];
}

#pragma mark - 获取手机号码归属地和位置id
- (void)GetIpMobilePlace:(NSString *)mobile{
    NSDictionary *paramDict = @{@"mobile":mobile};
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETIPMOBILEPLACE tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        NSArray *arr = [(NSString *)dataDict componentsSeparatedByString:@"$"];
        [SVProgressHUD dismiss];
        [self createDataArr:self.paMainDict];
        
        NSString *jobPlace;
        NSString *jobPlaceId;
        
        if (arr.count >0) {
            jobPlace = [arr lastObject];// 工作地点
            jobPlaceId = [arr firstObject];// 工作地点的id
        }
        
        if(jobPlace == nil || jobPlace == nil || jobPlace.length == 0 || jobPlaceId.length == 0){
            [self startLocation];
        
        }else{
            
            [self resetDataValue:[arr lastObject] key:@"工作地点"];
            // 参数字典添加位置
            [self.dataParam setValue: [arr firstObject] forKey:@"JobPlace"];
        }
        [self.tableview reloadData];
        [self setupAddHuaTongButton];
    
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
        [SVProgressHUD dismiss];
    }];
}
#pragma mark - 话筒Button
- (void)setupAddHuaTongButton{
    CGFloat cell_H = 45;
    SpeechButton *speechBtn = [SpeechButton new];
    speechBtn.frame = CGRectMake(SCREEN_WIDTH - 200 - 10, (SCREEN_HEIGHT - HEIGHT_STATUS_NAV - 49) * 0.50, 195, 50);
    speechBtn.center = CGPointMake(speechBtn.center.x, (self.dataArr.count - 1)*cell_H + 35 + cell_H/2);
    [self.view addSubview:speechBtn];
    speechBtn.speechInput = ^{
        SpeechViewController *svc = [[SpeechViewController alloc]init];
        svc.mobileVerify = mobileVerify;
        svc.dataArr = self.dataArr;
        WKNavigationController *nav = [[WKNavigationController alloc]initWithRootViewController:svc];
        __weak typeof(self)weakself = self;
        
        svc.speakContentBlock = ^(NSDictionary *dict) {
            NSArray *allKeys = [dict allKeys];
            for (NSString *key in allKeys) {
                NSString *value = dict[key];
                DLog(@"123说话内容：%@ - %@",key , value);
                [weakself resetDataValue:value key:key];
                [weakself.tableview reloadData];
            }
        };
        // 重置请求参数
        svc.speakRestParam = ^(NSString *key, NSString *value) {
            // 重置请求参数
            [self.dataParam setObject:value forKey:key];
        };
        BOOL haveEmpty = [self dataIsEmpty:NO];
        if (haveEmpty) {
            [self presentViewController:nav animated:YES completion:nil];
        }else{
            [RCToast showMessage:@"一分钟简历已经填写完成，请点击保存按钮！"];
        }
    };
}

#pragma mark - 懒加载

- (UITableView *)tableview{
    if (!_tableview) {
        _tableview = [[UITableView alloc]initWithFrame:CGRectMake(0, VIEW_BY(self.tipLab), SCREEN_WIDTH, SCREEN_HEIGHT - HEIGHT_STATUS_NAV - VIEW_H(self.tipLab) - 49) style:UITableViewStylePlain];
        //(0, VIEW_BY(self.tipLab), SCREEN_WIDTH, SCREEN_HEIGHT - VIEW_BY(self.tipLab)
        _tableview.tableFooterView = self.footView;
        _tableview.delegate = self;
        _tableview.dataSource = self;
        _tableview.backgroundColor = SEPARATECOLOR;
        _tableview.hidden = YES;
    }
    return _tableview;
}

- (UILabel *)tipLab{
    if (!_tipLab) {
        _tipLab= [[UILabel alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        _tipLab.backgroundColor = SEPARATECOLOR;
        _tipLab.text = @"   简历求职第一步，快速填写简历，给你一个满意的工作。";
        _tipLab.font = DEFAULTFONT;
        _tipLab.hidden = YES;
    }
    return _tipLab;
}

#pragma mark - 创建数据源
- (void)createDataArr:(NSDictionary *)dataDict{
    if (!_dataArr) {
        _dataArr = [OneMinuteArray createOneMinuteDataWithType:mobileVerify?1:0 dict:dataDict];
    }
    self.tableview.hidden = NO;
    self.tipLab.hidden = NO;
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
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 45;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    OnMinuteSingleCell *cell = [[OnMinuteSingleCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil data:self.dataArr[indexPath.row] viewController:self];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self)weakSelf = self;
    cell.cellDidSelect = ^(UITextField *textField) {
        [weakSelf cellSelectEvent:textField];
    };
    // 获取验证码
    cell.getMobileVerifyCode = ^{
        [weakSelf getMobileVerifyCode];
    };
    
    OneMinuteModel *model = nil;
    if (self.dataArr.count == 9) {
        model = [self.dataArr[4] lastObject];
        if ([model.contentStr isEqualToString:@"初中"]|| [model.contentStr isEqualToString:@"高中"]) {
            if(indexPath.row == 5){
                cell.userInteractionEnabled = NO;
            }
        }
    }else if(self.dataArr.count == 7){
        model = [self.dataArr[2] lastObject];
        if ([model.contentStr isEqualToString:@"初中"]|| [model.contentStr isEqualToString:@"高中"]) {
            if(indexPath.row == 3){
                cell.userInteractionEnabled = NO;
            }
        }
    }
    
    return cell;
}

- (void)cellSelectEvent:(UITextField *)textField{

    if ([textField.placeholder isEqualToString:@"手机号码"]) {
        [self resetDataValue:textField.text key:@"手机号码"];
        [self.dataParam setObject:textField.text forKey:@"Mobile"];
        BOOL valid = [Common checkMobile:textField.text];
        if(valid){
            [self GetIpMobilePlace:textField.text];
        }
        
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
        birthMonth = [dataMonth[@"id"] integerValue];// 赋值给出生月份变量
        birthYear = [dataYear[@"id"] integerValue];// 赋值给年份变量
        [self.dataParam setValue:[NSString stringWithFormat:@"%@%@%@", [dataYear objectForKey:@"id"], ([[dataMonth objectForKey:@"id"] length] == 1 ? @"0": @""), [dataMonth objectForKey:@"id"]] forKey:@"Birthday"];
        [self resetDataValue:[NSString stringWithFormat:@"%@%@",dataYear[@"value"],dataMonth[@"value"]] key:@"出生年月"];
        [self calulateRelatedWorkYears];
        
    }else if(popView.tag == WKPopViewTag_Education){// 学历
       
        NSDictionary *data = [arraySelect objectAtIndex:0];
//        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"EducationID"];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"Education"];
        [self resetDataValue:[data objectForKey:@"value"] key:@"学历"];
        
        if ([[data objectForKey:@"id"] isEqualToString:@"1"] || [[data objectForKey:@"id"] isEqualToString:@"2"]) {
            
            [self.dataParam setValue:@"1106" forKey:@"MajorID"];
            [self resetDataValue:@"未划分专业" key:@"专业类别"];
            
            [self.dataParam setValue:@"无" forKey:@"MajorName"];
            [self resetDataValue:@"无" key:@"专业名称"];
        }else{
            NSString *majorStr = self.dataParam[@"MajorID"];
            NSString *majorNameStr = self.dataParam[@"MajorName"];
            if ([majorStr isEqualToString:@"1106"] || [majorNameStr isEqualToString:@"无"]) {
                [self resetDataValue:@"" key:@"专业类别"];
                [self resetDataValue:@"" key:@"专业名称"];
            }
        }
        [self calulateRelatedWorkYears];
        
    }else if (popView.tag == WKPopViewTag_MajorID){// 专业类别
        NSDictionary *data = [arraySelect objectAtIndex:1];
        [self.dataParam setValue:[data objectForKey:@"id"] forKey:@"MajorID"];
        [self resetDataValue:[data objectForKey:@"value"] key:@"专业类别"];
        
    }else if (popView.tag == WKPopViewTag_JobPlace){// 期望工作地点
        NSDictionary *dataRegion = [arraySelect objectAtIndex:(arraySelect.count - 1)];
        [self.dataParam setValue:[dataRegion objectForKey:@"id"] forKey:@"JobPlace"];
        [self resetDataValue:[dataRegion objectForKey:@"value"] key:@"期望工作地点"];
        [self matchSalary];
        
    }else if (popView.tag == WKPopViewTag_Salary){// 期望月薪
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
- (OneMinuteModel *)getDataWithKey:(NSString *)key {
    OneMinuteModel *returnModel;
    for (id object in self.dataArr) {
        if ([object isKindOfClass:[OneMinuteModel class]]) {
            OneMinuteModel *model = (OneMinuteModel *)object;
            if ([model.placeholderStr containsString:key]) {
                returnModel = model;
            }
        }else if([object isKindOfClass:[NSArray class]]){
            NSArray *dataArr = (NSArray *)object;
            for (id object2 in dataArr) {
                OneMinuteModel *model2 = (OneMinuteModel *)object2;
                if ([model2.placeholderStr containsString:key]) {
                    returnModel = model2;
                }
            }
        }
    }
    return returnModel;
}

#pragma mark - 判断有无空信息
- (BOOL)dataIsEmpty:(BOOL)showAlert{
    BOOL haveEmpty = NO;
    for (id object in self.dataArr) {
        if ([object isKindOfClass:[OneMinuteModel class]]) {
            OneMinuteModel *model = (OneMinuteModel *)object;
            // 如果手机号通过了验证
            if(mobileVerify && !([model.placeholderStr containsString:@"手机号码"] || [model.placeholderStr containsString:@"短信确认码"])){
                if (model.contentStr.length == 0 ||model.contentStr == nil) {
                    if (showAlert) {
                        [RCToast showMessage:[NSString stringWithFormat:@"请完善%@信息",model.placeholderStr]];
                    }
                    haveEmpty = YES;
                    return haveEmpty;
                }
            }else{// 如果手机号没通过验证
                if (model.contentStr.length == 0 ||model.contentStr == nil) {
                    if (showAlert) {
                        [RCToast showMessage:[NSString stringWithFormat:@"请完善%@信息",model.placeholderStr]];
                    }
                    haveEmpty = YES;
                    return haveEmpty;
                }
            }
        }else if([object isKindOfClass:[NSArray class]]){
            NSArray *dataArr = (NSArray *)object;
            for (id object2 in dataArr) {
                OneMinuteModel *model2 = (OneMinuteModel *)object2;
                if ([model2.contentStr length] == 0 || model2.contentStr == nil) {
                    if (showAlert) {
                      [RCToast showMessage:[NSString stringWithFormat:@"请完善%@信息",model2.placeholderStr]];
                    }
                    haveEmpty = YES;
                    return haveEmpty;
                }
            }
        }
    }
    return haveEmpty;
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
    [self matchSalary];
    [self.tableview reloadData];
}

#pragma mark - 获取验证码
- (void)getMobileVerifyCode{
    
    OneMinuteModel *model = [self getDataWithKey:@"手机号码"];
    if ([model.contentStr length]) {
        NSDictionary *paramDict = @{@"paMainID":PAMAINID,
                                    @"strCode":[USER_DEFAULT valueForKey:@"paMainCode"],
                                    @"strMobile":model.contentStr,
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

#pragma mark - 计算工作经验
- (void)calulateRelatedWorkYears{
    
    NSString *birthStr = self.dataParam[@"Birthday"];
    NSString *educationSrr = self.dataParam[@"Education"];
    if(!(birthStr.length && educationSrr.length)){
        return;
    }
    
    // 获取现在年份
    NSDate *date = [NSDate date];
    NSDateFormatter *forMatter = [[NSDateFormatter alloc] init];
    [forMatter setDateFormat:@"yyyy"];
    // 当前年份
    NSInteger nowYear = [[forMatter stringFromDate:date] integerValue];
    // 学历应该减的年数
    NSInteger educationNum = [Common calulateRelatedWorkYearsWithEducation:[self.dataParam[@"Education"] integerValue]];
    // 出生月份应该减的数
    NSInteger birthMonthNum = (birthMonth <=8 && birthMonth >=1)?0:1;
    // 计算工作经验
    NSInteger relatedWorkYears = nowYear + educationNum - birthMonthNum - birthYear;
    [self.dataParam setValue:[NSString stringWithFormat:@"%ld",(long)relatedWorkYears] forKey:@"RelatedWorkYears"];
    if (relatedWorkYears == 0) {//应届生
        [self.dataParam setValue:@"4" forKey:@"intCareerStatus"];
        [self resetDataValue:@"应届毕业生" key:@"求职状态"];
        
    }else if(relatedWorkYears > 0 && relatedWorkYears < 50){
        [self.dataParam setValue:intCareerStatus forKey:@"intCareerStatus"];
        NSArray *careerStatusArr = [Common getCareerStatus];
        NSString *careerStatusStr = @"";
        for (NSDictionary *dic in careerStatusArr) {
            if ([dic[@"id"] isEqualToString:intCareerStatus]) {
                careerStatusStr = dic[@"value"];
                [self resetDataValue:dic[@"value"] key:@"求职状态"];
                break;
            }
        }
    }else if(relatedWorkYears<0){
         [self.dataParam setValue:@"0" forKey:@"RelatedWorkYears"];
    }else{
        [self.dataParam setValue:@"5" forKey:@"RelatedWorkYears"];
    }
    [self.tableview reloadData];
}

#pragma mark - 保存
- (void)saveEvent{
    
    BOOL haveEmpty = [self dataIsEmpty:YES];
    
    if(haveEmpty){
        return;
    }
    [self calulateRelatedWorkYears];
    [SVProgressHUD show];
    [AFNManager requestWithMethod:POST ParamDict:self.dataParam url:URL_SAVEONEMINUTE20180613NEW tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        [SVProgressHUD dismiss];
        // -100：code验证不通过  -101：手机号认证失败    1：成功
        NSInteger result = [(NSString *)dataDict integerValue];
        if (result == 1) {
            [RCToast showMessage:@"一分钟简历创建成功！"];
        
            // GCD延时执行
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if (self.pageType == PageType_Login) {
                    self.completeOneCV(@"一分钟简历创建成功");
                    [self.navigationController popViewControllerAnimated:NO];
                    [self dismissViewControllerAnimated:YES completion:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GETJOBLISTBYSEARCH object:nil];
                    self.tabBarController.selectedIndex = 0;// 跳转至“职位”页面
                   
                }else if(self.pageType == PageType_CV){
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GETCVLIST object:nil];
                    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_GETJOBLISTBYSEARCH object:nil];
                    self.tabBarController.selectedIndex = 0;// 跳转至“职位”页面
                }else if (self.pageType == PageType_JobInfo){
                    [self.navigationController popViewControllerAnimated:YES];
                }
    
            });

        }else if (result == -100){
            [RCToast showMessage:@"code验证不通过"];
        }else if (result == -101){
            [RCToast showMessage:@"手机号认证失败"];
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        [SVProgressHUD dismiss];
        [RCToast showMessage:msg];
    }];
}

#pragma mark - 匹配薪资
- (void)matchSalary{
    NSString *regionID = self.dataParam[@"JobPlace"];
    NSString *jobTypeID = self.dataParam[@"JobType"];
    if (regionID && jobTypeID) {
        NSArray *jobTypeArr = [jobTypeID componentsSeparatedByString:@" "];
        if (jobTypeArr.count > 0) {
            jobTypeID = [jobTypeArr firstObject];
        }
        NSDictionary *paramDict = @{@"RegionID":regionID,@"JobTypeID":jobTypeID};
        [AFNManager requestWithMethod:POST ParamDict:paramDict url:URL_GETSALARYJOBSTRING tableName:@"" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
            DLog(@"");
            NSString *resultStr = (NSString *)dataDict;
            if (resultStr == nil) {
                return ;
            }
            NSArray *resultArr = [resultStr componentsSeparatedByString:@","];
            if (resultArr.count > 0) {
                NSString *salaryId = [resultArr firstObject];
                NSArray *salaryValue = [resultArr lastObject];
                [self.dataParam setValue:salaryId forKey:@"Salary"];
                
                NSString *negotiableStr = self.dataParam[@"Negotiable"];
                if (negotiableStr == nil || negotiableStr.length == 0) {
                    negotiableStr = @"1";
                    [self.dataParam setValue:negotiableStr forKey:@"Negotiable"];
                }
                
                [self resetDataValue:[NSString stringWithFormat:@"%@ %@", salaryValue, ([negotiableStr isEqualToString:@"0"] ? @"不可面议" : @"可面议")] key:@"期望月薪"];
                [self.tableview reloadData];
                
            }
        } failureBlock:^(NSInteger errCode, NSString *msg) {
            DLog(@"");
        }];
    }
}
@end
