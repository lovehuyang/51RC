//
//  TagView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/15.
//  Copyright © 2018年 Jerry. All rights reserved.
//


#import <UIKit/UIKit.h>

@protocol TagViewDelegate <NSObject>

- (void)tagViewClick:(NSString *)title;

@end

@interface TagView : UIView
@property (nonatomic ,strong)NSArray * arr;

@property (nonatomic, assign) id<TagViewDelegate> delegate;

@end



