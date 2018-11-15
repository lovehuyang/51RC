//
//  ShieldSetEmptyDataView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddEvent)();

@interface ShieldSetEmptyDataView : UIView
@property (nonatomic , copy)AddEvent addEvent;
@end
