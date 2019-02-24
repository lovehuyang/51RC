//
//  AccountListCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/24.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WKButton.h"
@class AccountListModel;

@interface AccountListCell : UITableViewCell
@property (nonatomic , strong) NSIndexPath *indexPath;
@property (nonatomic , strong) AccountListModel *model;

@property (nonatomic , copy) void(^cellBlock)(WKButton *button, NSString *event);
@end
