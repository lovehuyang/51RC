//
//  ExpiredJobListCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ExpiredJobListCell.h"
#import "CpJobListModel.h"
#import "WKLabel.h"
#import "WKButton.h"
#import "Common.h"

@implementation ExpiredJobListCell

- (void)setModel:(CpJobListModel *)model{
    _model = model;
    [self setupSubViews];
}

- (void)setupSubViews{

    float widthForLable = SCREEN_WIDTH - 80;
    WKLabel *lbName = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 10, widthForLable, 20) content:_model.Name size:BIGGERFONTSIZE color:nil spacing:10];
    [self.contentView addSubview:lbName];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbName) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"截止时间：%@", [Common stringFromDateString:_model.IssueEnd formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:10];
    [self.contentView addSubview:lbDate];
    
    WKLabel *lbRefresh = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbName), VIEW_BY(lbDate) + 10, widthForLable, 20) content:[NSString stringWithFormat:@"累计应聘数：%@", _model.ApplyNumber] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:10];
    [self.contentView addSubview:lbRefresh];
    
    UIButton *btnApply = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, 0, 90, VIEW_BY(lbRefresh))];
    [btnApply setTag:100];
    [btnApply addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnApply];
    
    UIView *viewMiddle = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_Y(lbName), 1, VIEW_BY(lbRefresh) - VIEW_Y(lbName))];
    [viewMiddle setBackgroundColor:SEPARATECOLOR];
    [btnApply addSubview:viewMiddle];
    
    // 应聘简历的数量
    NSString *applyCountStr = _model.ApplyCount;
    WKLabel *lbApplyCount = [[WKLabel alloc] initWithFrame:CGRectMake(15, VIEW_Y(viewMiddle) + 15, 60, 20) content:_model.ApplyCount size:BIGGESTFONTSIZE color:[applyCountStr integerValue] == 0 ?TEXTGRAYCOLOR: GREENCOLOR];
    [lbApplyCount setTextAlignment:NSTextAlignmentCenter];
    [btnApply addSubview:lbApplyCount];
    
    WKLabel *lbApply = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_X(lbApplyCount), VIEW_BY(lbApplyCount), VIEW_W(lbApplyCount), 20) content:@"应聘简历" size:DEFAULTFONTSIZE color:nil];
    [lbApply setTextAlignment:NSTextAlignmentCenter];
    [btnApply addSubview:lbApply];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbRefresh) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparate];
    
    WKButton *btnRefresh = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), SCREEN_WIDTH / 3, 30) image:@"cp_jobdelete.png" title:@"删除" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnRefresh addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnRefresh setTag:101];
    [self.contentView addSubview:btnRefresh];
    
    WKButton *btnIssue = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnRefresh), VIEW_Y(btnRefresh), VIEW_W(btnRefresh), VIEW_H(btnRefresh)) image:@"cp_jobissue.png" title:@"重新发布" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnIssue addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnIssue setTag:102];
    [self.contentView addSubview:btnIssue];
    
    WKButton *btnModify = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnIssue), VIEW_Y(btnRefresh), VIEW_W(btnRefresh), VIEW_H(btnRefresh)) image:@"cp_jobmodify.png" title:@"编辑职位" fontSize:SMALLERFONTSIZE color:nil bgColor:nil];
    [btnModify addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [btnModify setTag:103];
    [self.contentView addSubview:btnModify];
    
    [self setupAutoHeightWithBottomView:btnModify bottomMargin:5];
}

- (void)btnClick:(UIButton *)btn{
    self.expiredCellBlock(btn, _model);
}

@end
