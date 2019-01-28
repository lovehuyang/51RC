//
//  JobTagViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol JobTagViewDelegate <NSObject>

- (void)JobTagViewConfirm:(NSString *)tag;
@end

@interface JobTagViewController : WKViewController

@property (nonatomic, assign) id<JobTagViewDelegate> delegate;
@property (nonatomic, strong) NSString *selectedTag;
@end
