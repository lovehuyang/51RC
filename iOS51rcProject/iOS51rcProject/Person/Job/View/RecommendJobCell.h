//
//  RecommendJobCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/12.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class InsertJobApplyModel;

@interface RecommendJobCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier data:(InsertJobApplyModel *)model;
@property (nonatomic , copy) void(^selectedPositon)(InsertJobApplyModel *model);
@end
