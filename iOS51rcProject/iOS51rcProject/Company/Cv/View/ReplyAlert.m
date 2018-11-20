//
//  ReplyAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/20.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "ReplyAlert.h"
#import <UIKit/UIKit.h>

@interface ReplyAlert()
{
    UIView *alertView;
    UIView *backgroundView;
    UILabel *contentLab;
}
@end

@implementation ReplyAlert

- (instancetype)init{
    if (self = [super init]) {
        self.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
        backgroundView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        backgroundView.backgroundColor = [UIColor blackColor];
        backgroundView.userInteractionEnabled = YES;
        [self addSubview:backgroundView];
        backgroundView.alpha = 0;
        backgroundView.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        
        alertView = [UIView new];
        [self addSubview:alertView];
        alertView.sd_layout
        .leftSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .topSpaceToView(self,SCREEN_HEIGHT)
        .heightIs(180);
        alertView.backgroundColor = [UIColor whiteColor];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissView)];
        [backgroundView addGestureRecognizer:tap];
        
        [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(animation) userInfo:nil repeats:NO];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIButton *closeBtn = [UIButton new];
    [alertView addSubview:closeBtn];
    closeBtn.sd_layout
    .rightSpaceToView(alertView, 5)
    .topSpaceToView(alertView, 5)
    .widthIs(30)
    .heightEqualToWidth();
    [closeBtn setImage:[UIImage imageNamed:@"guanbi_orange"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(closeEvent) forControlEvents:UIControlEventTouchUpInside];
    
    contentLab = [UILabel new];
    [alertView addSubview:contentLab];
    contentLab.sd_layout
    .leftSpaceToView(alertView, 20)
    .topSpaceToView(closeBtn, 20)
    .rightSpaceToView(alertView, 10)
    .autoHeightRatio(0);
    [self setAttribute];
    contentLab.font = DEFAULTFONT;
    
    UIButton *btn1 = [UIButton new];
    [alertView addSubview:btn1];
    btn1.sd_layout
    .leftSpaceToView(alertView, 20)
    .topSpaceToView(contentLab, 25)
    .widthIs(SCREEN_WIDTH/2 - 20 - 10)
    .heightIs(35);
    btn1.backgroundColor = [UIColor blueColor];
    [btn1 setTitle:@"简历符合要求，我会联系TA" forState:UIControlStateNormal];
    btn1.titleLabel.font = SMALLERFONT;
    btn1.sd_cornerRadius = @(3);
    btn1.backgroundColor = CPNAVBARCOLOR;
    btn1.tag = 100;
    [btn1 addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *btn2 = [UIButton new];
    [alertView addSubview:btn2];
    btn2.sd_layout
    .topEqualToView(btn1)
    .rightSpaceToView(alertView, 20)
    .heightRatioToView(btn1, 1)
    .widthRatioToView(btn1, 1);
    btn2.backgroundColor = [UIColor orangeColor];
    btn2.sd_cornerRadius = btn1.sd_cornerRadius;
    btn2.backgroundColor = NAVBARCOLOR;
    btn2.tag = 101;
    [btn2 addTarget:self action:@selector(replyClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn2 setTitle:@"暂不合适，放入储备人才库" forState:UIControlStateNormal];
    btn2.titleLabel.font = btn1.titleLabel.font;
    
    [alertView setupAutoHeightWithBottomView:btn2 bottomMargin:35];
}

- (void)setName:(NSString *)name{
    _name = name;
}

#pragma mark - 富文本操作
- (void)setAttribute{
    NSString *contStr = [NSString stringWithFormat:@"答复求职者%@求职申请，积极答复就会赠送10积分哟~",_name];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:8];
    
    NSMutableAttributedString *attributedStr = [[NSMutableAttributedString alloc]initWithString:contStr];
    
    [attributedStr addAttribute:NSForegroundColorAttributeName
          
                                       value:GREENCOLOR
          
                                       range:NSMakeRange(5, _name.length)];
    [attributedStr addAttribute:NSForegroundColorAttributeName
     
                          value:[UIColor redColor]
     
                          range:NSMakeRange(contStr.length - 6, 2)];
    
    [attributedStr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, contStr.length)];
    
    
    contentLab.attributedText = attributedStr;
}

- (void)replyClick:(UIButton *)btn{
    [self dismissView];
    self.replyBlock(btn.tag);
}

#pragma mark - 消失
- (void)dismissView{
    
    [UIView animateWithDuration:0.4 animations:^{
        alertView.sd_layout
        .bottomSpaceToView(self, -SCREEN_HEIGHT);
        [alertView updateLayout];
        backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - 出现
- (void)animation{
    [UIView animateWithDuration:0.4 animations:^{
        alertView.sd_layout
        .bottomSpaceToView(self, 0);
        [alertView updateLayout];
        backgroundView.alpha = 0.3;
    } completion:^(BOOL finished) {
        
    }];
}
#pragma mark - 关闭
- (void)closeEvent{
    [self dismissView];
}
@end
