//
//  RecommendJobView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/12.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "RecommendJobView.h"
#import "RecommendJobCell.h"
#import "InsertJobApplyModel.h"

@interface RecommendJobView()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic , strong) UIView *bgView;// 全局背景
@property (nonatomic , strong) UIView *alertView;// alerview
@property (nonatomic , strong) NSArray *dataArr;// 数据源
@end

@implementation RecommendJobView

- (instancetype)initWithData:(NSArray *)dataArr{
    if (self = [super init]) {
    
        self.dataArr = [NSArray arrayWithArray:dataArr];
        self.bgView = [UIView new];
        [self addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .rightSpaceToView(self, 0)
        .bottomSpaceToView(self, 0);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.5;
        
        //创建alertView
        self.alertView = [[UIView alloc]init];
        self.alertView.center = CGPointMake(self.center.x, self.center.y);
        self.alertView.layer.masksToBounds = YES;
        self.alertView.layer.cornerRadius = 5;
        self.alertView.clipsToBounds = YES;
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.alertView];
        self.alertView.sd_layout
        .leftSpaceToView(self, 30)
        .rightSpaceToView(self, 30)
        .heightIs(420)
        .centerYEqualToView(self);
        self.alertView.backgroundColor = [UIColor whiteColor];
        self.alertView.sd_cornerRadius = @(5);
        
        [self setupAllsubviews];
    }
    return self;
}

#pragma mark - 初始化子控件
- (void)setupAllsubviews{
    UIImageView *logoImgView = [UIImageView new];
    [self.alertView addSubview:logoImgView];
    logoImgView.sd_layout
    .topSpaceToView(self.alertView, 10)
    .widthIs(65)
    .heightEqualToWidth()
    .rightSpaceToView(self.alertView, (SCREEN_WIDTH - 60)/2);
    logoImgView.image = [UIImage imageNamed:@"job_kissicon"];
    
    UILabel *tipLab = [UILabel new];
    [self.alertView addSubview:tipLab];
    tipLab.sd_layout
    .leftSpaceToView(logoImgView, 5)
    .topEqualToView(logoImgView)
    .bottomEqualToView(logoImgView)
    .rightSpaceToView(self.alertView, 10);
    tipLab.numberOfLines = 0;
    tipLab.text = @"这些职位和你很配\n拿走吧，呱呱~~";
    tipLab.textColor = TEXTGRAYCOLOR;
    tipLab.font = DEFAULTFONT;
    
    
    UITableView *tableView = [UITableView new];
    [self.alertView addSubview:tableView];
    tableView.sd_layout
    .leftSpaceToView(self.alertView, 10)
    .rightSpaceToView(self.alertView, 10)
    .topSpaceToView(tipLab, 10)
    .bottomSpaceToView(self.alertView, 60);
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.scrollEnabled = NO;
    
    
    UIButton *acceptBtn = [UIButton new];
    [self.alertView addSubview:acceptBtn];
    acceptBtn.sd_layout
    .leftSpaceToView(self.alertView, 20)
    .heightIs(30)
    .widthRatioToView(self.alertView, 0.5)
    .bottomSpaceToView(self.alertView, 20);
    acceptBtn.backgroundColor = NAVBARCOLOR;
    acceptBtn.sd_cornerRadius = @(5);
    [acceptBtn setTitle:@"立即申请" forState:UIControlStateNormal];
    acceptBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    acceptBtn.tag = 100;
    [acceptBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *rejectBtn = [UIButton new];
    [self.alertView addSubview:rejectBtn];
    rejectBtn.sd_layout
    .leftSpaceToView(acceptBtn, 10)
    .heightRatioToView(acceptBtn, 1)
    .rightSpaceToView(self.alertView, 20)
    .bottomEqualToView(acceptBtn);
    rejectBtn.sd_cornerRadius = @(5);
    [rejectBtn setTitle:@"残忍拒绝" forState:UIControlStateNormal];
    rejectBtn.layer.borderWidth = 1;
    rejectBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    [rejectBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    rejectBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DEFAULTFONTSIZE];
    [rejectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    InsertJobApplyModel *model = self.dataArr[indexPath.row];
    RecommendJobCell *cell = [[RecommendJobCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil data:model];
    cell.selectedPositon = ^(InsertJobApplyModel *model) {
        DLog(@"哈哈");
    };
    
    return cell;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 69;
}

- (void)btnClick:(UIButton *)btn{
    if (btn.tag == 100) {// 申请
        self.applyFor();
    }else{// 拒绝
        [self dissmiss];
    }
}
 
- (void)show{
    
    UIView *view = [[UIApplication sharedApplication] keyWindow];
    [view addSubview:self];
    self.sd_layout
    .leftSpaceToView(view, 0)
    .rightSpaceToView(view, 0)
    .topSpaceToView(view, 0)
    .bottomSpaceToView(view, 0);
    
     self.alertView.transform = CGAffineTransformMakeScale(1.21f, 1.21f);
 
     [UIView animateWithDuration:.5f delay:0.f usingSpringWithDamping:.7f initialSpringVelocity:1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
         self.alertView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
 
     } completion:nil];
 }

- (void)dissmiss {
    
    [UIView animateWithDuration:.3 animations:^{
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            self.bgView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
            [self removeFromSuperview];
    }];
}

@end
