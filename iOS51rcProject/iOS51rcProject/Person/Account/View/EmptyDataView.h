//
//  EmptyDataView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/7.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmptyDataView : UIView
- (instancetype)initWithTip:(NSString *)tipStr;
@property (nonatomic , copy) void(^emptyDataTouch)();
@end
