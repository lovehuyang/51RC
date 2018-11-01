//
//  WKButton.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/6.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKButton.h"
#import "CommonMacro.h"
#import "WKLabel.h"

@implementation WKButton

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:BIGGERFONT];
        if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"1"]) {
            [self setBackgroundColor:NAVBARCOLOR];
        }
        else {
            [self setBackgroundColor:CPNAVBARCOLOR];
        }
        [self.layer setCornerRadius:VIEW_H(self) / 5];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.titleLabel setFont:BIGGERFONT];
        [self setBackgroundColor:NAVBARCOLOR];
        [self.layer setCornerRadius:VIEW_H(self) / 5];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color bgColor:(UIColor *)bgColor {
    self = [super initWithFrame:frame];
    if (self) {
        [self setTitle:title forState:UIControlStateNormal];
        [self setTitleColor:color forState:UIControlStateNormal];
        [self setBackgroundColor:bgColor];
        [self.titleLabel setFont:[UIFont systemFontOfSize:fontSize]];
    }
    return self;
}

- (id)initImageButtonWithFrame:(CGRect)frame image:(NSString *)image title:(NSString *)title fontSize:(CGFloat)fontSize color:(UIColor *)color bgColor:(UIColor *)bgColor {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *viewContent = [[UIView alloc] init];
        [viewContent setUserInteractionEnabled:NO];
        float heightForImage = frame.size.height / 2;
        UIImageView *imgTitle = [[UIImageView alloc] initWithFrame:CGRectMake(0, heightForImage / 2, heightForImage, heightForImage)];
        [imgTitle setImage:[UIImage imageNamed:image]];
        [imgTitle setContentMode:UIViewContentModeScaleAspectFit];
        [viewContent addSubview:imgTitle];
        
        WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgTitle) + 5, 0, frame.size.width, frame.size.height) content:title size:fontSize color:color];
        [viewContent addSubview:lbTitle];
        
        [viewContent setFrame:CGRectMake(0, 0, VIEW_BX(lbTitle), frame.size.height)];
        [viewContent setCenter:CGPointMake(frame.size.width / 2, viewContent.center.y)];
        [self addSubview:viewContent];
        
        if (bgColor != nil) {
            [self setBackgroundColor:bgColor];
        }
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
     Drawing code
}
*/

@end
