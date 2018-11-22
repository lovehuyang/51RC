//
//  AttachmentImgView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AttachmentImgView.h"

@implementation AttachmentImgView

- (instancetype)init{
    if (self = [super init]) {
        UIButton *deleteBtn = [UIButton new];
        [self addSubview:deleteBtn];
        deleteBtn.sd_layout
        .rightSpaceToView(self, 0)
        .topSpaceToView(self, 0)
        .heightIs(30)
        .widthEqualToHeight();
        [deleteBtn setImage:[UIImage imageNamed:@"attachment_delete"] forState:UIControlStateNormal];
        [deleteBtn addTarget:self action:@selector(deleteEvent) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setModel:(AttachmentModel *)model{
    _model = model;
}
- (void)deleteEvent{
    
}


@end
