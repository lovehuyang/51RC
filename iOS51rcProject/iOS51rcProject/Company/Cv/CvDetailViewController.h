//
//  CvDetailViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/4/10.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKViewController.h"
#import "NetWebServiceRequest.h"

@interface CvDetailViewController : WKViewController

@property (nonatomic, strong) NSString *cvMainId;
@property (nonatomic, strong) NSString *jobId;
@end
