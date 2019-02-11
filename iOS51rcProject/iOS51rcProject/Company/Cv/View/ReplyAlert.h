//
//  ReplyAlert.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/20.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^ReplyBlock)(NSInteger tag);

@interface ReplyAlert : UIView

@property (nonatomic , strong) NSString *name;
@property (nonatomic , copy) ReplyBlock replyBlock;

@end
