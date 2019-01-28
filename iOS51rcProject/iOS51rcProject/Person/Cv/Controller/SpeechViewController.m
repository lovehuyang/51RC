//
//  SpeechViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/3.
//  Copyright © 2018年 Jerry. All rights reserved.
//  语音输入页面

#import "SpeechViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "VoiceWaveImgView.h"
#import "VoiceModel.h"// 语音数据模型
#import "SpeakBtn.h"
#import "AlertView.h"
#import "OneMinuteModel.h"
#import "Common.h"

#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"

@interface SpeechViewController ()<AVAudioPlayerDelegate,BDSClientASRDelegate>
{
    NSInteger index;
}
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) AVAudioPlayer *errorPlayer;
@property (nonatomic, strong) NSMutableArray *voiceData;// 音乐名数组
@property (nonatomic, strong) UILabel *titleLab;// 标题
@property (nonatomic, strong) SpeakBtn *reSpeakBtn;// 重说按钮
@property (nonatomic, strong) UILabel *recognationLab;// 语音识别结果
@property (nonatomic, strong) NSTimer *timer;// 计时器

@property (strong, nonatomic) BDSEventManager *asrEventManager;// 语音识别管理类
@end

@implementation SpeechViewController
- (instancetype)init{
    if (self = [super init]) {
        index = 0;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromHex(0x0B033B);
    
    [self dealwithData];

    // 关闭按钮
    [self setupCloseBtn];
    // 创建标题
    [self setupTipLab];
    // 创建声波
    [self setupVoiceWave];
    // 展示语音识别结果的labble
    [self setupRecognationLab];
    // 创建“点击说话”按钮
    [self createSpeakButton];
    // 开始播放
    [self.audioPlayer play];
    // 配置语音识别
    [self configVoiceRecognitionClient];
}

- (NSMutableArray *)voiceData{
    if (!_voiceData) {
        _voiceData = [VoiceModel createVoiceModel:self.mobileVerify? 1: 0];
    }
    return _voiceData;
}

- (AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        // 启动扬声器
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
        [audioSession setActive:YES error:nil];
        
        VoiceModel *model = [self.voiceData objectAtIndex:index];
        NSURL *url = [NSURL fileURLWithPath:model.voicePath];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}

- (BDSEventManager *)asrEventManager{
    if (!_asrEventManager) {
        _asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
        [_asrEventManager setDelegate:self];
    }
    return _asrEventManager;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
    
}

- (void)playVedio:(NSString *)vedioName{
    self.errorPlayer = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:vedioName ofType:@"mp3"];
    NSURL *url = [NSURL fileURLWithPath:path];
    // 启动扬声器
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    [audioSession setActive:YES error:nil];
    self.errorPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
    self.errorPlayer.delegate = self;
    [self.errorPlayer prepareToPlay];
    [self.errorPlayer play];
    
    if([vedioName isEqualToString:@"“013”副本"]){
        [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
    }
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    
    if (player == self.audioPlayer) {
        // 启动语音识别
        [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
    
    }else{// player == self.errorPlayer
        self.reSpeakBtn.hidden = NO;
        self.recognationLab.text = @"请重试";
    }
}

#pragma mark - 标题
- (void)setupTipLab{
    if(self.titleLab == nil){
        self.titleLab = [UILabel new];
        [self.view addSubview:self.titleLab];
        self.titleLab.sd_layout
        .leftSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .topSpaceToView(self.view, 80)
        .heightIs(35);
        [self.titleLab setTextAlignment:NSTextAlignmentCenter];
        self.titleLab.textColor = [UIColor whiteColor];
         self.titleLab.font = [UIFont fontWithName:@"Helvetica-Bold" size:20];//加粗
    }
    VoiceModel *model = [self.voiceData objectAtIndex:index];
    self.titleLab.text = model.titleStr;
}

#pragma mark - 声波
- (void)setupVoiceWave{
    VoiceWaveImgView *voiceWaveImgView = [VoiceWaveImgView new];
    [self.view addSubview:voiceWaveImgView];
    voiceWaveImgView.sd_layout
    .centerXEqualToView(self.view)
    .centerYEqualToView(self.view)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(100);
}

#pragma mark - 语音识别结果labble
- (void)setupRecognationLab{
    self.recognationLab = [UILabel new];
    [self.view addSubview:_recognationLab];
    self.recognationLab.sd_layout
    .leftSpaceToView(self.view, 20)
    .rightSpaceToView(self.view, 20)
    .topSpaceToView(self.titleLab, 20)
    .autoHeightRatio(0);
    self.recognationLab.textAlignment = NSTextAlignmentCenter;
    self.recognationLab.font = [UIFont boldSystemFontOfSize:18];
    [self.recognationLab setTextColor:NAVBARCOLOR];
}

#pragma mark - 点击说话按钮
- (void)createSpeakButton{
    if(self.reSpeakBtn == nil){
        SpeakBtn *speakBtn = [SpeakBtn new];
        [self.view addSubview:speakBtn];
        speakBtn.sd_layout
        .bottomSpaceToView(self.view, 20)
        .centerXEqualToView(self.view)
        .widthIs(60)
        .heightIs(80);
        [speakBtn setTitle:@"重说" forState:UIControlStateNormal];
        [speakBtn setImage:[UIImage imageNamed:@"speak_icon"] forState:UIControlStateNormal];
        [speakBtn addTarget:self action:@selector(respeakEvent) forControlEvents:UIControlEventTouchUpInside];
        self.reSpeakBtn = speakBtn;
        self.reSpeakBtn.hidden = YES;
    }
}

#pragma mark - 关闭按钮
- (void)setupCloseBtn{
    UIButton *closeBtn = [UIButton new];
    [self.view addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(self.view, 10)
    .topSpaceToView(self.view, 20)
    .widthIs(44)
    .heightEqualToWidth();
    [closeBtn setImage:[UIImage imageNamed:@"img_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeBtnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)closeBtnClick{
    
    AlertView *alertView = [[AlertView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    __weak __typeof(alertView)WeakAlertView = alertView;
    [WeakAlertView initWithTitle:@"提示" content:@"确定退出语音填写模式么？" btnTitleArr:@[@"取消",@"确定"] canDismiss:YES];
    WeakAlertView.clickButtonBlock = ^(UIButton *button) {
        if (button.tag == 101) {
            [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [WeakAlertView show];
}

#pragma mark - 重说
- (void)respeakEvent{
    self.recognationLab.text = @"";
    self.reSpeakBtn.hidden = YES;
    [self stopTimer];
    // 启动语音识别
    [self.asrEventManager sendCommand:BDS_ASR_CMD_START];
}

#pragma mark - 配置语音识别
- (void)configVoiceRecognitionClient{
    // 设置DEBUG_LOG的级别
    [self.asrEventManager setParameter:@(EVRDebugLogLevelTrace) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    // 配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[BD_API_KEY, BD_SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:BD_APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    // 配置端点检测（二选一）
    [self configDNNMFE];
    // ---- 语义与标点 -----
    [self enableNLU];
}

#pragma mark - 端点检测
- (void)configDNNMFE {
    NSString *mfe_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_dnn" ofType:@"dat"];
    [self.asrEventManager setParameter:mfe_dnn_filepath forKey:BDS_ASR_MFE_DNN_DAT_FILE];
    NSString *cmvn_dnn_filepath = [[NSBundle mainBundle] pathForResource:@"bds_easr_mfe_cmvn" ofType:@"dat"];
    [self.asrEventManager setParameter:cmvn_dnn_filepath forKey:BDS_ASR_MFE_CMVN_DAT_FILE];
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_ENABLE_MODEL_VAD];
}

#pragma mark - 语义与标点
- (void) enableNLU {
    // 开启语义理解
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_NLU];
    [self.asrEventManager setParameter:@"1536" forKey:BDS_ASR_PRODUCT_ID];
}

- (void) enablePunctuation {
    // ---- 开启标点输出 -----
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_DISABLE_PUNCTUATION];
    // 普通话标点
    //    [self.asrEventManager setParameter:@"1537" forKey:BDS_ASR_PRODUCT_ID];
    // 英文标点
    [self.asrEventManager setParameter:@"1737" forKey:BDS_ASR_PRODUCT_ID];
}

#pragma mark - BDSClientASRDelegate

- (void)VoiceRecognitionClientWorkStatus:(int)workStatus obj:(id)aObj{
    switch (workStatus) {
        case EVoiceRecognitionClientWorkStatusNewRecordData: {

            DLog(@"录音数据回调");
            break;
        }
            
        case EVoiceRecognitionClientWorkStatusStartWorkIng: {
            DLog(@"识别工作开始");
            break;
        }
        case EVoiceRecognitionClientWorkStatusStart: {
            DLog(@"检测到用户开始说话");
            break;
        }
        case EVoiceRecognitionClientWorkStatusEnd: {
            DLog(@"本地声音采集结束，等待识别结果返回并结束录音");
            break;
        }
        case EVoiceRecognitionClientWorkStatusFlushData: {
            NSString *result = [NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]];
            [self voiceRecognition:(NSDictionary *)aObj status:NO];
            DLog(@"连续上屏");
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            NSString *result = [NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]];
            [self voiceRecognition:(NSDictionary *)aObj status:YES];
            DLog(@"语音识别功能完成，服务器返回正确结果\n%@",result);
            // 语音识别完成，显示重说按钮
            self.reSpeakBtn.hidden = NO;
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            DLog(@"用户取消");
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            DLog(@"发生错误");
            [self playVedio:@"“013”副本"];
            break;
        }
        case EVoiceRecognitionClientWorkStatusLoaded: {
            DLog(@"离线引擎加载完成");
            break;
        }
        case EVoiceRecognitionClientWorkStatusUnLoaded: {
            DLog(@"离线引擎卸载完成");
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkThirdData: {
            DLog(@"CHUNK: 识别结果中的第三方数据");
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkNlu: {
            DLog(@"CHUNK: 识别结果中的语义结果");
            break;
        }
        case EVoiceRecognitionClientWorkStatusChunkEnd: {
            DLog(@"CHUNK: 识别过程结束");
            [self openTimer];
            break;
        }
        case EVoiceRecognitionClientWorkStatusFeedback: {
            DLog(@"Feedback: 识别过程反馈的打点数据");
            break;
        }
        case EVoiceRecognitionClientWorkStatusRecorderEnd: {
            DLog(@"录音机关闭，页面跳转需检测此时间，规避状态条 (iOS)");
            break;
        }
        case EVoiceRecognitionClientWorkStatusLongSpeechEnd: {
            DLog(@"长语音结束状态");
            break;
        }
        default:
            break;
    }
}

- (NSString *)getDescriptionForDic:(NSDictionary *)dic {

    if (dic) {
        
        NSString *resultStr = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
        return resultStr;
    }
    return nil;
}

#pragma mark - 下一段语音
- (void)nextVedio{
    DLog(@"定时器事件执行");
    self.audioPlayer = nil;
    self.reSpeakBtn.hidden = YES;
    self.recognationLab.text = @"";
    
    index ++;
    if (index >= self.voiceData.count) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    [self setupTipLab];
    [self.audioPlayer play];
}

#pragma mark - 语音识别结果处理
/*
 @[@"你的手机号码是？",
 @"你是男士还是女士？",
 @"你的出生年、月是？",
 @"你的最高学历是？",
 @"毕业学校是？",
 @"你所学专业名称是？",
 @"你最期望的岗位是？",
 @"你的期望月薪是？",
 @"你的姓名是？"];
 */
- (void)voiceRecognition:(NSDictionary *)objc status:(BOOL)isFinish{
    // 回传参数
    NSArray *recognationArr = objc[@"results_recognition"] ;
    NSString *recognationStr = [recognationArr firstObject];
    self.recognationLab.text = recognationStr;
    
    if(!isFinish){
        return;
    }
    VoiceModel *model = self.voiceData[index];
    model.recognationStr = recognationStr;

    if([model.titleStr containsString:@"手机号码"]){
        NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:model.recognationStr};
        self.speakContentBlock(dict);
        self.speakRestParam(@"Mobile", model.recognationStr);
        
    }else if ([model.titleStr containsString:@"男士"]){
        if([model.recognationStr containsString:@"男"] || [model.recognationStr containsString:@"爷"] || [model.recognationStr containsString:@"伙"] ||[model.recognationStr containsString:@"雄"]  ||[model.recognationStr containsString:@"父"] || [model.recognationStr containsString:@"爸"]  ||[model.recognationStr containsString:@"儿"]||[model.recognationStr containsString:@"兄"]||[model.recognationStr containsString:@"哥"]||[model.recognationStr containsString:@"弟"]){
            self.speakRestParam(@"Gender", @"0");// 性别
            NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:@"男"};
            self.speakContentBlock(dict);
        }else{
            self.speakRestParam(@"Gender",@"1");
            NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:@"女"};
            self.speakContentBlock(dict);
        }
        
    }else if ([model.titleStr containsString:@"出生年"]){
        if (model.recognationStr.length<=4) {
            return;
        }
        
        NSString *year = @"";
        NSString *month = @"";
        
        if(![model.recognationStr containsString:@"年"] && model.recognationStr.length> 4){// 不包含“年”字的语音
            year = [model.recognationStr substringWithRange:NSMakeRange(0, 4)];
            NSString *tempMonth = [model.recognationStr substringWithRange:NSMakeRange(year.length, model.recognationStr.length - year.length)];
            if (tempMonth.length == 4) {
                if([tempMonth hasPrefix:@"0"]){
                    month = [tempMonth substringWithRange:NSMakeRange(1, 1)];
                }else{
                    NSString *tempMonthStr = [tempMonth substringWithRange:NSMakeRange(0, 2)];
                    if ([tempMonthStr integerValue] > 12) {
                        month = [tempMonth substringWithRange:NSMakeRange(0, 1)];
                    }
                }
            
            }else if(tempMonth.length >2){
                if ([tempMonth hasPrefix:@"0"]) {
                    month = [NSString stringWithFormat:@"%@",[tempMonth substringWithRange:NSMakeRange(1, 1)]];
                }else{
                    NSString *tempMonthStr = [tempMonth substringWithRange:NSMakeRange(0, 2)];
                    if ([tempMonthStr integerValue] > 12) {
                        month = [tempMonth substringWithRange:NSMakeRange(0, 1)];
                    }else{
                        month = [NSString stringWithFormat:@"%@",tempMonthStr];
                    }
                }
            }else if (tempMonth.length == 2){
                if ([tempMonth hasPrefix:@"0"]) {
                    month = [tempMonth substringWithRange:NSMakeRange(1, 1)];
                }else{
                    if([tempMonth integerValue]> 12){
                        month = [tempMonth substringWithRange:NSMakeRange(0, 1)];
                    }else{
                       month = [NSString stringWithFormat:@"%@",tempMonth];
                    }
                }
            }else{
                month = [NSString stringWithFormat:@"%@",tempMonth];
            }
            DLog(@"出生年：%@  月：%@",year,month);
            if(month.length == 1){
                month = [NSString stringWithFormat:@"0%@",month];
            }
            self.speakRestParam(@"Birthday", [NSString stringWithFormat:@"%@%@",year, month]);
            NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:[NSString stringWithFormat:@"%@年%@月",year, month]};
            self.speakContentBlock(dict);
            return;
        }
//        NSString *birth = [Common translatBirth:model.recognationStr];
        NSString *birth = model.recognationStr;
        NSArray *yearArr = [birth componentsSeparatedByString:@"年"];
        
        if (yearArr.count > 0) {
            
            year = [yearArr firstObject];
            if (![Common deptNumInputShouldNumber:year]) {
                DLog(@"");
                
                year = [Common translatNum:year];
            }
            if(year.length == 2){
                if ( [year integerValue]/10 > 0) {
                    year = [NSString stringWithFormat:@"19%@",year];
                }else{
                    year = [NSString stringWithFormat:@"20%@",year];
                }
            }
            
            NSArray *tempArr = [[yearArr lastObject] componentsSeparatedByString:@"年"];
            if(tempArr.count > 0){
                NSArray *monthArr = [[tempArr lastObject] componentsSeparatedByString:@"月"];
                month = [monthArr firstObject];
                if ( ![Common deptNumInputShouldNumber:month]) {
                    month = [Common translatNum:month];
                }
                if(month.length == 0){
                    month = @"01";
                }
                DLog(@"出生年：%@  月：%@",year,month);
                if(month.length == 1){
                    month = [NSString stringWithFormat:@"0%@",month];
                }
                self.speakRestParam(@"Birthday", [NSString stringWithFormat:@"%@%@",year, month]);
                NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:[NSString stringWithFormat:@"%@年%@月",year, month]};
                self.speakContentBlock(dict);
            }
        }else{
            return;
        }
    }else if([model.titleStr containsString:@"最高学历"]){
        NSArray *educationArr = [Common getEducation];
        for (NSDictionary *tempDict in educationArr) {
            NSString *value = tempDict[@"value"];
            if ([model.recognationStr containsString:value]) {
                self.speakRestParam(@"Education", tempDict[@"id"]);
                NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:value};
                self.speakContentBlock(dict);
                return;
            }
        }
    }else if ([model.titleStr containsString:@"毕业学校"]){
        self.speakRestParam(@"College", model.recognationStr);
        NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:model.recognationStr};
        self.speakContentBlock(dict);
    }else if ([model.titleStr containsString:@"专业名称"]){
        NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:model.recognationStr};
        self.speakContentBlock(dict);
        self.speakRestParam(@"MajorName", model.recognationStr);
        // 获取专业类别
        [self getMajor:model];
    }else if ([model.titleStr containsString:@"岗位"]){
        [self getCvVoiceJobType:model];
    }else if ([model.titleStr containsString:@"期望月薪"]){
        NSString *salay = [Common translatNum:model.recognationStr];// 把汉字数字转阿拉伯数字
        NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:[NSString stringWithFormat:@"%@ 可面议",[self getSalaryDegree:salay]]};
        self.speakContentBlock(dict);
        self.speakRestParam(@"Salary", [self getSalaryId:[self getSalaryDegree:salay]]);
    }else if ([model.titleStr containsString:@"姓名"]){
        NSDictionary *dict = @{[self transformToLastPageKey:model.titleStr]:model.recognationStr};
        self.speakContentBlock(dict);
        self.speakRestParam(@"Name", model.recognationStr);
    }
}

