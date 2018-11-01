//
//  MultiSelectViewController.h
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/11.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKViewController.h"

typedef enum {
    MultiSelectTypeRegion = 1,
    MultiSelectTypeJobType = 2,
    MultiSelectTypeIndustry = 3,
    MultiSelectTypeCpIndustry = 4
} MultiSelectType;

typedef enum {
    MultiSelectAccountTypePersonal = 1,
    MultiSelectAccountTypeCompany = 2
} MultiSelectAccountType;

@protocol MultiSelectDelegate <NSObject>

- (void)getMultiSelect:(NSInteger)selectType arraySelect:(NSArray *)arraySelect;
@end

@interface MultiSelectViewController : WKViewController

@property (nonatomic, assign) id<MultiSelectDelegate> delegate;
@property (nonatomic, strong) NSString *selId;
@property (nonatomic, strong) NSString *selValue;
@property MultiSelectType selectType;
@property MultiSelectAccountType accountType;
@end
