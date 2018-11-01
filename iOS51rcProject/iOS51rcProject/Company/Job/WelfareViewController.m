//
//  WelfareViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/14.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "WelfareViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"

@interface WelfareViewController ()

@property (nonatomic, strong) NSArray *arrayWelfare;
@property (nonatomic, strong) NSArray *arrayWelfareId;
@property (nonatomic, strong) NSMutableArray *arrayWelfareIdSelected;
@end

@implementation WelfareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"福利待遇";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    
    if ([self.selectedWelfareId length] == 0) {
        self.selectedWelfareId = @"0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
    }
    self.arrayWelfareIdSelected = [[self.selectedWelfareId componentsSeparatedByString:@","] mutableCopy];
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    self.arrayWelfare = [Common arrayWelfare];
    self.arrayWelfareId = [Common arrayWelfareId];
    
    [self fillWelfare];
}

- (void)fillWelfare {
    float widthForWelfare = 15;
    float heightForWelfare = STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT + 15;
    for (NSInteger index = 0; index < self.arrayWelfare.count; index++) {
        NSString *welfare = [self.arrayWelfare objectAtIndex:index];
        WKLabel *lbWelfare = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForWelfare, heightForWelfare, 200, 35) content:welfare size:DEFAULTFONTSIZE color:nil];
        [lbWelfare setTextAlignment:NSTextAlignmentCenter];
        CGRect frameWelfare = lbWelfare.frame;
        frameWelfare.size.width = frameWelfare.size.width + 35;
        [lbWelfare setFrame:frameWelfare];
        
        if (VIEW_BX(lbWelfare) > SCREEN_WIDTH) {
            frameWelfare.origin.y = VIEW_BY(lbWelfare) + 10;
            frameWelfare.origin.x = 15;
        }
        [lbWelfare setFrame:frameWelfare];
        
        widthForWelfare = VIEW_BX(lbWelfare) + 10;
        heightForWelfare = VIEW_Y(lbWelfare);
        NSInteger welfareId = [[self.arrayWelfareId objectAtIndex:index] integerValue];
        UIButton *btnWelfare = [[UIButton alloc] initWithFrame:lbWelfare.frame];
        [btnWelfare setTag:welfareId];
        [btnWelfare setTitle:welfare forState:UIControlStateNormal];
        [btnWelfare setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnWelfare.titleLabel setFont:DEFAULTFONT];
        [btnWelfare.layer setMasksToBounds:YES];
        [btnWelfare.layer setBorderWidth:1];
        [btnWelfare.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [btnWelfare.layer setCornerRadius:5];
        [btnWelfare addTarget:self action:@selector(welfareClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnWelfare];
        
        if ([[self.arrayWelfareIdSelected objectAtIndex:(welfareId - 1)] isEqualToString:@"1"]) {
            [btnWelfare setBackgroundColor:GREENCOLOR];
            [btnWelfare setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)welfareClick:(UIButton *)button {
    NSInteger index = button.tag - 1;
    if ([[self.arrayWelfareIdSelected objectAtIndex:index] isEqualToString:@"0"]) {
        [button setBackgroundColor:GREENCOLOR];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.arrayWelfareIdSelected setObject:@"1" atIndexedSubscript:index];
    }
    else {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.arrayWelfareIdSelected setObject:@"0" atIndexedSubscript:index];
    }
}

- (void)saveClick {
    [self.delegate WelfareViewConfirm:[self.arrayWelfareIdSelected componentsJoinedByString:@","] welfare:[Common getWelfare:self.arrayWelfareIdSelected]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
