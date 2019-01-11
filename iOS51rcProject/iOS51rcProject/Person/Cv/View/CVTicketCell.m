//
//  CVTicketCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "CVTicketCell.h"
#import "CVTicketModel.h"
#import "NSString+RCString.h"

@interface CVTicketCell()
@property (nonatomic , strong)UIImageView *imgView;
@property (nonatomic , strong)UILabel *tipLab;
@property (nonatomic , strong)UILabel *subTipLab;
@property (nonatomic , strong)UILabel *statusLab;
@property (nonatomic , strong)UILabel *validDateLab;

@end

@implementation CVTicketCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupSubviewsWithCellType:(NSString *)ticketType{

    UIImageView *imgView = [UIImageView new];
    [self.contentView addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self.contentView, 10)
    .rightSpaceToView(self.contentView, 10)
    .topSpaceToView(self.contentView, 0)
    .bottomSpaceToView(self.contentView, 5);
    imgView.userInteractionEnabled = YES;
    self.imgView = imgView;
    
    UILabel *tipLab = [UILabel new];
    [imgView addSubview:tipLab];
    tipLab.textColor = [UIColor whiteColor];
    tipLab.font = BIGGERFONT;
    
    //1拼手气代金券
    if ([ticketType isEqualToString:@"1"]) {
        tipLab.sd_layout
        .autoHeightRatio(0)
        .centerYEqualToView(imgView)
        .leftSpaceToView(imgView, 10);
        [tipLab setSingleLineAutoResizeWithMaxWidth:200];
         self.tipLab = tipLab;
        
    }else if ([ticketType isEqualToString:@"2"]) {// 固定额度的代金券
        if(_model.disStartDate && _model.disEndDate && _model.disStartDate.length && _model.disEndDate.length){
            tipLab.sd_layout
            .topSpaceToView(imgView, 5)
            .autoHeightRatio(0)
            .leftSpaceToView(imgView, 10);
            [tipLab setSingleLineAutoResizeWithMaxWidth:200];
            self.tipLab = tipLab;
            
            // 有效期
            UILabel *validDateLab = [UILabel new];
            [imgView addSubview:validDateLab];
            validDateLab.sd_layout
            .leftEqualToView(tipLab)
            .topSpaceToView(tipLab, 0)
            .bottomSpaceToView(imgView, 0);
            validDateLab.textColor = [UIColor whiteColor];
            validDateLab.font = SMALLERFONT;
            [validDateLab setSingleLineAutoResizeWithMaxWidth:300];
            self.validDateLab = validDateLab;
        
        }else{
            tipLab.sd_layout
            .autoHeightRatio(0)
            .centerYEqualToView(imgView)
            .leftSpaceToView(imgView, 10);
            [tipLab setSingleLineAutoResizeWithMaxWidth:200];
            self.tipLab = tipLab;
        }
    }
    
    UILabel *subTipLab = [UILabel new];
    [imgView addSubview:subTipLab];
    subTipLab.sd_layout
    .leftSpaceToView(tipLab, 5)
    .bottomEqualToView(tipLab)
    .autoHeightRatio(0);
    subTipLab.textColor = [UIColor whiteColor];
    subTipLab.font = DEFAULTFONT;
    [subTipLab setSingleLineAutoResizeWithMaxWidth:200];
    self.subTipLab = subTipLab;

    // 代金券的领取状态
    UILabel *statusLab = [UILabel new];
    [imgView addSubview:statusLab];
    statusLab.sd_layout
    .rightSpaceToView(imgView, 0)
    .widthRatioToView(imgView, 0.3)
    .topSpaceToView(imgView, 0)
    .bottomSpaceToView(imgView, 0);
    statusLab.textColor = [UIColor whiteColor];
    statusLab.font = DEFAULTFONT;
    statusLab.textAlignment = NSTextAlignmentCenter;
    statusLab.numberOfLines = 0;
    self.statusLab = statusLab;
    statusLab.userInteractionEnabled = YES;
    
    UIButton *getBtn = [UIButton new];
    [statusLab addSubview:getBtn];
    getBtn.sd_layout
    .leftSpaceToView(statusLab, 0)
    .rightSpaceToView(statusLab, 0)
    .topSpaceToView(statusLab, 0)
    .bottomSpaceToView(statusLab, 0);
    if (![self.model.disType boolValue]) {
        // 未领取
        getBtn.enabled = YES;
    }else{
        getBtn.enabled = NO;
    }
    [getBtn addTarget:self action:@selector(btnClick) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setModel:(CVTicketModel *)model{
    _model = model;

    // discountType：1拼手气代金券   2固定额度代金券
    [self setupSubviewsWithCellType:model.discountType];
    
    // disType标识是否领取：0未领取  1已领取
    if ([model.disType boolValue]) {
        self.imgView.image = [UIImage imageNamed:@"ticket_bgImg"];
        self.statusLab.text = @"已领取";
    }else{
        self.imgView.image = [UIImage imageNamed:@"ticket_bgImg2"];
        self.statusLab.text = @"分享即可\n领取";
    }
    
    if ([_model.discountType isEqualToString:@"1"]) {
        self.subTipLab.text = @"拼手气领取代金券";
        self.tipLab.text = [NSString stringWithFormat:@"%@元",model.discountMoney];
    }else{
        self.tipLab.text = [NSString stringWithFormat:@"￥%@元",model.discountMoney];
        self.subTipLab.text = [NSString juedeString:_model.disRule];
        self.validDateLab.text = [NSString stringWithFormat:@"有效期:%@至%@",_model.disStartDate,_model.disEndDate];
    }
}

- (void)btnClick{
    
    self.getTicketBlock(_model);
    
}
@end
