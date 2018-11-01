//
//  JobPushViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/28.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "JobPushViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"

@interface JobPushViewController ()

@property (nonatomic, strong) NSArray *arrayPush;
@end

@implementation JobPushViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"推荐简历";
    [self.view setBackgroundColor:[UIColor whiteColor]];
    if (self.pushId.length == 0) {
        self.pushId = @"0000000";
    }
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    self.arrayPush = [Common arrayPush];
    [self fillPush];
}

- (void)fillPush {
    float widthForPush = 15;
    float heightForPush = STATUS_BAR_HEIGHT + NAVIGATION_BAR_HEIGHT + 15;
    
    WKLabel *lbTips = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForPush, heightForPush, SCREEN_WIDTH, 20) content:@"请选择每周推送时间" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [self.view addSubview:lbTips];
    
    heightForPush = VIEW_BY(lbTips) + 15;
    
    for (NSInteger index = 0; index < self.arrayPush.count; index++) {
        NSString *push = [self.arrayPush objectAtIndex:index];
        WKLabel *lbPush = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForPush, heightForPush, 200, 35) content:push size:DEFAULTFONTSIZE color:nil];
        [lbPush setTextAlignment:NSTextAlignmentCenter];
        CGRect framePush = lbPush.frame;
        framePush.size.width = framePush.size.width + 35;
        [lbPush setFrame:framePush];
        
        if (VIEW_BX(lbPush) > SCREEN_WIDTH) {
            framePush.origin.y = VIEW_BY(lbPush) + 10;
            framePush.origin.x = 15;
        }
        [lbPush setFrame:framePush];
        
        widthForPush = VIEW_BX(lbPush) + 10;
        heightForPush = VIEW_Y(lbPush);
        UIButton *btnPush = [[UIButton alloc] initWithFrame:lbPush.frame];
        [btnPush setTag:index];
        [btnPush setTitle:push forState:UIControlStateNormal];
        [btnPush setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnPush.titleLabel setFont:DEFAULTFONT];
        [btnPush.layer setMasksToBounds:YES];
        [btnPush.layer setBorderWidth:1];
        [btnPush.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [btnPush.layer setCornerRadius:5];
        [btnPush addTarget:self action:@selector(pushClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btnPush];
        
        if ([[self.pushId substringWithRange:NSMakeRange(index, 1)] isEqualToString:@"1"]) {
            [btnPush setBackgroundColor:GREENCOLOR];
            [btnPush setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}

- (void)pushClick:(UIButton *)button {
    NSInteger index = button.tag;
    NSRange range = NSMakeRange(index, 1);
    if ([[self.pushId substringWithRange:range] isEqualToString:@"0"]) {
        [button setBackgroundColor:GREENCOLOR];
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.pushId = [self.pushId stringByReplacingCharactersInRange:range withString:@"1"];
    }
    else {
        [button setBackgroundColor:[UIColor whiteColor]];
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.pushId = [self.pushId stringByReplacingCharactersInRange:range withString:@"0"];
    }
}

- (void)saveClick {
    [self.delegate JobPushViewConfirm:self.pushId push:[Common getPush:self.pushId]];
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

