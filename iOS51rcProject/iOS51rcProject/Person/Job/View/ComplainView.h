//
//  ComplainView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/31.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ComplainView : UIView

@property (nonatomic , copy)NSString *content; // 文本框

- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title content:(NSString *)content textViewHeight:(CGFloat)height;
@end
