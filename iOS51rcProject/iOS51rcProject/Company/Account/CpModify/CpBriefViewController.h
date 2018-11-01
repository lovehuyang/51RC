//
//  CpBriefViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/16.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol CpBriefViewDelegate <NSObject>

- (void)CpBriefViewConfirm:(NSString *)brief;
@end

@interface CpBriefViewController : WKViewController

@property (nonatomic, strong) NSString *brief;
@property (nonatomic, assign) id<CpBriefViewDelegate> delegate;
@end
