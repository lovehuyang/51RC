//
//  AdAlert.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AdAlert.h"

@interface AdAlert()

@property (nonatomic , strong) UIView *bgView;// 褐色透明背景
@property (nonatomic , strong) UIImageView *adImgView;// 广告图片
@property (nonatomic , strong) NSDictionary *dataDict;// 数据源

@end

@implementation AdAlert

-(instancetype)initWithData:(NSDictionary *)data{
    if (self = [super init]) {
        
        self.dataDict = [[NSDictionary alloc]initWithDictionary:data];
        
        self.bgView = [UIView new];
        [self.view addSubview:self.bgView];
        self.bgView.sd_layout
        .leftSpaceToView(self.view, 0)
        .topSpaceToView(self.view, 0)
        .rightSpaceToView(self.view, 0)
        .bottomSpaceToView(self.view, 0);
        self.bgView.backgroundColor = [UIColor blackColor];
        self.bgView.alpha = 0.5;
        self.bgView.userInteractionEnabled = YES;
        
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews{
    
    // 广告图片
    UIImageView *adImgView = [UIImageView new];
    [self.view addSubview:adImgView];
    adImgView.sd_layout
    .widthIs(SCREEN_WIDTH * 0.8)
    .heightIs(SCREEN_WIDTH * 0.8 * 1.45)
    .centerXEqualToView(self.bgView)
    .centerYEqualToView(self.bgView);
    [adImgView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/imagefolder/operational/hpimage/%@", [self.dataDict objectForKey:@"ImageFile"]]]];
    adImgView.userInteractionEnabled = YES;
    
    // 有超链接
    if ([[self.dataDict objectForKey:@"Url"] length] > 0) {
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launcherPicClick)];
        [adImgView addGestureRecognizer:singleTap];
    }

    // 关闭按钮
    CGFloat closeBtn_H = 50;
    CGFloat closeBtn_W = 50 * 0.5753;
    UIButton *closeBtn = [UIButton new];
    [self.view addSubview:closeBtn];
    closeBtn.sd_layout
    .leftSpaceToView(adImgView, -closeBtn_W)
    .bottomSpaceToView(adImgView, 0)
    .heightIs(closeBtn_H)
    .widthIs(closeBtn_W);
    [closeBtn setImage:[UIImage imageNamed:@"img_picclose.png"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(dissmiss) forControlEvents:UIControlEventTouchUpInside];
}

- (void)launcherPicClick{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[self.dataDict objectForKey:@"Url"]]];
    [self dissmiss];
}

- (void)show:(UIViewController *)vc{
    
    if ([[self.dataDict objectForKey:@"Id"] isEqualToString:[USER_DEFAULT objectForKey:@"launcherPicId"]]) {// 弹窗弹出过
        return;

    }
    
    // 弹窗未弹出过，记录下弹窗广告的id
    [USER_DEFAULT setObject:[self.dataDict objectForKey:@"Id"] forKey:@"launcherPicId"];
    self.modalPresentationStyle = UIModalPresentationOverFullScreen;
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [vc presentViewController:self animated:YES completion:nil];
}

- (void)dissmiss {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
