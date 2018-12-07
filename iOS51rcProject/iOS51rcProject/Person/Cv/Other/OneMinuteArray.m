//
//  OneMinuteArray.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/27.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "OneMinuteArray.h"
#import "OneMinuteModel.h"
#import "Common.h"
#import "NSString+RCString.h"

@implementation OneMinuteArray
+ (NSArray *)createOneMinuteDataWithType:(NSInteger )type dict:(NSDictionary *)dataDict{
    NSMutableArray  *dataArr = [NSMutableArray array];
    
    NSArray *keyBoardUseArr = @[@"1",
                                @"1",
                                @[@"1",@"0"],
                                @"0",
                                @[@"1",@"0"],
                                @[@"0",@"0"],
                                @[@"0",@"0"],
                                @"0",
                                @"0"];
    NSArray *placeholderArr = @[@"手机号码",
                                @"短信确认码",
                                @[@"姓名",@"性别"],
                                @"出生年月",
                                @[@"毕业院校",@"学历"],
                                @[@"专业名称",@"专业类别"],
                                @[@"期望工作地点",@"期望职位类别"],
                                @"期望月薪",
                                @"求职状态"];
    
    // 获取日期信息
    NSString *birthStr = dataDict[@"BirthDay"];
    NSString *birthDayStr = @"";
    if (birthStr.length > 0) {
        NSRange range1 = NSMakeRange(0, 4);
        NSRange range2 = NSMakeRange(4, 2);
        birthDayStr = [NSString stringWithFormat:@"%@年%@月",[birthStr substringWithRange:range1],[birthStr substringWithRange:range2] ];
    }
    // 获取求职状态id 转成文字
    NSArray *careerStatusArr = [Common getCareerStatus];
    NSString *careerStatusStr = @"";
    for (NSDictionary *dic in careerStatusArr) {
        if ([dic[@"id"] isEqualToString:dataDict[@"dcCareerStatus"]]) {
            careerStatusStr = dic[@"value"];
            break;
        }
    }

    NSString *mobile = [NSString juedeString:dataDict[@"Mobile"]];
    NSString *name = [NSString juedeString:dataDict[@"Name"]];
    NSString *Gender = [NSString juedeString:dataDict[@"Gender"]];
    
    
    NSArray *contentArr = @[mobile,
                            @"",
                            @[name,[Gender boolValue]?@"女":@"男"],
                            birthDayStr,
                            @[@"",@""],
                            @[@"",@""],
                            @[@"",@""],
                            @"",
                            careerStatusStr];
    
    
    for (int i = 0; i < placeholderArr.count; i ++) {
        id element = [placeholderArr objectAtIndex:i];
        if ([element isKindOfClass:[NSString class]]) {
            OneMinuteModel *model = [[OneMinuteModel alloc]init];
            model.contentStr = contentArr[i];
            model.placeholderStr = (NSString *)element;
            model.useKeyBoard = keyBoardUseArr[i];
            [dataArr addObject:model];
        }else if ([element isKindOfClass:[NSArray class]]){
            NSArray *elementArr = (NSArray *)element;
            NSMutableArray *tempArr = [NSMutableArray array];
            for (int j = 0; j < elementArr.count; j ++) {
                NSString *tempStr = elementArr[j];
                OneMinuteModel *model = [[OneMinuteModel alloc]init];
                model.contentStr = contentArr[i][j];
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
