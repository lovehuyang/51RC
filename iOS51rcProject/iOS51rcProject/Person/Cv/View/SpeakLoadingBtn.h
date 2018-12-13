//
//  SpeakLoadingBtn.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/11.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeakLoadingBtn : UIView

@property (nonatomic ,copy) void(^speakStatus)(BOOL speaking);

@end
