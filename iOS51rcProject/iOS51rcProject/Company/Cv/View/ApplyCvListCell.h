//
//  ApplyCvListCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/11.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ApplyCvListModel;

@interface ApplyCvListCell : UITableViewCell
@property (nonatomic , strong) ApplyCvListModel *model;
@property (nonatomic , copy) void(^replyBlock)(ApplyCvListModel *model);
@property (nonatomic , copy) void(^chatBlock)(ApplyCvListModel *model);
@end
