//
//  CvInfoChildViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/3.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"
#import "CvInfoViewController.h"

@protocol CvInfoChildDelegate <NSObject>

- (void)cvInfoReload;
@end

@interface CvInfoChildViewController : WKViewController

@property (nonatomic, assign) id<CvInfoChildDelegate> delegate;
@property (nonatomic, strong) NSString *cvMainId;
@property Boolean onlyOne;
@end
