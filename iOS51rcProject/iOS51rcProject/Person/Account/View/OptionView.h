//
//  OptionView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/10/30.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OptionView : UIView
@property (nonatomic , copy)void (^optionViewClick)(NSString *optionTitle);
@end
