//
//  LongVoiceInputController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "LongVoiceInputController.h"
#import "SpecialityModifyViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIView+Toast.h"
#import "NetWebServiceRequest.h"
#import "SpeakLoadingBtn.h"

#import "BDSEventManager.h"
#import "BDSASRDefines.h"
#import "BDSASRParameters.h"

@interface LongVoiceInputController ()<BDSClientASRDelegate,UITextViewDelegate>

@property (nonatomic , assign) BOOL longPressFlag;//yes时为正在进行长语音识别
@property (nonatomic , strong) UITextView *txtSpeciality;
@property (nonatomic , strong) SpeakLoadingBtn *speakBtn;
@property (nonatomic , strong) BDSEventManager *asrEventManager;// 语音识别管理类

@end

@implementation LongVoiceInputController

- (void)viewDidLoad {
    [super viewDidLoad];
    [Common changeFontSize:self.view];
    [self.view setBackgroundColor:SEPARATECOLOR];
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveSpeciality)];
    [btnSave setTintColor:[UIColor whiteColor]];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    self.txtSpeciality = [[UITextView alloc] initWithFrame:CGRectMake(15, 20, SCREEN_WIDTH - 30, 100)];
    [self.txtSpeciality setBackgroundColor:[UIColor whiteColor]];
    if (self.detail == nil) {
        self.detail = @"";
    }
    [self.txtSpeciality setText:self.detail];
    [self.txtSpeciality setFont:DEFAULTFONT];
    [self.txtSpeciality.layer setCornerRadius:5];
    [self.txtSpeciality setDelegate:self];
    [self.view addSubview:self.txtSpeciality];
    
    UILabel *tipLab = [UILabel new];
    [self.view addSubview:tipLab];
    tipLab.sd_layout
    .leftEqualToView(self.txtSpeciality)
    .topSpaceToView(self.txtSpeciality, 20)
    .rightEqualToView(self.txtSpeciality)
    .autoHeightRatio(0);
    tipLab.text = self.tipStr;
    tipLab.textColor = TEXTGRAYCOLOR;
    tipLab.font = DEFAULTFONT;
    
    self.speakBtn = [SpeakLoadingBtn new];
    [self.view addSubview:self.speakBtn];
    self.speakBtn.sd_layout
    .bottomSpaceToView(self.view, 10)
    .centerXEqualToView(self.view)
    .widthIs(200)
    .heightIs(80);
    __weak typeof(self)weakself = self;
    self.speakBtn.speakStatus = ^(BOOL speaking) {
        if (speaking) {
            NSLog(@"说话中");
            [weakself.asrEventManager sendCommand:BDS_ASR_CMD_START];
        }else{
            NSLog(@"暂停中");
            [weakself.asrEventManager sendCommand:BDS_ASR_CMD_STOP];
        }
    };
    [self longSpeechRecognition];
}

- (BDSEventManager *)asrEventManager{
    if (!_asrEventManager) {
        _asrEventManager = [BDSEventManager createEventManagerWithName:BDS_ASR_NAME];
        [_asrEventManager setDelegate:self];
    }
    return _asrEventManager;
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
}

- (void)saveSpeciality {
    [self.view endEditing:YES];
    self.detailContent(self.txtSpeciality.text);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    DLog(@"文字发生了改变：%@",textView.text);
    self.detail = textView.text;
}
#pragma mark - 配置语音识别
- (void)longSpeechRecognition{
    self.longPressFlag = NO;
    // 设置DEBUG_LOG的级别
    [self.asrEventManager setParameter:@(EVRDebugLogLevelTrace) forKey:BDS_ASR_DEBUG_LOG_LEVEL];
    // 配置API_KEY 和 SECRET_KEY 和 APP_ID
    [self.asrEventManager setParameter:@[BD_API_KEY, BD_SECRET_KEY] forKey:BDS_ASR_API_SECRET_KEYS];
    [self.asrEventManager setParameter:BD_APP_ID forKey:BDS_ASR_OFFLINE_APP_CODE];
    // 配置端点检测（二选一）
    [self configDNNMFE];
    // ---- 语义与标点 -----
    [self enableNLU];
    
    // 长语音识别
    [self.asrEventManager setParameter:@(NO) forKey:BDS_ASR_NEED_CACHE_AUDIO];
    [self.asrEventManager setParameter:@"" forKey:BDS_ASR_OFFLINE_ENGINE_TRIGGERED_WAKEUP_WORD];
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LONG_SPEECH];
    // 长语音请务必开启本地VAD
    [self.asrEventManager setParameter:@(YES) forKey:BDS_ASR_ENABLE_LOCAL_VAD];
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
            self.longPressFlag = YES;
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
            DLog(@"连续上屏\n%@",result);
            break;
        }
        case EVoiceRecognitionClientWorkStatusFinish: {
            NSString *result = [NSString stringWithFormat:@"CALLBACK: final result - %@.\n\n", [self getDescriptionForDic:aObj]];
            [self voiceRecognition:(NSDictionary *)aObj status:YES];
            DLog(@"语音识别功能完成，服务器返回正确结果\n%@",result);
            self.longPressFlag = NO;
            break;
        }
        case EVoiceRecognitionClientWorkStatusMeterLevel: {
            break;
        }
        case EVoiceRecognitionClientWorkStatusCancel: {
            DLog(@"用户取消");
            self.longPressFlag = NO;
            break;
        }
        case EVoiceRecognitionClientWorkStatusError: {
            DLog(@"发生错误");
            [RCToast showMessage:@"语音识别发生错误"];
            self.longPressFlag = NO;
            [self.asrEventManager sendCommand:BDS_ASR_CMD_CANCEL];
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
            self.longPressFlag = NO;
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

#pragma mark - 处理语音识别
- (void)voiceRecognition:(NSDictionary *)objc status:(BOOL)isFinish{
    
    NSArray *recognationArr = objc[@"results_recognition"] ;
    NSString *recognationStr = [recognationArr firstObject];
    
    if (!isFinish) {// 正在识别中
        self.txtSpeciality.text = [NSString stringWithFormat:@"%@%@",self.detail,recognationStr];
        
    }else{// 该段识别结束
        self.txtSpeciality.text = [NSString stringWithFormat:@"%@%@",self.detail,recognationStr];
        self.detail = self.txtSpeciality.text;
    }
    DLog(@"语音识别内容：%@",recognationStr);
}


@end
