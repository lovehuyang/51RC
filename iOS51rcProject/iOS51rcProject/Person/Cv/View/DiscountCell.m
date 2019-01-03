//
//  DiscountCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "DiscountCell.h"
#import "DiscountInfoModle.h"
@interface DiscountCell()

@property (nonatomic , strong)UILabel *cvTitleLab;
@property (nonatomic , strong)UIButton *selectBtn;

@end

@implementation DiscountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier indexPath:(NSIndexPath *)indexPath{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews:indexPath];
    }
    return self;
}
- (void)setupSubViews:(NSIndexPath *)indexPath{
   
    if (indexPath.row == 0) {
        UILabel *titleLab = [UILabel new];
        [self.contentView addSubview:titleLab];
        titleLab.sd_layout
        .leftSpaceToView(self.contentView, 15)
        .rightSpaceToView(self.contentView, 15)
        .topSpaceToView(self.contentView, 0)
        .bottomSpaceToView(self.contentView, 0);
        titleLab.text = @"代金券";
        [titleLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:DEFAULTFONTSIZE]];
    }else{
       
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectClick)];
        [self.contentView addGestureRecognizer:tap];
        self.contentView.userInteractionEnabled = YES;
        UILabel *cvTitleLab = [UILabel new];
        [self.contentView addSubview:cvTitleLab];
        cvTitleLab.sd_layout
        .leftSpaceToView(self.contentView, 15)
        .topSpaceToView(self.contentView, 0)
        .bottomSpaceToView(self.contentView, 0);
        [cvTitleLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH - 15 - 15 - 25];
        cvTitleLab.font = DEFAULTFONT;
        self.cvTitleLab = cvTitleLab;
        
        self.selectBtn = [UIButton new];
        [self.contentView addSubview:self.selectBtn];
        self.selectBtn.sd_layout
        .rightSpaceToView(self.contentView, 15)
        .centerYEqualToView(self.contentView)
        .widthIs(20)
        .heightEqualToWidth();
        [self.selectBtn setImage:[UIImage imageNamed:@"img_checksmall2"] forState:UIControlStateNormal];
        [self.selectBtn setImage:[UIImage imageNamed:@"img_checksmall1"] forState:UIControlStateSelected];
        [self.selectBtn addTarget:self action:@selector(selectClick) forControlEvents:UIControlEventTouchUpInside];
    }
}

- (void)setDiscountModel:(DiscountInfoModle *)discountModel{
    _discountModel = discountModel;
    
    self.cvTitleLab.text = [NSString stringWithFormat:@"%@元代金券",_discountModel.Money];
    
    self.selectBtn.selected = _discountModel.isSelceted;
}

- (void)selectClick{
    self.selectDiscountBlock(self.discountModel);
}

@end
