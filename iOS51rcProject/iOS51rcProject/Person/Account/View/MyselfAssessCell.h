//
//  MyselfAssessCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MyselfAssessModel;
@interface MyselfAssessCell : UITableViewCell
@property (nonatomic , strong) MyselfAssessModel *model;
@property (nonatomic, copy) void(^cellBlock)(MyselfAssessModel *myselfModel , UIButton *button);
@end
