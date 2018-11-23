//
//  AttachMentView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/22.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AttachmentModel;

@interface AttachMentView : UIView
- (instancetype)initWithFrame:(CGRect)frame data:(NSArray *)data;

@property (nonatomic , copy)void (^deleteAttachMent)(AttachmentModel *attach);
@end
