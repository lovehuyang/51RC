//
//  WKLoading.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/9.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKLoadingView.h"
#import "CommonMacro.h"
#import "UIImage+GIF.h"
#import "FLAnimatedImage.h"

@implementation WKLoadingView

- (id)initLoading {
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        [self setTag:LOADINGTAG];
        [self setHidden:YES];
        [self setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.5]];
        //[self setBackgroundColor:[UIColor whiteColor]];
        NSString *loadingPath = [[NSBundle mainBundle] pathForResource:@"loading.gif" ofType:nil];
        float imgWidth = SCREEN_WIDTH * 0.3;
        float imgHeight = imgWidth * 0.89;
        FLAnimatedImageView *imgLoading = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        [imgLoading setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:loadingPath]]];
        [imgLoading setCenter:self.center];
        [self addSubview:imgLoading];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
