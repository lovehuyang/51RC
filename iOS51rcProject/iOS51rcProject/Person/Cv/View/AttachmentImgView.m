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
{
    UIImageView *imgView;
}

- (instancetype)init{
    if (self = [super init]) {
        
//        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
//        self.layer.borderWidth = 1;
//        self.contentMode = UIViewContentModeScaleAspectFit;
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self setupSubView];
    }
    return self;
}

- (void)setupSubView{
    imgView = [UIImageView new];
    imgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:imgView];
    imgView.sd_layout
    .leftSpaceToView(self, 0)
    .rightSpaceToView(self, 15)
    .topSpaceToView(self, 15)
    .bottomSpaceToView(self, 0);
    
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

- (void)setModel:(AttachmentModel *)model{
    _model = model;
    _model.FilePath = [NSString stringWithFormat:@"http://down.51rc.com/imagefolder/attachment/%@/%@",[self randomString],_model.FilePath];
    [imgView sd_setImageWithURL:[NSURL URLWithString:self.model.FilePath] placeholderImage:nil];
}
- (void)deleteEvent{
    self.deleteAttachment(self.model);
}

#pragma mark - 简历附件生成路径
- (NSString *)randomString{
    NSInteger photoPathTemp = ([self.model.cvMainID integerValue]/100000 + 1)  * 100000;
    NSString *tempStr = [NSString stringWithFormat:@"%ld",(long)photoPathTemp];
    NSMutableString *tempMutString = [NSMutableString string];
    
    for(int i =0; i < 8; i++){
        
        NSString *temp = [tempStr substringWithRange:NSMakeRange(i, 1)];
        [tempMutString appendString:temp];
    }
    
    NSString *randomStr = [NSString stringWithFormat:@"L0%@",tempMutString];
    return  randomStr;
}

@end
