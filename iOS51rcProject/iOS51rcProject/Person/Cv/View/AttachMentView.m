//
//  AttachMentView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/22.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AttachMentView.h"
#import "AttachmentModel.h"
#import "AttachmentImgView.h"

@implementation AttachMentView

- (instancetype)initWithFrame:(CGRect)frame data:(NSArray *)data{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupSubviews:data];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)setupSubviews:(NSArray *)data{
    

    CGFloat IMG_W = 90;
    if (data.count == 1) {
        AttachmentImgView *imgview = [AttachmentImgView new];
        imgview.model = [data firstObject];
        [self addSubview:imgview];
        imgview.sd_layout
        .widthIs(IMG_W)
        .centerXEqualToView(self)
        .centerYEqualToView(self)
        .heightIs(120);
        imgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
    }else if (data.count == 2){
        
        UILabel *lineLab = [UILabel new];
        [self addSubview:lineLab];
        lineLab.sd_layout
        .centerXEqualToView(self)
        .centerYEqualToView(lineLab)
        .widthIs(1)
        .heightRatioToView(self, 1);
        
        AttachmentImgView *imgview = [AttachmentImgView new];
        imgview.model = [data firstObject];
        [self addSubview:imgview];
        imgview.sd_layout
        .widthIs(IMG_W)
        .rightSpaceToView(lineLab, 5)
        .centerYEqualToView(self)
        .heightRatioToView(self, 1);
        imgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
        
        AttachmentImgView *imgview2 = [AttachmentImgView new];
        imgview2.model = [data lastObject];
        [self addSubview:imgview2];
        imgview2.sd_layout
        .widthRatioToView(imgview, 1)
        .leftSpaceToView(lineLab, 5)
        .centerYEqualToView(imgview)
        .heightRatioToView(imgview, 1);
        imgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
    }else if (data.count == 3){
        
        CGRect frame = self.frame;
        frame.origin.y = frame.origin.y - 30;
        self.frame = frame;
        
        AttachmentImgView *centerImgview = [AttachmentImgView new];
        centerImgview.model = [data objectAtIndex:1];
        [self addSubview:centerImgview];
        centerImgview.sd_layout
        .widthIs(IMG_W)
        .centerXEqualToView(self)
        .centerYEqualToView(self)
        .heightRatioToView(self, 1);
        centerImgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
        
        AttachmentImgView *leftImgview = [AttachmentImgView new];
        leftImgview.model = [data firstObject];
        [self addSubview:leftImgview];
        leftImgview.sd_layout
        .widthRatioToView(centerImgview, 1)
        .rightSpaceToView(centerImgview, 10)
        .centerYEqualToView(centerImgview)
        .heightRatioToView(centerImgview, 1);
        leftImgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
        
        AttachmentImgView *rightImgview = [AttachmentImgView new];
        rightImgview.model = [data lastObject];
        [self addSubview:rightImgview];
        rightImgview.sd_layout
        .widthRatioToView(centerImgview, 1)
        .leftSpaceToView(centerImgview, 10)
        .centerYEqualToView(centerImgview)
        .heightRatioToView(centerImgview, 1);
        rightImgview.deleteAttachment = ^(AttachmentModel *attach) {
            self.deleteAttachMent(attach);
        };
    }
}

@end
