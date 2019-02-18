//
//  ChatListCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/15.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ChatListCell.h"
#import "ChatListModel.h"
#import "WKLabel.h"
#import "Common.h"

@implementation ChatListCell

- (void)setModel:(ChatListModel *)model{
    for (UIView *view in self.contentView.subviews) {
        [view removeFromSuperview];
    }
    
    _model = model;
    [self setupSubViews];
}

- (void)setupSubViews{
    UIImageView *imgPhoto = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    if (_model.PhotoUrl != nil) {
        NSString *path = [NSString stringWithFormat:@"%d",([_model.paMainId intValue] / 100000 + 1) * 100000];
        NSInteger lastLength = 9 - path.length;
        for (int i = 0; i < lastLength; i++) {
            path = [NSString stringWithFormat:@"0%@",path];
        }
        path = [NSString stringWithFormat:@"L%@",path];
        path = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/Photo/%@/Processed/%@", path, _model.PhotoUrl];
        [imgPhoto sd_setImageWithURL:[NSURL URLWithString:path]];
    }
    else {
        [imgPhoto setImage:[UIImage imageNamed:([_model.Gender boolValue] ? @"img_photowoman.png" : @"img_photoman.png")]];
    }
    [imgPhoto.layer setMasksToBounds:YES];
    [imgPhoto.layer setCornerRadius:(VIEW_W(imgPhoto) / 2)];
    [self.contentView addSubview:imgPhoto];
    
    if ([_model.OnlineStatus isEqualToString:@"0"]) {
        UIView *viewMask = [[UIView alloc] initWithFrame:imgPhoto.frame];
        [viewMask setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
        [self.contentView addSubview:viewMask];
    }
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgPhoto) - 30;
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgPhoto) + 15, VIEW_Y(imgPhoto), maxWidth - 100, 25) content:_model.Name size:BIGGERFONTSIZE color:nil];
    [self.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 100, VIEW_Y(lbCompany), 85, VIEW_H(lbCompany)) content:[Common stringFromDateString:_model.LastSendDate formatType:@"MM-dd HH:mm"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [self.contentView addSubview:lbDate];
    
    WKLabel *lbMessage = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth - ([_model.NoViewedNum integerValue] > 0 ? 35 : 0), 25) content:_model.Message size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbMessage setTextAlignment:NSTextAlignmentCenter];
    [self.contentView addSubview:lbMessage];
    
    if ([_model.NoViewedNum integerValue] > 0) {
        WKLabel *lbCount = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 35, VIEW_Y(lbMessage) + 5, 15, 15) content:_model.NoViewedNum size:10 color:[UIColor whiteColor]];
        [lbCount setBackgroundColor:NAVBARCOLOR];
        [lbCount setTextAlignment:NSTextAlignmentCenter];
        [lbCount.layer setMasksToBounds:YES];
        [lbCount.layer setCornerRadius:VIEW_H(lbCount) / 2];
        [self.contentView addSubview:lbCount];
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbMessage) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [self.contentView addSubview:viewSeparate];
    [self setupAutoHeightWithBottomView:viewSeparate bottomMargin:0];
}
@end
