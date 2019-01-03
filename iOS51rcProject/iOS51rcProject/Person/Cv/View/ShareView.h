//
//  ShareView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/2.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShareView : UIView

@property (nonatomic , copy) void (^shareBlock)();
- (void)show;
@end
