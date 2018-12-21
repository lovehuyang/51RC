//
//  SelectCvAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectCvAlert : UIView
@property (nonatomic , copy)void(^completeInformation)();
- (void)show;
- (void)dissmiss;
@end
