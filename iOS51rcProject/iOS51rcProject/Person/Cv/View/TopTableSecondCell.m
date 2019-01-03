//
//  TopTableSecondCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "TopTableSecondCell.h"
#import "CVTopPackageModel.h"
#import "CVPackageView.h"

@implementation TopTableSecondCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
    }
    return self;
}
- (void)setupSubViews{
    UILabel *titleLab = [UILabel new];
    [self.contentView addSubview:titleLab];
    
    titleLab.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(self.contentView, 0)
    .heightIs(30);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.textColor = NAVBARCOLOR;
    titleLab.font = [UIFont boldSystemFontOfSize:BIGGERFONTSIZE];
    titleLab.text = @"/置顶套餐/";
    
    UIScrollView *scrollView = [UIScrollView new];
    [self.contentView addSubview:scrollView];
    scrollView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .topSpaceToView(titleLab, 0)
    .rightSpaceToView(self.contentView, 0)
    .autoHeightRatio(0.5);
    
    CGFloat Package_W = SCREEN_WIDTH/3;
    for (int i = 0; i < self.dataArr.count; i ++) {
        CVTopPackageModel *model = [self.dataArr objectAtIndex:i];
        CVPackageView *packageView = [CVPackageView new];
        [scrollView addSubview:packageView];
        packageView.sd_layout
        .leftSpaceToView(scrollView, Package_W *i)
        .topSpaceToView(scrollView, 10)
        .bottomSpaceToView(scrollView, 0)
        .widthIs(Package_W);
        packageView.model = model;
        packageView.buyBtnClickBlock = ^(CVTopPackageModel *model) {
            self.buyPackageBlock(model);
        };
    }
    
    scrollView.contentSize = CGSizeMake(Package_W *self.dataArr.count, 0);
    scrollView.showsHorizontalScrollIndicator = NO;
    
    
    [self setupAutoHeightWithBottomView:scrollView bottomMargin:0];
}

- (void)setDataArr:(NSArray *)dataArr{
    _dataArr = dataArr;
    [self setupSubViews];
}

@end
