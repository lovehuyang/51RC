//
//  WKTableView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKTableView.h"
#import "CommonMacro.h"
#import "WKLabel.h"

@implementation WKTableView

- (instancetype)initWithFrame:(CGRect)frame style:(UITableViewStyle)style noDataMsg:(NSString *)noDataMsg {
    if (self = [super initWithFrame:frame style:style]) {
        [self setBackgroundColor:SEPARATECOLOR];
        UIView *viewNoData = [[UIView alloc] initWithFrame:frame];
        [viewNoData setBackgroundColor:[UIColor whiteColor]];
        [viewNoData setTag:NODATAVIEWTAG];
        [viewNoData setHidden:YES];
        [self addSubview:viewNoData];
        
        UIImageView *imgNoData = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 150) / 2, 60, 150, 150 * 0.86)];
        [imgNoData setImage:[UIImage imageNamed:@"img_nodata.png"]];
        [imgNoData setContentMode:UIViewContentModeScaleAspectFit];
        [viewNoData addSubview:imgNoData];
        
        WKLabel *lbNoData = [[WKLabel alloc] initWithFixedSpacing:CGRectMake((SCREEN_WIDTH - 200) / 2, VIEW_BY(imgNoData) + 20, SCREEN_WIDTH * 0.6, 20) content:noDataMsg size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:7];
        [lbNoData setTextAlignment:NSTextAlignmentCenter];
        [lbNoData setCenter:CGPointMake(SCREEN_WIDTH / 2, lbNoData.center.y)];
        [viewNoData addSubview:lbNoData];
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
