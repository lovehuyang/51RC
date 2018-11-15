//
//  TagView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//


#import "TagView.h"
#import "TagViewBtn.h"

#define kScreenWidth      [UIScreen mainScreen].bounds.size.width
@implementation TagView

-(void)setArr:(NSArray *)arr{
    _arr = arr;
    CGFloat marginX = 15;
    CGFloat marginY = 10;
    CGFloat height = 22;
    UIButton * markBtn;
    for (int i = 0; i < _arr.count; i++) {
        CGFloat width =  [self calculateString:_arr[i] Width:12] +30;
        TagViewBtn * tagBtn = [TagViewBtn buttonWithType:UIButtonTypeCustom];
        if (!markBtn) {
            tagBtn.frame = CGRectMake(marginX, marginY, width, height);
        }else{
            if (markBtn.frame.origin.x + markBtn.frame.size.width + marginX + width + marginX > kScreenWidth) {
                tagBtn.frame = CGRectMake(marginX, markBtn.frame.origin.y + markBtn.frame.size.height + marginY, width, height);
            }else{
                tagBtn.frame = CGRectMake(markBtn.frame.origin.x + markBtn.frame.size.width + marginX, markBtn.frame.origin.y, width, height);
            }
        }
        [tagBtn setTitle:_arr[i] forState:UIControlStateNormal];
        tagBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [tagBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self makeCornerRadius:3 borderColor:[UIColor lightGrayColor] layer:tagBtn.layer borderWidth:.5];
        markBtn = tagBtn;
        
        [tagBtn addTarget:self action:@selector(clickTo:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:markBtn];
    }
    CGRect rect = self.frame;
    rect.size.height = markBtn.frame.origin.y + markBtn.frame.size.height + marginY;
    self.frame = rect;
}


-(void)clickTo:(UIButton *)sender
{
    self.handleSelectTag(sender.titleLabel.text);
}



-(void)makeCornerRadius:(CGFloat)radius borderColor:(UIColor *)borderColor layer:(CALayer *)layer borderWidth:(CGFloat)borderWidth
{
    layer.cornerRadius = radius;
    layer.masksToBounds = YES;
    layer.borderColor = borderColor.CGColor;
    layer.borderWidth = borderWidth;
}

-(CGFloat)calculateString:(NSString *)str Width:(NSInteger)font
{
    CGSize size = [str boundingRectWithSize:CGSizeMake(kScreenWidth, 100000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:font]} context:nil].size;
    return size.width;
}

@end
