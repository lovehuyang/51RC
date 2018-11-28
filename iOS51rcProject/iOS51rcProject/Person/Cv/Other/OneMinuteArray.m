//
//  OneMinuteArray.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "OneMinuteArray.h"
#import "OneMinuteModel.h"

@implementation OneMinuteArray
+ (NSArray *)createOneMinuteDataWithType:(NSInteger )type{
    NSMutableArray  *dataArr = [NSMutableArray array];
    
    NSArray *keyBoardUseArr = @[@"1",@"1",@[@"1",@"0"],@"0",@[@"1",@"0"],@[@"0",@"0"],@[@"0",@"0"],@"0",@"0"];
    NSArray *placeholderArr = @[@"手机号码",@"短信确认码",@[@"姓名",@"性别"],@"出生年月",@[@"毕业院校",@"学历"],@[@"专业名称",@"专业类别"],@[@"期望工作地点",@"期望职位类别"],@"期望月薪",@"求职状态"];
    
    for (int i = 0; i < placeholderArr.count; i ++) {
        id element = [placeholderArr objectAtIndex:i];
        if ([element isKindOfClass:[NSString class]]) {
            OneMinuteModel *model = [[OneMinuteModel alloc]init];
            model.contentStr = @"";
            model.placeholderStr = (NSString *)element;
            model.useKeyBoard = keyBoardUseArr[i];
            [dataArr addObject:model];
        }else if ([element isKindOfClass:[NSArray class]]){
            NSArray *elementArr = (NSArray *)element;
            NSMutableArray *tempArr = [NSMutableArray array];
            for (int j = 0; j < elementArr.count; j ++) {
                NSString *tempStr = elementArr[j];
                OneMinuteModel *model = [[OneMinuteModel alloc]init];
                model.contentStr = @"";
                model.placeholderStr = tempStr;
                model.useKeyBoard = keyBoardUseArr[i][j];
                [tempArr addObject:model];
            }
            
            
//            for (NSString *tempStr in elementArr) {
//                OneMinuteModel *model = [[OneMinuteModel alloc]init];
//                model.contentStr = @"";
//                model.placeholderStr = tempStr;
//                model.useKeyBoard = keyBoardUseArr[i];
//                [tempArr addObject:model];
//            }
            [dataArr addObject:tempArr];
        }
    }
    if(type == 1){
        [dataArr removeObjectAtIndex:0];
        [dataArr removeObjectAtIndex:0];
        
    }
    return [NSArray arrayWithArray:dataArr];
}
@end
