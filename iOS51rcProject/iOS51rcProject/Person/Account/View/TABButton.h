//
//  TABButton.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/30.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TABButton : UIView
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title image:(NSString *)image;

@property (nonatomic ,copy)void(^btnClick)(NSString *title);

@end
