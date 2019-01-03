//
//  KeywordViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/4.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

@protocol KeyWordViewDelegate <NSObject>

- (void)KeyWordSelect:(NSString *)keyword;
@end

@interface KeywordViewController : WKViewController

@property (nonatomic, assign) id<KeyWordViewDelegate> delegate;
@property (nonatomic, strong) NSString *keyWord;
@end
