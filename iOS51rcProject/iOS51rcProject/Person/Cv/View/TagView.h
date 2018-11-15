//
//  TagView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//


#import <UIKit/UIKit.h>

@interface TagView : UIView
@property (nonatomic ,strong)NSArray * arr;

@property (nonatomic ,copy) void(^handleSelectTag)(NSString *keyWord);

@end
