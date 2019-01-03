//
//  RedPacketView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/2.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RedPacketView : UIView
@property (nonatomic , copy) NSString *money;// 红包的金额
- (void)show;

@end
