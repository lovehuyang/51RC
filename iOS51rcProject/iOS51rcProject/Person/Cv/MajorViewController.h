//
//  MajorViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/12.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol MajorViewDelete <NSObject>

- (void)majorViewClick:(NSDictionary *)major;
@end

@interface MajorViewController : WKViewController

@property (nonatomic, assign) id<MajorViewDelete> delegate;
@end
