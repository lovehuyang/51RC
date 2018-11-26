//
//  InputAlertView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/16.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "InputAlertView.h"

@interface InputAlertView()<UITextViewDelegate>
/**
 *  背景view
 */
@property (nonatomic,strong) UIView *backgroundView;
/**
 *  AlertView
 */
@property (nonatomic,strong) UIView *alertview;
/**
 *  标题栏
 */
@property (nonatomic,strong) UILabel *titleLable;
/**
 *  内容
 */
@property (nonatomic,strong) UITextView *textView;
/**
 *  标题
 */
@property (nonatomic,strong) NSString *titleStr;
/**
 *  提示内容
 */
@property (nonatomic,strong) NSString *contentStr;

/**
 *  点击背景view是不是可以消失,默认为yes,点击背景可以消失
 */
@property (nonatomic,assign) BOOL canDissmiss;

/**
 *  存放按钮标题的数组
 */
@property (nonatomic ,strong)NSArray *btnTitleArr;

@property (nonatomic , strong)NSString *inputStr;// 输入内容
@end

@implementation InputAlertView

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _inputStr = @"";
        _backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT)];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0.5;
        _backgroundView.userInteractionEnabled = YES;
        [self addSubview:self.backgroundView];
        
        //创建alertView
        CGFloat alertviewW = 270 ;
        CGFloat alertviewH = 200;
        _alertview = [[UIView alloc]initWithFrame:CGRectMake(SCREEN_WIDTH *0.5 - alertviewW *0.5, (SCREEN_HEIGHT - 44 - HEIGHT_STATUS) *0.5 - alertviewH *0.5, alertviewW, alertviewH)];
        self.alertview.center = CGPointMake(self.center.x, self.center.y);
        self.alertview.layer.masksToBounds = YES;
        self.alertview.layer.cornerRadius = 5;
        self.alertview.clipsToBounds = YES;
        self.alertview.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertview];
        
        //监听当键盘将要出现时
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillShow:)
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        //监听当键将要退出时
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
    return self;
}

- (void)layoutSubviews{
    
    [super layoutSubviews];
    //添加标题
    _titleLable = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, self.alertview.frame.size.width, 25)];
    _titleLable.textAlignment = NSTextAlignmentCenter;
//    [_titleLable setBackgroundColor:[UIColor yellowColor]];
    _titleLable.text = self.titleStr;
    [_titleLable setFont:DEFAULTFONT];
    [_titleLable setTextColor:[UIColor blackColor]];
    [self.alertview addSubview:self.titleLable];
    
    UILabel *contentLab = [[UILabel alloc]initWithFrame:CGRectMake(0, VIEW_BY(_titleLable), VIEW_W(_titleLable), 25)];
    contentLab.text = self.contentStr;
    contentLab.textAlignment = NSTextAlignmentCenter;
    contentLab.font = DEFAULTFONT;
    [self.alertview addSubview:contentLab];
    
    self.textView = [UITextView new];
    self.textView.frame = CGRectMake(10, VIEW_BY(contentLab) , self.alertview.frame.size.width - 20  , 35 );
    self.textView.layer.borderColor =UIColorFromHex(0xB8B8B8).CGColor;
    self.textView.backgroundColor = UIColorFromHex(0xB8B8B8);
    self.textView.layer.borderWidth = 0.5;
    self.textView.layer.cornerRadius = 5;
    self.textView.font = DEFAULTFONT;
    [self.alertview addSubview:self.textView];
    self.textView.delegate = self;
    [self.textView becomeFirstResponder];
    
    [self.alertview setFrame:CGRectMake(self.alertview.frame.origin.x, self.alertview.frame.origin.y, self.alertview.frame.size.width, CGRectGetMaxY(self.textView.frame) + 55)];
    self.alertview.center = CGPointMake(self.center.x, self.center.y);
    
    CGFloat width = (CGRectGetWidth(self.alertview.frame) - 15 *(self.btnTitleArr.count + 1))/self.btnTitleArr.count ;
    for (int i = 0; i <self.btnTitleArr.count; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(15*(i + 1) + width *i, VIEW_BY(self.textView) + 10, width, 35);
        [btn setTitle:self.btnTitleArr[i] forState:UIControlStateNormal];
        btn.layer.cornerRadius = 3;
        
        if (i == 0) {
            btn.backgroundColor = [UIColor whiteColor];
            btn.layer.borderWidth = 0.5;
            btn.layer.borderColor = [UIColor lightGrayColor].CGColor;
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
                
        }else if (i == 1){
            btn.backgroundColor = NAVBARCOLOR;
        }
        
        btn.tag = 100+i;
        [btn addTarget:self action:@selector(clickButton:) forControlEvents:UIControlEventTouchUpInside];
        [btn.titleLabel setFont:DEFAULTFONT];
        [self.alertview addSubview:btn];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dissmiss)];
        [self addGestureRecognizer:tap];
    }
}

-(void)clickButton:(UIButton *)btn
{
    [self.textView resignFirstResponder];
    if (self.clickButtonBlock) {
        if(btn.tag == 101){
            if (self.inputStr.length == 0) {
                [RCToast showMessage:@"请输入您要屏蔽的关键词！"];
            }else{
                self.clickButtonBlock(btn,self.textView.text);
                self.canDissmiss = YES;
                [self dissmiss];
            }
            
        }else{
            self.canDissmiss = YES;
            [self dissmiss];
        }
    }
}

- (void)initWithTitle:(NSString *)title content:(NSString *)contentStr btnTitleArr :(NSArray *)btnTitleArr canDismiss:(BOOL )canDismiss{
    self.canDissmiss = canDismiss;
    self.titleStr = title;
    self.btnTitleArr = [NSArray arrayWithArray:btnTitleArr];
    self.contentStr = [NSString stringWithString:contentStr];
}

- (void)show:(UIView *)view {
//    [view addSubview:self];
    [[[UIApplication sharedApplication] keyWindow]addSubview:self];
    self.alertview.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
    
    [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.alertview.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        
    } completion:nil];
}

- (void)dissmiss {
    
    if (self.canDissmiss) {
        
        [UIView animateWithDuration:.3 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            _backgroundView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            [self.textView resignFirstResponder];
        }];
    }
}

//当键盘出现
- (void)keyboardWillShow:(NSNotification *)notification
{
    //获取键盘的高度
    NSDictionary *userInfo = [notification userInfo];
    NSValue *value = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [value CGRectValue];
    int height = keyboardRect.size.height;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.alertview.center = CGPointMake(self.center.x, self.centerY - height/3.5);
    }];
}

//当键退出
- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView animateWithDuration:0.5 animations:^{
        self.alertview.center = CGPointMake(self.center.x, self.center.y);
    }];
}


#pragma mark -- UITextViewDelegate
- (void)textViewDidChange:(UITextView *)textView{
    
    if(textView.text.length > 50){
        textView.text = self.inputStr;
        DLog(@"已经超出了最大输入数量%@",self.inputStr);
    }else{
        self.inputStr = textView.text;
        DLog(@"输入内容%@",self.inputStr);
    }
}
- (BOOL)textViewShouldEndEditing:(UITextView *)textView{
    return YES;
}
@end
