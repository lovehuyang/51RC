//
//  ExpiredJobListViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol ExpiredJobListViewDelegate <NSObject>

- (void)issueListReload;
@end

@interface ExpiredJobListViewController : WKViewController

@property (nonatomic, assign) id<ExpiredJobListViewDelegate> delegate;
- (void)initData;
@end
