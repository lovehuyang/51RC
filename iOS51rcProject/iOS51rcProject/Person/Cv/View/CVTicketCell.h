//
//  CVTicketCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/29.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CVTicketModel;

@interface CVTicketCell : UITableViewCell
@property (nonatomic ,strong)CVTicketModel *model;
@property (nonatomic , copy) void (^getTicketBlock)(CVTicketModel *model);
@end
