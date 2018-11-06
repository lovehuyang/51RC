//
//  OptionView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/30.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "OptionView.h"
#import "TABButton.h"

@implementation OptionView
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubViews];
        
    }
    return self;
}

// 布局子空间
- (void)setupSubViews{
    NSArray *titleArr = @[@"招聘会",@"查工资",@"就业资讯",@"人才测评"];
    NSArray *imgArr = @[@"p_mine_job",@"p_mine_ salary",@"p_mine_news",@"p_mine_test"];
    CGFloat BTN_W = SCREEN_WIDTH/titleArr.count;
    for (int i = 0; i < titleArr.count ; i ++) {
        // 按钮
        TABButton *btn = [[TABButton alloc]initWithFrame:CGRectMake(i * BTN_W, 0, BTN_W, 45) title:titleArr[i] image:imgArr[i]];
        __weak __typeof (self)weakSelf = self;
        [btn setBtnClick:^(NSString *title) {
            weakSelf.optionViewClick(title);
        }];
        [self addSubview:btn];
        
        // 分割线
        UILabel *lineLab = [UILabel new];
        lineLab.backgroundColor = SEPARATECOLOR;
        lineLab.frame = CGRectMake(BTN_W * i , 10, 1, self.frame.size.height - 20);
        [self addSubview:lineLab];
    }
}

@end
