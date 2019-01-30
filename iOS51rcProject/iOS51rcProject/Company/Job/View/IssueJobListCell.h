//
//  IssueJobListCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/1/29.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CpJobListModel;

@interface IssueJobListCell : UITableViewCell

@property (nonatomic , strong) CpJobListModel *model;
@property (nonatomic , copy) void(^issueCellBlock)(UIButton *btn,CpJobListModel *model);

@end
