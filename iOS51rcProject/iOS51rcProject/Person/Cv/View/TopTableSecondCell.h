//
//  TopTableSecondCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/12/28.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class CVTopPackageModel;

@interface TopTableSecondCell : UITableViewCell
@property (nonatomic , copy) void (^buyPackageBlock)(CVTopPackageModel *model);
@property (nonatomic , strong) NSArray *dataArr;
@end
