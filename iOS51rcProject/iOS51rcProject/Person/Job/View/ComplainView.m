//
//  ComplainView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "ComplainView.h"

@interface ComplainView()<UITextViewDelegate>
@end

@implementation ComplainView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content textViewHeight:(CGFloat)height{
    if (self = [super initWithFrame:frame]) {
        _content = content;
        [self setupSubViewsTitle:title content:content textViewHeight:height];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}

// 初始化子控件
- (void)setupSubViewsTitle:(NSString *)title content:(NSString *)content textViewHeight:(CGFloat)height{
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(0, 0, self.frame.size.width, 25);
    [self addSubview:titleLab];
    titleLab.text = title;
    titleLab.backgroundColor = UIColorWithRGBA(215, 215, 215, 1);
    titleLab.font = DEFAULTFONT;
    
    UITextView *textView = [UITextView new];
    textView.frame = CGRectMake(0, CGRectGetMaxY(titleLab.frame), self.frame.size.width, self.frame.size.height - CGRectGetMaxY(titleLab.frame));
    textView.text = self.content;
    textView.font = DEFAULTFONT;
    [self addSubview:textView];
    textView.delegate = self;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView{
    self.content = textView.text;
}

@end
