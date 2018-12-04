//
//  SpeechButton.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/3.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpeechButton : UIView
@property (nonatomic , copy) void(^speechInput)();
@end
