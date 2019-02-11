//
//  ApplyCvListCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/11.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ApplyCvListCell.h"
#import "ApplyCvListModel.h"
#import "Common.h"
#import "OnlineLab.h"
#import "WKLabel.h"

@implementation ApplyCvListCell

- (void)setModel:(ApplyCvListModel *)model{
    _model = model;
    [self setupSubViews];
}
- (void)setupSubViews{
    
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    WKLabel *lbMatch = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 95, 0, 80, 40) content:@"" size:DEFAULTFONTSIZE color:nil];
    [lbMatch setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:lbMatch];
    
    NSMutableAttributedString *matchString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"匹配度%@%%", _model.cvMatch]];
    [matchString addAttribute:NSForegroundColorAttributeName value:GREENCOLOR range:NSMakeRange(3, matchString.length - 3)];
    [lbMatch setAttributedText:matchString];
    
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 0, VIEW_X(lbMatch) - 15, VIEW_H(lbMatch)) content:[NSString stringWithFormat:@"应聘职位：%@", _model.JobName] size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbJob];
    
    UIView *viewSeparateTop = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(lbJob), SCREEN_WIDTH, 1)];
    [viewSeparateTop setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparateTop];
    
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_X(lbJob), VIEW_BY(viewSeparateTop) + 10, 50, 50)];
    [imgPhoto setImage:[UIImage imageNamed:([_model.Gender boolValue] ? @"img_photowoman.png" : @"img_photoman.png")]];
    [imgPhoto setContentMode:UIViewContentModeScaleAspectFill];
    [imgPhoto.layer setMasksToBounds:YES];
    [imgPhoto.layer setCornerRadius:25];
    [self.contentView addSubview:imgPhoto];
    if ([_model.PaPhoto length] > 0) {
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:[Common getPaPhotoUrl:_model.PaPhoto paMainId:_model.paMainID]]];
    }
    
    WKLabel *lbName = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPhoto) + 15, VIEW_Y(imgPhoto), 500, 30) content:_model.paName size:BIGGERFONTSIZE color:nil];
    [self.contentView addSubview:lbName];
    
    float xForName = VIEW_BX(lbName);
    if ([_model.MobileVerifyDate length] > 0) {
        UIImageView *imgMobileCer = [[UIImageView alloc] initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 16, 16)];
        [imgMobileCer setImage:[UIImage imageNamed:@"cp_mobilecer.png"]];
        [imgMobileCer setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgMobileCer];
        xForName = VIEW_BX(imgMobileCer);
    }
    
    if ([_model.IsOnline boolValue]) {
        
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 30, 16)];
        [self.contentView addSubview:onlineLab];
        xForName = VIEW_BX(onlineLab);
        
        // “聊”图标
        //        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 16, 16)];
        //        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
        //        [imgOnline setContentMode:UIViewContentModeScaleAspectFit];
        //        [cell.contentView addSubview:imgOnline];
        //        xForName = VIEW_BX(imgOnline);
    }
    
    if ([_model.RemindDate length] > 0 && [_model.Reply isEqualToString:@"0"]) {
        NSTimeInterval interval = [[Common dateFromString:_model.RemindDate] timeIntervalSinceDate:[NSDate date]];
        float remindDay = (interval / (24 * 3600));
        UIImageView *imgRemind = [[UIImageView alloc] initWithFrame:CGRectMake(xForName + 5, VIEW_Y(lbName) + 7, 50, 16)];
        if (remindDay > 3) {
            [imgRemind setImage:[UIImage imageNamed:@"cp_jobreplyno.png"]];
        }
        else {
            [imgRemind setImage:[UIImage imageNamed:@"cp_jobreply.png"]];
        }
        [imgRemind setContentMode:UIViewContentModeScaleAspectFit];
        [self.contentView addSubview:imgRemind];
    }
    
    NSString *workYears = @"";
    if ([_model.RelatedWorkYears isEqualToString:@"0"]) {
        workYears = @"无";
    }
    else if ([_model.RelatedWorkYears isEqualToString:@"11"]) {
        workYears = @"10年以上";
    }
    else if ([_model.RelatedWorkYears length] > 0) {
        workYears = [NSString stringWithFormat:@"%@年", _model.RelatedWorkYears];
    }
    WKLabel *lbInfo = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbName), VIEW_BY(lbName), 500, 25) content:[NSString stringWithFormat:@"%@ | %@岁 | %@ | %@工作经验 | %@", ([_model.Gender boolValue] ? @"女" : @"男"), _model.Age, _model.DegreeName, workYears, _model.LivePlaceName] size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbInfo];
    
    UIView *viewSeparateBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgPhoto) + 10, SCREEN_WIDTH, 1)];
    [viewSeparateBottom setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparateBottom];
    
    UIButton *btnReply = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, VIEW_BY(viewSeparateBottom) + 7, 75, 26)];
    [btnReply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnReply setBackgroundColor:[UIColor clearColor]];
    [btnReply.titleLabel setFont:DEFAULTFONT];
    [self.contentView addSubview:btnReply];
    
    if ([_model.Reply isEqualToString:@"0"]) {
//        [btnReply setTag:indexPath.section];
        [btnReply setTitle:@"答复" forState:UIControlStateNormal];
        [btnReply setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnReply setBackgroundColor:GREENCOLOR];
        [btnReply.layer setCornerRadius:5];
        [btnReply addTarget:self action:@selector(replyClick) forControlEvents:UIControlEventTouchUpInside];
    }
    else if ([_model.Reply isEqualToString:@"1"]) {
        [btnReply setTitle:@"符合要求" forState:UIControlStateNormal];
    }
    else if ([_model.Reply isEqualToString:@"5"]) {
        [btnReply setTitle:@"储备(自动)" forState:UIControlStateNormal];
    }
    else { // 2
        [btnReply setTitle:@"储备" forState:UIControlStateNormal];
    }
    
    UIButton *btnOnline = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_X(btnReply) - 95, VIEW_Y(btnReply), 85, VIEW_H(btnReply))];
//    [btnOnline setTag:indexPath.section];
    [btnOnline setTitle:@"跟TA聊聊" forState:UIControlStateNormal];
    [btnOnline setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btnOnline setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btnOnline.titleLabel setFont:DEFAULTFONT];
    [btnOnline addTarget:self action:@selector(chatClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:btnOnline];
    
    WKLabel *lbLoginDate = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_Y(btnReply), 500, VIEW_H(btnOnline)) content:[NSString stringWithFormat:@"应聘时间：%@", [Common stringFromDateString:_model.AddDate formatType:@"yyyy-MM-dd"]] size:DEFAULTFONTSIZE color:nil];
    [self.contentView addSubview:lbLoginDate];
    
    [self setupAutoHeightWithBottomView:lbLoginDate bottomMargin:5];
}
#pragma mark - 答复
- (void)replyClick{
    self.replyBlock(_model);
}

#pragma mark - 跟ta聊聊
- (void)chatClick{
    self.chatBlock(_model);
}
@end
