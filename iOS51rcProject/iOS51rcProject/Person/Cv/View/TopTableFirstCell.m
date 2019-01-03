//
//  TopTableFirstCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "TopTableFirstCell.h"

@interface TopTableFirstCell()
@property (nonatomic , strong) UILabel *titleLab;
@end;

@implementation TopTableFirstCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    UIView *seperateView = [UIView new];
    [self.contentView addSubview:seperateView];
    seperateView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(self.contentView, 0)
    .heightIs(10);
    seperateView.backgroundColor = SEPARATECOLOR;
    
    UILabel *titleLab = [UILabel new];
    self.titleLab = titleLab;
    [self.contentView addSubview:titleLab];
    
    titleLab.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(seperateView, 0)
    .heightIs(30);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = NAVBARCOLOR;
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    
    UIImageView *imgView = [UIImageView new];
    [self.contentView addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .topSpaceToView(titleLab, 5)
    .rightSpaceToView(self.contentView, 10)
    .autoHeightRatio(0.417);
    imgView.image = [UIImage imageNamed:@"icon_resume_top2"];
    [self setupAutoHeightWithBottomView:imgView bottomMargin:0];
}

- (void)setTitleStr:(NSString *)titleStr{
    self.titleLab.text = titleStr;
}
@end
