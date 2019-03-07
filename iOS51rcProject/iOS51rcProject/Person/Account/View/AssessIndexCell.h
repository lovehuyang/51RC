//
//  AssessIndexCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/5.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AssessIndexModel;

@interface AssessIndexCell : UITableViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic , strong) AssessIndexModel *model;
@property (nonatomic, copy) void(^assessBlock)(AssessIndexModel *model,UIButton *button);
@end
