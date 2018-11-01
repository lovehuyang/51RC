//
//  WKApplyView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/2.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKPopView.h"

@protocol WKApplyViewDelegate;

@interface WKApplyView : UIView<WKPopViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, assign) id<WKApplyViewDelegate> delegate;
@property (nonatomic, strong) NSString *cvMainId;
@property (nonatomic, strong) NSArray *arrayJob;
@property (nonatomic, strong) NSMutableArray *arrSelected;
@property (nonatomic, strong) UITableView *tableView;

- (id)initWithArrayCv:(NSArray *)arrayCv;
- (id)initWithRecommendJob:(NSArray *)arrayJob;
- (void)show:(UIViewController *)viewController;
- (void)showRecommend:(UIViewController *)viewController;
@end

@protocol WKApplyViewDelegate <NSObject>

- (void)WKApplyViewConfirm:(WKApplyView *)applyView arrayJobId:(NSString *)cvMainId;

@optional
- (void)WKApplyViewApplyBatch:(NSArray *)arrayJobId;
@end
