//
//  WKCvTableViewCell.h
//  iOS51rcProject
//
//  Created by Lucifer on 2018/2/24.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WKCvTableViewCell : UITableViewCell

@property (nonatomic, strong) NSString *cvMainId;
@property (nonatomic) NSString *jobId;
@property (nonatomic, strong) UIViewController *viewController;
@property NSInteger listType;

- (instancetype)initWithListType:(NSInteger)listType reuseIdentifier:(NSString *)reuseIdentifier viewController:(UIViewController *)viewController;

- (void)fillCvInfo:(NSString *)topString gender:(NSString *)gender name:(NSString *)name relatedWorkYears:(NSString *)relatedWorkYears age:(NSString *)age degree:(NSString *)degree livePlace:(NSString *)livePlace loginDate:(NSString *)loginDate mobileVerifyDate:(NSString *)mobileVerifyDate paPhoto:(NSString *)paPhoto online:(NSString *)online paMainId:(NSString *)paMainId cvMainId:(NSString *)cvMainId;
@end
