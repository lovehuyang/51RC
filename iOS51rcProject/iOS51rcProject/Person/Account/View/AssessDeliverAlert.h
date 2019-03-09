//
//  AssessDeliverAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/7.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AssessDeliverAlert : UIView

- (void)setTitle:(NSString *)title markContent:(NSString *)markContent content:(NSString *)content btnTitle:(NSString *)btnTitle;
- (void)show;
@end
