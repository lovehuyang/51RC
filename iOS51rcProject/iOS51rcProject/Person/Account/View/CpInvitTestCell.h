//
//  CpInvitTestCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CpInvitTestModel.h"

@interface CpInvitTestCell : UITableViewCell
@property (nonatomic , strong) CpInvitTestModel *model;
@property (nonatomic , copy) void (^cellBlock)(CpInvitTestModel *model);
@end
