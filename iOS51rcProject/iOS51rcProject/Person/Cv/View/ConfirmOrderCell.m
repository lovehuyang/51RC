//
//  ConfirmOrderCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/3.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "ConfirmOrderCell.h"
#import "CVListModel.h"
@interface ConfirmOrderCell()

@property (nonatomic , strong)UILabel *cvTitleLab;
@property (nonatomic , strong)UIButton *selectBtn;

@end

@implementation ConfirmOrderCell

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
        titleLab.text = @"置顶的简历";
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

- (void)setCvModel:(CVListModel *)cvModel{
    
    _cvModel = cvModel;
    if([_cvModel.Valid isEqualToString:@"0"]){
        self.selectBtn.hidden = YES;
        self.cvTitleLab.text = [NSString stringWithFormat:@"%@(不完整)",_cvModel.Name];
    }else{
         self.cvTitleLab.text = _cvModel.Name;
    }
    
    self.selectBtn.selected = _cvModel.isSlected;
}

- (void)selectClick{
    if ([self.cvModel.Valid isEqualToString:@"0"]) {
        [RCToast showMessage:@"不完整简历不可置顶"];
    }
    else{
        self.selectCvBlock(self.cvModel);
    }
}
@end
