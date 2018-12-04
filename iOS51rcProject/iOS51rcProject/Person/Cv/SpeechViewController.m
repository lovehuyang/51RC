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

@interface SpeechViewController ()<AVAudioPlayerDelegate>
{
    NSInteger index;
}
@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSArray *voiceData;// 音乐名数组
@property (nonatomic, strong) VoiceWaveImgView *voiceWaveImgView;// 声波图
@property (nonatomic, strong) UILabel *titleLab;// 标题
@property (nonatomic, strong) SpeakBtn *speakBtn;// 话筒按钮

@end

@implementation SpeechViewController
- (instancetype)init{
    if (self = [super init]) {
        self.view.backgroundColor = UIColorFromHex(0x0B033B);
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    index = 0;
    
    [self setupCloseBtn];
    
    // 创建标题
    [self setupTipLab];
    // 创建声波
    [self setupVoiceWave];
    // 创建“点击说话”按钮
    [self createSpeakButton];
    
    [self.audioPlayer play];// 开始播放
}

- (NSArray *)voiceData{
    if (!_voiceData) {
        _voiceData = [VoiceModel createVoiceModel:1];
    }
    return _voiceData;
}

- (AVAudioPlayer *)audioPlayer{
    if (!_audioPlayer) {
        VoiceModel *model = [self.voiceData objectAtIndex:index];
        NSURL *url = [NSURL fileURLWithPath:model.voicePath];
        _audioPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        _audioPlayer.delegate = self;
        [_audioPlayer prepareToPlay];
    }
    return _audioPlayer;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.audioPlayer = nil;
    self.voiceWaveImgView.hidden = NO;
    self.speakBtn.hidden = YES;
    index ++;
    if (index >= self.voiceData.count) {
        index = 0;
    }
    [self setupTipLab];
    [self.audioPlayer play];
}

#pragma mark - AVAudioPlayerDelegate
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
   
    DLog(@"播放完毕");
    self.voiceWaveImgView.hidden = YES;
    self.speakBtn.hidden = NO;
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
    self.voiceWaveImgView = [VoiceWaveImgView new];
    [self.view addSubview:self.voiceWaveImgView];
    self.voiceWaveImgView.sd_layout
    .centerXEqualToView(self.view)
    .centerYEqualToView(self.view)
    .leftSpaceToView(self.view, 0)
    .rightSpaceToView(self.view, 0)
    .heightIs(100);
}

#pragma mark - 点击说话按钮
- (void)createSpeakButton{
    if(self.speakBtn == nil){
        SpeakBtn *speakBtn = [SpeakBtn new];
        [self.view addSubview:speakBtn];
        speakBtn.sd_layout
        .bottomSpaceToView(self.view, 20)
        .centerXEqualToView(self.view)
        .widthIs(60)
        .heightIs(80);
        [speakBtn setTitle:@"点击说话" forState:UIControlStateNormal];
        [speakBtn setImage:[UIImage imageNamed:@"speak_icon"] forState:UIControlStateNormal];
        self.speakBtn = speakBtn;
        self.speakBtn.hidden = YES;
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
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    [WeakAlertView show];
}

@end
