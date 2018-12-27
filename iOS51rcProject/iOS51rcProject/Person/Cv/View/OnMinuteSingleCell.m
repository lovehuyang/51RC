//
//  OnMinuteSingleCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "OnMinuteSingleCell.h"
#import "OneMinuteModel.h"

@interface OnMinuteSingleCell()<UITextFieldDelegate>
@property (nonatomic , strong) UIButton *getSecurityBtn;// 获取验证码的button
@property (nonatomic , strong) UIViewController *vc;
@end

@implementation OnMinuteSingleCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(id)data viewController:(UIViewController *)vc{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.vc = vc;
        if ([data isKindOfClass:[OneMinuteModel class]]) {
            [self setupSubViews:data];
        }else{
            [self setupSubViews2:(NSArray *)data];
        }
        
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(openCountdown) name:NOTIFICATION_ONEMINUTEGETVERIFYCODE object:nil];
    }
    return self;
}

#pragma mark - 一个文本框的cell
- (void)setupSubViews:(id)data{
    OneMinuteModel *model = (OneMinuteModel *)data;
    
    UIImageView *imgView = [UIImageView new];
    [self.contentView addSubview:imgView];
    
    imgView.sd_layout
    .leftSpaceToView(self.contentView, 15)
    .centerYEqualToView(self.contentView)
    .widthIs(15)
    .heightEqualToWidth();
    imgView.image = [UIImage imageNamed:@"pa_add"];

    UITextField *textTF = [UITextField new];
    [self.contentView addSubview:textTF];
    textTF.sd_layout
    .leftSpaceToView(imgView, 5)
    .centerYEqualToView(imgView)
    .rightSpaceToView(self.contentView, 10)
    .heightRatioToView(self.contentView, 0.9);
    textTF.placeholder = model.placeholderStr;
    textTF.text = model.contentStr;
    textTF.font = DEFAULTFONT;
    textTF.delegate = self;
    [textTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    // 短信验证码
    if ([model.placeholderStr containsString:@"短信"]) {
        textTF.sd_layout
        .rightSpaceToView(self.contentView, 100);
        self.getSecurityBtn = [UIButton new];
        [self.contentView addSubview:self.getSecurityBtn];
        self.getSecurityBtn.sd_layout
        .leftSpaceToView(textTF, 10)
        .rightSpaceToView(self.contentView, 10)
        .centerYEqualToView(textTF)
        .heightRatioToView(self.contentView, 0.6);
        self.getSecurityBtn.titleLabel.font = DEFAULTFONT;
        [self.getSecurityBtn setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        self.getSecurityBtn.layer.borderWidth = 1;
        self.getSecurityBtn.layer.borderColor = NAVBARCOLOR.CGColor;
        self.getSecurityBtn.layer.cornerRadius = 2;
        [self.getSecurityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
        [self.getSecurityBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
    }else if ([model.placeholderStr containsString:@"手机"]){
        textTF.keyboardType = UIKeyboardTypeNumberPad;
    }
}

#pragma mark -  两个文本框的cell
- (void)setupSubViews2:(NSArray *)dataArr{
    for (int i = 0; i < dataArr.count; i ++) {
        OneMinuteModel *model = [dataArr objectAtIndex:i];
        
        UIImageView *imgView = [UIImageView new];
        [self.contentView addSubview:imgView];
        
        imgView.sd_layout
        .leftSpaceToView(self.contentView, 15 + i * VIEW_W(self.contentView)/2)
        .centerYEqualToView(self.contentView)
        .widthIs(15)
        .heightEqualToWidth();
        imgView.image = [UIImage imageNamed:@"pa_add"];
        
        UITextField *textTF = [UITextField new];
        [self.contentView addSubview:textTF];
        textTF.sd_layout
        .leftSpaceToView(imgView, 5)
        .centerYEqualToView(imgView)
        .heightRatioToView(self.contentView, 0.9);
        textTF.placeholder = model.placeholderStr;
        textTF.text = model.contentStr;
        textTF.font = DEFAULTFONT;
        textTF.delegate = self;
        textTF.tag = 100 + i;
        [textTF addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        if (i == 1) {
            textTF.sd_layout
            .rightSpaceToView(self.contentView, 10);
        }else if (i == 0){
            textTF.sd_layout
            .widthIs(VIEW_W(self.contentView)/2 - 30);
        }
    }
}

#pragma mark - 监测文本框内容发生改变
-(void)textFieldDidChange :(UITextField *)theTextField{
    self.cellDidSelect(theTextField);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    NSString *placeHoderStr = textField.placeholder;
    
    if ([placeHoderStr isEqualToString:@"手机号码"]||[placeHoderStr isEqualToString:@"短信确认码"] || [placeHoderStr isEqualToString:@"姓名"]||[placeHoderStr isEqualToString:@"毕业院校"]) {
        
        return YES;
    }else{
        self.cellDidSelect(textField);
        [textField resignFirstResponder];
        [self.vc.view endEditing:YES];
        return NO;
    }
}

#pragma mark - 获取验证码
- (void)btnClick{
    self.getMobileVerifyCode();
}

#pragma mark -  发送验证码的倒计时操作
- (void)openCountdown{
    
    __block NSInteger time = 180; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.getSecurityBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
                
                self.getSecurityBtn.enabled = YES;
            });
            
        }else{
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.getSecurityBtn setTitle:[NSString stringWithFormat:@"%lds", (long)time] forState:UIControlStateNormal];
                
                self.getSecurityBtn.enabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
@end
