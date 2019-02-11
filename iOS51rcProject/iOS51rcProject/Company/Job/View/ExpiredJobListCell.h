//
//  ExpiredJobListCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/30.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CpJobListModel;

@interface ExpiredJobListCell : UITableViewCell

@property (nonatomic , strong) CpJobListModel *model;
@property (nonatomic , copy) void(^expiredCellBlock)(UIButton *btn,CpJobListModel *model);


@end
