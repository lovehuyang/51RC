//
//  RecommendJobView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/12.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecommendJobView : UIView
@property (nonatomic , copy)void(^applyFor)();

- (instancetype)initWithData:(NSArray *)dataArr;
- (void)show;
@end
