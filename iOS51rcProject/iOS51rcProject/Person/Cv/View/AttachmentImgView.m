//
//  AttachmentImgView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "AttachmentImgView.h"
#import "AttachmentModel.h"

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
        
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (void)setModel:(AttachmentModel *)model{
    _model = model;
    _model.FilePath = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/attachment/%@/%@",[self randomString],_model.FilePath];
//    _model.FilePath = @"http://down.51rc.com/imagefolder/Photo/L026400000/Processed/26395818_20181122082729.jpg";
//http://down.51rc.com/imagefolder/attachment/L028670000/28663401_20181126093741.jp
    [self sd_setImageWithURL:[NSURL URLWithString:self.model.FilePath] placeholderImage:nil];
}
- (void)deleteEvent{
    self.deleteAttachment(self.model);
}

#pragma mark - 简历附件生成路径
- (NSString *)randomString{
    NSInteger photoPathTemp = ([self.model.cvMainID integerValue]/100000 + 1)  * 100000;
    NSString *randomStr = [NSString stringWithFormat:@"L0%ld",(long)photoPathTemp];
    return  randomStr;
}


@end
