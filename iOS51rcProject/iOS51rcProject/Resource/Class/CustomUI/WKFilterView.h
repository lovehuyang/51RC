//
//  WKFilterView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/21.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WKFilterTypeRegion = 1,
    WKFilterTypeJobType = 2,
    WKFilterTypeSalary = 3,
    WKFilterTypeOther = 4,
    WKFilterTypeDistance = 5
} WKFilterType;

@protocol WKFilterViewDelegate <NSObject>

- (void)WKFilterItemClick:(WKFilterType)filterType selectedItem:(NSDictionary *)selectedItem;
- (void)WKFilterOtherClick:(NSArray *)selectedItems;
- (void)WKFilterViewClose;
@end

@interface WKFilterView : UIView<UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property (nonatomic, assign) id<WKFilterViewDelegate> delegate;
@property (nonatomic) WKFilterType filterType;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) NSArray *arrayOther;
@property (nonatomic, strong) NSMutableArray *arraySelect;
@property (nonatomic, strong) UITableView *tableViewLeft;
@property (nonatomic, strong) UITableView *tableViewRight;
@property NSInteger selectRow;

- (id)initWithButton:(UIButton *)button;
- (void)showFilterView:(UIViewController *)viewController;
@end
