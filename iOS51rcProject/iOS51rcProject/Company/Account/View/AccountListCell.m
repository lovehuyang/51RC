//
//  AccountListCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AccountListCell.h"
#import "AccountListModel.h"
#import "WKLabel.h"

@implementation AccountListCell

- (void)setIndexPath:(NSIndexPath *)indexPath{
    _indexPath = indexPath;
}

- (void)setModel:(AccountListModel *)model{
    _model = model;
    [self setupSubViews];
}

- (void)setupSubViews{
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 15, SCREEN_WIDTH - 80, 10) content:[NSString stringWithFormat:@"\u3000用户名：%@ [%@]\n\u3000\u3000姓名：%@\n电子邮箱：%@\n\u3000手机号：%@", _model.UserName, ([_model.AccountType isEqualToString:@"1"] ? @"管理员" : @"普通用户"), _model.Name, _model.EMail, _model.Mobile] size:DEFAULTFONTSIZE color:nil spacing:10];
    NSMutableAttributedString *detailString = [[NSMutableAttributedString alloc] initWithString:lbDetail.text];
    [detailString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange([lbDetail.text rangeOfString:@"["].location, ([_model.AccountType isEqualToString:@"1"] ? 3 : 4) + 2)];
    [detailString addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, detailString.length)];
    [lbDetail setAttributedText:detailString];
    [self.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparate];
    
    float widthForButton = SCREEN_WIDTH / 2;
    bool canOperate = NO;
    if ([_model.AccountType isEqualToString:@"2"] && [[USER_DEFAULT objectForKey:@"AccountType"] isEqualToString:@"1"]) {
        canOperate = YES;
    }
    if (canOperate) {
        widthForButton = SCREEN_WIDTH / 3;
        WKButton *btnStart;
        if ([_model.IsPause boolValue]) {
            btnStart = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountstart.png" title:@"启用" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
            [btnStart setTag:_indexPath.section];
            [btnStart addTarget:self action:@selector(startClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        else {
            btnStart = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(0, VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountpause.png" title:@"暂停" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
            [btnStart setTag:_indexPath.section];
            [btnStart addTarget:self action:@selector(pauseClick:) forControlEvents:UIControlEventTouchUpInside];
        }
        [self.contentView addSubview:btnStart];
        UIView *viewSeparateLeft = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnStart), VIEW_Y(btnStart), 1, VIEW_H(btnStart))];
        [viewSeparateLeft setBackgroundColor:SEPARATECOLOR];
        [self.contentView addSubview:viewSeparateLeft];
    }
    if ([_model.IsPause boolValue]) {
        WKLabel *lbStatus = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbDetail), 50, 20) content:@"已暂停" size:DEFAULTFONTSIZE color:[UIColor whiteColor]];
        [lbStatus setBackgroundColor:[UIColor grayColor]];
        [lbStatus setTextAlignment:NSTextAlignmentCenter];
        [self.contentView addSubview:lbStatus];
    }
    WKButton *btnUserSafe = [[WKButton alloc] initImageButtonWithFrame:CGRectMake((canOperate ? widthForButton : 0), VIEW_BY(viewSeparate), widthForButton, 40) image:@"cp_accountsafe.png" title:@"修改用户名密码" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
    [btnUserSafe setTag:_indexPath.section];
    [btnUserSafe addTarget:self action:@selector(safeClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnUserSafe];
    
    WKButton *btnUserInfo = [[WKButton alloc] initImageButtonWithFrame:CGRectMake(VIEW_BX(btnUserSafe), VIEW_Y(btnUserSafe), VIEW_W(btnUserSafe), VIEW_H(btnUserSafe)) image:@"cp_accountmodify.png" title:@"修改用户信息" fontSize:DEFAULTFONTSIZE color:nil bgColor:nil];
//    [btnUserInfo setTag:indexPath.section];
    [btnUserInfo addTarget:self action:@selector(userClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnUserInfo];
    
    UIView *viewSeparateMiddle = [[UIView alloc] initWithFrame:CGRectMake(VIEW_BX(btnUserSafe), VIEW_Y(btnUserSafe), 1, VIEW_H(btnUserSafe))];
    [viewSeparateMiddle setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparateMiddle];
    
    [self setupAutoHeightWithBottomView:viewSeparateMiddle bottomMargin:0];
}

- (void)startClick:(WKButton *)button{
    self.cellBlock(button, @"startClick");
}

- (void)pauseClick:(WKButton *)button{
    self.cellBlock(button, @"pauseClick");

}

- (void)safeClick:(WKButton *)button{
    self.cellBlock(button, @"safeClick");

}

- (void)userClick:(WKButton *)button{
    self.cellBlock(button, @"userClick");

}
@end
