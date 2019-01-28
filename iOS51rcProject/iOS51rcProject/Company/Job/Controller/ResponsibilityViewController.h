//
//  ResponsibilityViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/14.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol ResponsibilityViewDelegate <NSObject>

- (void)ResponsibilityViewConfirm:(NSString *)responsibility;
@end

@interface ResponsibilityViewController : WKViewController

@property (nonatomic, strong) NSString *responsibility;
@property (nonatomic, assign) id<ResponsibilityViewDelegate> delegate;
@end
