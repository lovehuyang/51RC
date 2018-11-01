//
//  TABButton.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/30.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "TABButton.h"
@interface TABButton ()
@property (nonatomic ,strong)NSString *title;
@end

@implementation TABButton

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)image{
    if (self = [super initWithFrame:frame]) {
        [self setupAllSubViews:title image:image];
        self.userInteractionEnabled = YES;
        self.title = title;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapEvent)];
        [self addGestureRecognizer:tap];
    }
    return  self;
}

- (void)setupAllSubViews:(NSString *)title image:(NSString *)image{
    UIImageView *imgView = [UIImageView new];
    imgView.frame = CGRectMake(self.frame.size.width/2 - 12.5, self.frame.size.height/2 - 12.5, 25, 25);
    imgView.image = [UIImage imageNamed:image];
    [self addSubview:imgView];
    
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(0, CGRectGetMaxY(imgView.frame), self.frame.size.width, 20);
    titleLab.textAlignment = NSTextAlignmentCenter;
    titleLab.text = title;
    titleLab.font = SMALLERFONT;
    [self addSubview:titleLab];
}

- (void)tapEvent{
    self.btnClick(self.title);
}

@end
