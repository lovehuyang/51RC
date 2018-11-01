//
//  DemandViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/14.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@protocol DemandViewDelegate <NSObject>

- (void)DemandViewConfirm:(NSString *)demand;
@end

@interface DemandViewController : WKViewController

@property (nonatomic, strong) NSString *demand;
@property (nonatomic, assign) id<DemandViewDelegate> delegate;
@end
