//
//  VoiceWaveImgView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/4.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "VoiceWaveImgView.h"

@implementation VoiceWaveImgView
- (instancetype)init{
    if (self = [super init]) {
        NSMutableArray *imgMutArr = [NSMutableArray array];
        for (int i = 1; i <11; i ++) {
            UIImage *img = [UIImage imageNamed:[NSString stringWithFormat:@"voice_loading_%d",i]];
            [imgMutArr addObject:img];
        }
        self.animationImages = imgMutArr;
        self.animationDuration = 1;
        self.animationRepeatCount = 0;
        [self startAnimating];
    }
    return self;
}
@end
