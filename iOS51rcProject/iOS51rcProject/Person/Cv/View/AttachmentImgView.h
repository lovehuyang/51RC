//
//  AttachmentImgView.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/21.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AttachmentModel;

@interface AttachmentImgView : UIImageView
@property (nonatomic , strong) AttachmentModel *model;
@property (nonatomic , copy) void (^deleteAttachment)(AttachmentModel *attach);
@end
