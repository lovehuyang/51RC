//
//  ChatListCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2019/2/15.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ChatListModel;

@interface ChatListCell : UITableViewCell
@property (nonatomic , strong) ChatListModel *model;

@end
