//
//  MyOrderCell.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/4.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "MyOrderCell.h"
#import "OrderListModel.h"

@interface MyOrderCell ()
@property (nonatomic , strong)UILabel *submitTimeLab;
@property (nonatomic , strong)UILabel *orderNumLab;
@property (nonatomic , strong)UILabel *orderStatusLab;
@property (nonatomic , strong)UILabel *orderNameLab;
@property (nonatomic , strong)UILabel *moneyLab;
@property (nonatomic , strong)UILabel *discountMoneyLab;
@property (nonatomic , strong)UILabel *payMethodLab;
@property (nonatomic , strong)UILabel *cvNameLab;//
@property (nonatomic , strong)UILabel *setTopTimeLab;//

@end
@implementation MyOrderCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setupSubViews{
    
    for (UIView *subView in self.contentView.subviews) {
        [subView removeFromSuperview];
    }
    
    // 订单提交时间
    self.submitTimeLab = [UILabel new];
    [self.contentView addSubview:self.submitTimeLab];
    self.submitTimeLab.sd_layout
    .leftSpaceToView(self.contentView, 15)
    .topSpaceToView(self.contentView, 10)
    .autoHeightRatio(0);
    [self.submitTimeLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    self.submitTimeLab.font = SMALLERFONT;
    self.submitTimeLab.textColor = TEXTGRAYCOLOR;
    
    // 订单号
    self.orderNumLab = [UILabel new];
    [self.contentView addSubview:self.orderNumLab];
    self.orderNumLab.sd_layout
    .leftEqualToView(self.submitTimeLab)
    .topSpaceToView(self.submitTimeLab,5)
    .autoHeightRatio(0);
    self.orderNumLab.font = self.submitTimeLab.font;
    self.orderNumLab.textColor = self.submitTimeLab.textColor;
    [self.orderNumLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    
    // 订单状态
    self.orderStatusLab = [UILabel new];
    [self.contentView addSubview:self.orderStatusLab];
    self.orderStatusLab.sd_layout
    .rightSpaceToView(self.contentView, 10)
    .heightIs(25)
    .topSpaceToView(self.submitTimeLab, -15)
    .widthIs(55);
    self.orderStatusLab.font = DEFAULTFONT;
    self.orderStatusLab.textColor = UIColorFromHex(0x16A777);
    self.orderStatusLab.layer.borderColor = UIColorFromHex(0x16A777).CGColor;
    self.orderStatusLab.layer.borderWidth = 1;
    self.orderStatusLab.sd_cornerRadius = @(5);
    self.orderStatusLab.textAlignment = NSTextAlignmentCenter;
    
    UIView *separateLine = [UIView new];
    [self.contentView addSubview:separateLine];
    separateLine.sd_layout
    .leftEqualToView(self.orderNumLab)
    .topSpaceToView(self.orderNumLab, 10)
    .rightSpaceToView(self.contentView, 15)
    .heightIs(1);
    separateLine.backgroundColor = SEPARATECOLOR;
    
    self.orderNameLab = [UILabel new];
    [self.contentView addSubview:self.orderNameLab];
    self.orderNameLab.sd_layout
    .leftEqualToView(self.orderNumLab)
    .topSpaceToView(separateLine, 10)
    .autoHeightRatio(0);
    [self.orderNameLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    [self.orderNameLab setFont:[UIFont fontWithName:@"Helvetica-Bold" size:BIGGERFONTSIZE]];
    
    // 金额
    self.moneyLab = [UILabel new];
    [self.contentView addSubview:self.moneyLab];
    self.moneyLab.sd_layout
    .leftSpaceToView(self.orderNameLab, 5)
    .centerYEqualToView(self.orderNameLab)
    .heightRatioToView(self.orderNameLab, 1);
    [self.moneyLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    self.moneyLab.textColor = NAVBARCOLOR;
    self.moneyLab.font = self.orderNameLab.font;
    // 折扣
    self.discountMoneyLab = [UILabel new];
    [self.contentView addSubview:self.discountMoneyLab];
    self.discountMoneyLab.sd_layout
    .leftSpaceToView(self.moneyLab, 0)
    .centerYEqualToView(self.moneyLab)
    .heightRatioToView(self.moneyLab, 1);
    [self.discountMoneyLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    self.discountMoneyLab.textColor = self.moneyLab.textColor;
    self.discountMoneyLab.font = self.moneyLab.font;
    
    //支付方式
    self.payMethodLab = [UILabel new];
    [self.contentView addSubview:self.payMethodLab];
    self.payMethodLab.sd_layout
    .leftSpaceToView(self.discountMoneyLab, 0)
    .centerYEqualToView(self.discountMoneyLab)
    .heightRatioToView(self.discountMoneyLab, 1);
    self.payMethodLab.textColor = TEXTGRAYCOLOR;
    self.payMethodLab.font = DEFAULTFONT;
    [self.payMethodLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
    
    //置顶开始时间
    BOOL show = NO;
    if (_model.beginDate &&  _model.endDate){
        show = YES;
        self.setTopTimeLab = [UILabel new];
        [self.contentView addSubview:self.setTopTimeLab];
        self.setTopTimeLab.sd_layout
        .leftEqualToView(self.orderNameLab)
        .topSpaceToView(self.orderNameLab, 10)
        .autoHeightRatio(0);
        [self.setTopTimeLab setSingleLineAutoResizeWithMaxWidth:SCREEN_WIDTH];
        self.setTopTimeLab.font = DEFAULTFONT;
    }
    
    // 置顶简历名
    self.cvNameLab = [UILabel new];
    [self.contentView addSubview:self.cvNameLab];
    self.cvNameLab.sd_layout
    .leftEqualToView(self.orderNameLab)
    .topSpaceToView( show ? self.setTopTimeLab: self.orderNameLab, 10)
    .rightSpaceToView(self.contentView, 15)
    .autoHeightRatio(0);
    self.cvNameLab.textColor = TEXTGRAYCOLOR;
    self.cvNameLab.font = DEFAULTFONT;
    
    // 分割线
    UIView *separateView = [UIView new];
    [self.contentView addSubview:separateView];
    separateView.sd_layout
    .leftSpaceToView(self.contentView, 0)
    .rightSpaceToView(self.contentView, 0)
    .topSpaceToView(self.cvNameLab, 10)
    .heightIs(10);
    separateView.backgroundColor = SEPARATECOLOR;
    
    [self setupAutoHeightWithBottomView:separateView bottomMargin:0];
}

- (void)setModel:(OrderListModel *)model{
    _model = model;
    [self setupSubViews];
    [self setValue];
}

- (void)setValue{
    
    
    NSString *addDate = [CommonTools changeDateWithDateString:_model.addDate];// 订单提交时间

    self.submitTimeLab.text = [NSString stringWithFormat:@"订单提交时间:%@",addDate];
    self.orderNameLab.text = _model.cvOrderName;
    self.orderNumLab.text = [NSString stringWithFormat:@"订单号:%@",_model.payOrderNum];
    self.orderStatusLab.text = _model.cvTopStatus;
    self.moneyLab.text = [NSString stringWithFormat:@"%@元",_model.OrderMoney];
    if (_model.DiscountMoney != nil && _model.DiscountMoney.length) {
        self.discountMoneyLab.text = [NSString stringWithFormat:@"+%@元代金券",_model.DiscountMoney];
    }
    
    if (_model.DiscountMoney == nil || _model.DiscountMoney.length == 0) {
        self.payMethodLab.sd_layout
        .leftSpaceToView(self.moneyLab, 0)
        .centerYEqualToView(self.moneyLab)
        .heightRatioToView(self.moneyLab, 1);
    }
    
    if ([_model.payMethod isEqualToString:@"1"]) {
        self.payMethodLab.text = @"(微信付款)";
    }else if ([_model.payMethod isEqualToString:@"2"]){
        self.payMethodLab.text = @"(支付宝付款)";
    }
    
    // 置顶时间
    if (_model.beginDate &&  _model.endDate) {
        self.setTopTimeLab.text = [NSString stringWithFormat:@"置顶时间：%@至%@",[self changeBeginFormatWithDateString:_model.beginDate],[self changeBeginFormatWithDateString:_model.endDate]];
    }
    
    if (_model.beginDate == nil || _model.endDate == nil) {
        self.cvNameLab.sd_layout
        .topSpaceToView(self.orderNameLab, 10);
        self.setTopTimeLab.hidden = YES;
    }
    
    NSString *cvName = _model.CvName == nil ? @"(简历已删除)":_model.CvName;
    self.cvNameLab.text = [NSString stringWithFormat:@"简历：%@",cvName];
    
    [self.contentView updateLayout];
}

-(NSString *)changeFormatWithDateString:(NSString *)date{
    //2019-01-07T09:43:58.233+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}

-(NSString *)changeBeginFormatWithDateString:(NSString *)date{
    //2019-01-04T17:54:00+08:00
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'+'ss:ss"];
    NSDate *currentDate = [dateFormatter dateFromString:date];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateStr=[dateFormatter stringFromDate:currentDate];
    return dateStr;
}
@end