#pragma mark - 根据语音获取职位类别
- (void)getCvVoiceJobType:(VoiceModel *)voiceModel{
    NSDictionary *parmaDict = @{@"voiceText":voiceModel.recognationStr};
    [AFNManager requestWithMethod:POST ParamDict:parmaDict url:URL_GETCVVOICEJOBTYPE tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        DLog(@"");
        if (requestData.count > 0) {
            NSMutableString *mutStr = [NSMutableString string];
            NSMutableString *idStr = [NSMutableString string];
            for (int i = 0; i < requestData.count; i ++) {
                NSDictionary *dict = requestData[i];
                if(i < requestData.count - 1){
                    [mutStr appendFormat:@"%@ ",dict[@"Description"]];
                    [idStr appendFormat:@"%@ ",dict[@"dcJobTypeID"]];
                }else{
                    [mutStr appendFormat:@"%@",dict[@"Description"]];
                    [idStr appendFormat:@"%@",dict[@"dcJobTypeID"]];
                }
            }
    
            NSDictionary *dict = @{[self transformToLastPageKey:voiceModel.titleStr]:mutStr};
            self.speakContentBlock(dict);
            self.speakRestParam(@"JobType", idStr);
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}


#pragma mark - 根据专业名称获取专业类别

- (void)getMajor:(VoiceModel *)voiceModel{
    NSDictionary *paramDict = @{@"majorName":voiceModel.recognationStr};
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"GetMajor" tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        if(dataDict != nil && [dataDict isKindOfClass:[NSDictionary class]]){
            NSString *value = dataDict[@"Major"];
            if (value == nil || [value isKindOfClass:[NSNull class]]) {
                return ;
            }
            NSDictionary *dict = @{@"专业类别":dataDict[@"Major"]};
            self.speakContentBlock(dict);
            self.speakRestParam(@"MajorID", dataDict[@"dcMajorId"]);
        }
        
    } failureBlock:^(NSInteger errCode, NSString *msg) {
        DLog(@"");
    }];
}

