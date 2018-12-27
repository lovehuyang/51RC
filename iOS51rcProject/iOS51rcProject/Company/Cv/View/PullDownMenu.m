//
//  PullDownMenu.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/13.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "PullDownMenu.h"
#import "MenuButton.h"
#import "Common.h"

@interface PullDownMenu()
@property (nonatomic , strong) UILabel *replyRateLab;
@property (nonatomic , strong) UITableView *tableView;
@property (nonatomic , strong) MenuButton *menuBtn;

@end

@implementation PullDownMenu

- (instancetype)initWithFrame:(CGRect)frame controller:(UIViewController *)controller Title:(NSArray *)titleArr replyRate:(NSString *)replyRate{
    if (self = [super initWithFrame:frame]) {
        [self setupSubViewsController:controller Title:titleArr replyRate:replyRate];
        self.backgroundColor = SEPARATECOLOR;
    }
    return self;
}

- (void)setupSubViewsController:(UIViewController *)controller Title:(NSArray *)titleArr replyRate:(NSString *)replyRate{
    UIView *titleView = [UIView new];
    [self addSubview:titleView];
    titleView.sd_layout
    .leftEqualToView(self)
    .topEqualToView(self)
    .rightEqualToView(self)
    .heightIs(35);
    
    // 答复率
    UILabel *replyRateLab = [UILabel new];
    [titleView addSubview:replyRateLab];
    replyRateLab.sd_layout
    .rightSpaceToView(titleView, 15)
    .widthIs(100)
    .topEqualToView(titleView)
    .heightRatioToView(titleView, 1);
    replyRateLab.textAlignment = NSTextAlignmentRight;
    replyRateLab.font = DEFAULTFONT;
    self.replyRateLab = replyRateLab;

    //
    MenuButton *button = [[MenuButton alloc]initWithFrame:CGRectMake(15, 0, self.frame.size.width, VIEW_H(titleView))];
    [button setTitle:@"全部职位" forState:UIControlStateNormal];
    CGSize btnSize = [Common sizeWithText:button.titleLabel.text font:DEFAULTFONT maxSize:CGSizeMake(SCREEN_WIDTH, button.frame.size.height)];
    button.frame = CGRectMake(20, 0, btnSize.width + 20, button.frame.size.height);
    [button addTarget:self action:@selector(menuBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:button];
    self.menuBtn = button;
}

- (void)setTitleArr:(NSArray *)titleArr{
    _titleArr = titleArr;
    [self.menuBtn setTitle:[_titleArr firstObject] forState:UIControlStateNormal];
}
- (void)setTitleStr:(NSString *)titleStr{
    [self.menuBtn setTitle:titleStr forState:UIControlStateNormal];
    [self updateMenuBtnStatus:self.menuBtn];
}

- (void)setReplyRate:(NSString *)replyRate{
    _replyRate = replyRate;
    CGFloat rate =  [replyRate floatValue] * 100;
    self.replyRateLab.text = [NSString stringWithFormat:@"答复率:%.1f%@",rate,@"%"];
}

- (void)menuBtnClick{
    self.menuClick(self.menuBtn.titleLabel.text);
}

#pragma mark - 更新菜单栏按钮显示
- (void)updateMenuBtnStatus:(MenuButton *)menuBtn{

    CGSize btnSize = [Common sizeWithText:menuBtn.titleLabel.text font:DEFAULTFONT maxSize:CGSizeMake(SCREEN_WIDTH, menuBtn.frame.size.height)];
    menuBtn.frame = CGRectMake(VIEW_X(self.menuBtn), VIEW_Y(self.menuBtn), btnSize.width + 20, menuBtn.frame.size.height);

}
@end
