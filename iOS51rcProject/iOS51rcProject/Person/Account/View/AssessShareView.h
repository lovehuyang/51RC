//
//  AssessShareView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessShareView : UIView

@property (nonatomic , copy) void (^shareBlock)(UIButton *button);
- (void)show;

@end