#pragma mark - 计时器
- (void)openTimer{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
    // 开启下一段语音识别
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(nextVedio) userInfo:nil repeats:NO];
    DLog(@"定时器开启");
}

- (void)stopTimer {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
        DLog(@"定时器取消");
    }
}

- (void)dealloc {
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

#pragma mark - 筛选出已经填写的项
- (void)dealwithData{
    
    NSMutableArray *notEmptyArr = [NSMutableArray array];
    
    for (int i = 0; i < self.dataArr.count; i ++) {
        id object = self.dataArr[i];
        if ([object isKindOfClass:[OneMinuteModel class]]) {
            OneMinuteModel *model = (OneMinuteModel *)object;
            if (model.contentStr.length > 0) {
                [notEmptyArr addObject:model];
            }
            
        }else if([object isKindOfClass:[NSArray class]]){
            NSArray *subDataArr = (NSArray *)object;
            for (int j = 0; j < subDataArr.count; j ++) {
                id object2 = subDataArr[j];
                OneMinuteModel *model2 = (OneMinuteModel *)object2;
                if (model2.contentStr.length > 0) {
                    [notEmptyArr addObject:model2];
                }
            }
        }
    }
    
    for (OneMinuteModel *model in notEmptyArr) {
        if ([model.placeholderStr containsString:@"姓名"]) {
            [self deleteDataElement:@"姓名"];
        }else if ([model.placeholderStr containsString:@"手机号码"]){
            [self deleteDataElement:@"手机号码"];
        }else if ([model.placeholderStr containsString:@"性别"]){
            [self deleteDataElement:@"男士还是女士"];
        }else if ([model.placeholderStr containsString:@"出生年月"]){
            [self deleteDataElement:@"出生年"];
        }else if ([model.placeholderStr containsString:@"毕业院校"]){
            [self deleteDataElement:@"毕业学校"];
        }else if ([model.placeholderStr containsString:@"学历"]){
            [self deleteDataElement:@"学历"];
        }else if ([model.placeholderStr containsString:@"专业名称"]){
            [self deleteDataElement:@"专业名称"];
        }else if ([model.placeholderStr containsString:@"职位类别"]){
            [self deleteDataElement:@"岗位"];
        }else if ([model.placeholderStr containsString:@"期望月薪"]){
            [self deleteDataElement:@"期望月薪"];
        }
    }
}
/*
 
 @[@"手机号码",
 @"短信确认码",
 @[@"姓名",@"性别"],
 @"出生年月",
 @[@"毕业院校",@"学历"],
 @[@"专业名称",@"专业类别"],
 @[@"期望工作地点",@"期望职位类别"],
 @"期望月薪",@"求职状态"];
 
 */

/*
 @[@"你的手机号码是？",
 @"你是男士还是女士？",
 @"你的出生年、月是？",
 @"你的最高学历是？",
 @"毕业学校是？",
 @"你所学专业名称是？",
 @"你最期望的岗位是？",
 @"你的期望月薪是？",
 @"你的姓名是？"];
 */
// 删除数据源的元素
- (void)deleteDataElement:(NSString *)keyStr{
    NSArray *tempArr = [NSArray arrayWithArray:self.voiceData];
    for (VoiceModel *model in tempArr) {
        if ([model.titleStr containsString:keyStr]) {
            [self.voiceData removeObject:model];
        }
    }
}

#pragma mark - 把当前数据源key的值转成上个页面的key
- (NSString *)transformToLastPageKey:(NSString *)nowKey{
    if ([nowKey containsString:@"手机号码"]) {
        return @"手机号码";
    }else if ([nowKey containsString:@"男士还是女士"]){
        return @"性别";
    }else if ([nowKey containsString:@"姓名"]){
        return @"姓名";
    }else if ([nowKey containsString:@"出生年"]){
        return @"出生年月";
    }else if ([nowKey containsString:@"毕业学校"]){
        return @"毕业院校";
    }else if ([nowKey containsString:@"学历"]){
        return @"学历";
    }else if ([nowKey containsString:@"专业名称"]){
        return @"专业名称";
    }else if ([nowKey containsString:@"岗位"]){
        return @"职位类别";
    }else if ([nowKey containsString:@"期望月薪"]){
        return @"期望月薪";
    }
    return @"";
}

#pragma mark - 获取薪资范围
- (NSString *)getSalaryDegree:(NSString *)salary{
    
    NSInteger averageSearchSalary = [salary integerValue];
    
    if (averageSearchSalary >= 20000) {
        return @"20000元以上";
    }
    else if (averageSearchSalary >= 15000)
    {
        return @"15000元以上";
    }
    else if (averageSearchSalary >= 10000)
    {
        return @"10000元以上";
    }
    else if (averageSearchSalary >= 8000)
    {
        return @"8000元以上";
    }
    else if (averageSearchSalary >= 6000)
    {
        return @"6000元以上";
    }
    else if (averageSearchSalary >= 5000)
    {
        return @"5000元以上";
    }
    else if (averageSearchSalary >= 4000)
    {
        return @"4000元以上";
    }
    else if (averageSearchSalary >= 3500)
    {
        return @"3500元以上";
    }
    else if (averageSearchSalary >= 3000)
    {
        return @"3000元以上";
    }
    else if (averageSearchSalary >= 2500)
    {
        return @"2500元以上";
    }
    else if (averageSearchSalary >= 2000)
    {
        return @"2000元以上";
    }
    else if (averageSearchSalary >= 1500)
    {
        return @"1500元以上";
    }
    else if (averageSearchSalary > 0)
    {
        return @"1000元以上";
    }else{
        return @"";
    }
}

#pragma mark - 获取月薪id
- (NSString *)getSalaryId:(NSString *)salaryDegree{
    NSArray *salaryArr = [Common getSalary];
    for (NSDictionary *dict in salaryArr) {
        if ([salaryDegree isEqualToString:dict[@"value"]]) {
            return dict[@"id"];
        }
    }
    return @"";
}
@end
