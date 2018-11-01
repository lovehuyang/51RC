//
//  WelfareViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/14.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol WelfareViewDelegate <NSObject>

- (void)WelfareViewConfirm:(NSString *)welfareId welfare:(NSString *)welfare;
@end

@interface WelfareViewController : WKViewController

@property (nonatomic, assign) id<WelfareViewDelegate> delegate;
@property (nonatomic, strong) NSString *selectedWelfareId;
@end
