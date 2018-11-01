//
//  CpLogoViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"

@interface CpLogoViewController : WKViewController

@property (strong, nonatomic) IBOutlet UILabel *lbLogo;
@property (strong, nonatomic) IBOutlet UIImageView *imgLogo;
@property (strong, nonatomic) IBOutlet UIView *viewUpload;
@property (strong, nonatomic) IBOutlet UIView *viewDelete;
@end
