//
//  CVPackageView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CVTopPackageModel;

@interface CVPackageView : UIView

@property (nonatomic , copy) void (^buyBtnClickBlock)(CVTopPackageModel *model);
@property (nonatomic , strong) CVTopPackageModel *model;
@end
