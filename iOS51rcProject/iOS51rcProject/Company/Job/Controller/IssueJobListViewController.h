//
//  IssueJobListViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/9.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol IssueJobListViewDelegate <NSObject>

- (void)expiredListReload;
@end

@interface IssueJobListViewController : WKViewController

@property (nonatomic, assign) id<IssueJobListViewDelegate> delegate;
- (void)initData;
@end
