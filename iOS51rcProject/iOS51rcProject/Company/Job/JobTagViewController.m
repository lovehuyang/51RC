//
//  JobTagViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/3/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "JobTagViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "UIView+Toast.h"

@interface JobTagViewController ()<UITextFieldDelegate>

@property (nonatomic, strong) NSArray *arrayTag;
@property (nonatomic, strong) NSMutableArray *arrayTagSelected;
@property (nonatomic, strong) UIView *viewSelected;
@property (nonatomic, strong) UIView *viewTag;
@property (nonatomic, strong) UIScrollView *viewScroll;
@property (nonatomic, strong) UITextField *txtAdd;
@end

@implementation JobTagViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"职位诱惑";
    
    UIBarButtonItem *btnSave = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveClick)];
    [btnSave setTintColor:[UIColor whiteColor]];
    [btnSave setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:BIGGERFONT,NSFontAttributeName, nil] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = btnSave;
    
    self.viewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [self.viewScroll setBackgroundColor:SEPARATECOLOR];
    [self.view addSubview:self.viewScroll];
    
    self.arrayTag = [[NSArray alloc] initWithObjects:@"A轮融资", @"B轮融资", @"C轮融资", @"D轮融资", @"13薪", @"不出差", @"扁平化", @"寒暑假", @"正能量", @"不加班", @"下午茶", @"牛人多", @"大平台 ", @"健身房", @"台球桌", @"妹子多", @"高晋升", @"压力小", @"自由互助", @"领导Nice", @"水果零食", @"帅哥美女", @"定期团建", @"股权期权", @"国企控股", @"前瞻行业", @"大厨三餐", @"朝十晚六", @"氛围融洽", @"弹性工作", @"挑战高薪", @"创新项目", @"环境优雅", @"季度加薪", @"阳光团队", @"CBD办公", @"无需打卡", @"交通便利", @"苹果电脑", nil];
    if (self.selectedTag.length == 0) {
        self.arrayTagSelected = [[NSMutableArray alloc] init];
    }
    else {
        self.arrayTagSelected = [[self.selectedTag componentsSeparatedByString:@"@"] mutableCopy];
    }
    self.viewSelected = [[UIView alloc] init];
    [self.viewSelected setBackgroundColor:[UIColor whiteColor]];
    [self.viewScroll addSubview:self.viewSelected];
    
    self.viewTag = [[UIView alloc] init];
    [self.viewScroll addSubview:self.viewTag];
    [self fillTag];
}

- (void)fillTagSelected {
    for (UIView *view in self.viewSelected.subviews) {
        [view removeFromSuperview];
    }
    if (self.arrayTagSelected.count == 0) {
        WKLabel *lbTips = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 0, SCREEN_WIDTH - 30, 50) content:@"选择或输入职位诱惑关键词" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [self.viewSelected addSubview:lbTips];
        [self.viewSelected setFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    }
    else {
        float widthForTag = 15;
        float heightForTag = 15;
        for (NSInteger index = 0; index < self.arrayTagSelected.count; index++) {
            NSString *tag = [self.arrayTagSelected objectAtIndex:index];
            WKLabel *lbTag = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForTag, heightForTag, 200, 30) content:[NSString stringWithFormat:@"%@×", tag] size:DEFAULTFONTSIZE color:nil];
            [lbTag setTextAlignment:NSTextAlignmentCenter];
            CGRect frameTag = lbTag.frame;
            frameTag.size.width = frameTag.size.width + 30;
            [lbTag setFrame:frameTag];
            
            if (VIEW_BX(lbTag) > SCREEN_WIDTH) {
                frameTag.origin.y = VIEW_BY(lbTag) + 10;
                frameTag.origin.x = 15;
            }
            [lbTag setFrame:frameTag];
            
            widthForTag = VIEW_BX(lbTag) + 10;
            heightForTag = VIEW_Y(lbTag);
            UIButton *btnTag = [[UIButton alloc] initWithFrame:lbTag.frame];
            [btnTag setTitle:lbTag.text forState:UIControlStateNormal];
            [btnTag setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btnTag.titleLabel setFont:DEFAULTFONT];
            [btnTag setBackgroundColor:GREENCOLOR];
            [btnTag.layer setCornerRadius:5];
            [btnTag addTarget:self action:@selector(tagRemove:) forControlEvents:UIControlEventTouchUpInside];
            [self.viewSelected addSubview:btnTag];
        }
        [self.viewSelected setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForTag + 45)];
    }
    CGRect frameTag = self.viewTag.frame;
    frameTag.origin.y = VIEW_BY(self.viewSelected);
    [self.viewTag setFrame:frameTag];
    
    [self.viewScroll setContentSize:CGSizeMake(SCREEN_WIDTH, VIEW_BY(self.viewTag))];
}

- (void)fillTag {
    for (UIView *view in self.viewTag.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewAdd = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    [viewAdd setBackgroundColor:[UIColor whiteColor]];
    [self.viewTag addSubview:viewAdd];
    
    self.txtAdd = [[UITextField alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH - 30 - 80, VIEW_H(viewAdd))];
    [self.txtAdd setFont:DEFAULTFONT];
    [self.txtAdd setPlaceholder:@"点击手动输入"];
    [self.txtAdd setDelegate:self];
    [self.txtAdd setReturnKeyType:UIReturnKeyDone];
    [viewAdd addSubview:self.txtAdd];
    
    UIButton *btnAdd = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 75, 10, 60, VIEW_H(viewAdd) - 20)];
    [btnAdd setTitle:@"添加" forState:UIControlStateNormal];
    [btnAdd setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnAdd setBackgroundColor:CPNAVBARCOLOR];
    [btnAdd.titleLabel setFont:DEFAULTFONT];
    [btnAdd.layer setCornerRadius:5];
    [btnAdd addTarget:self action:@selector(tagAdd) forControlEvents:UIControlEventTouchUpInside];
    [viewAdd addSubview:btnAdd];
    
    UIView *viewTopSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
    [viewTopSeparate setBackgroundColor:SEPARATECOLOR];
    [viewAdd addSubview:viewTopSeparate];
    
    UIView *viewBottomSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_H(viewAdd) - 1, SCREEN_WIDTH, 1)];
    [viewBottomSeparate setBackgroundColor:SEPARATECOLOR];
    [viewAdd addSubview:viewBottomSeparate];
    
    float widthForTag = 15;
    float heightForTag = VIEW_BY(viewAdd) + 15;
    for (NSInteger index = 0; index < self.arrayTag.count; index++) {
        NSString *tag = [self.arrayTag objectAtIndex:index];
        WKLabel *lbTag = [[WKLabel alloc] initWithFixedHeight:CGRectMake(widthForTag, heightForTag, 200, 30) content:tag size:DEFAULTFONTSIZE color:nil];
        [lbTag setTextAlignment:NSTextAlignmentCenter];
        CGRect frameTag = lbTag.frame;
        frameTag.size.width = frameTag.size.width + 30;
        [lbTag setFrame:frameTag];
        
        if (VIEW_BX(lbTag) > SCREEN_WIDTH) {
            frameTag.origin.y = VIEW_BY(lbTag) + 10;
            frameTag.origin.x = 15;
        }
        [lbTag setFrame:frameTag];
        
        widthForTag = VIEW_BX(lbTag) + 10;
        heightForTag = VIEW_Y(lbTag);
        UIButton *btnTag = [[UIButton alloc] initWithFrame:lbTag.frame];
        [btnTag setTitle:tag forState:UIControlStateNormal];
        [btnTag setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btnTag.titleLabel setFont:DEFAULTFONT];
        [btnTag setBackgroundColor:[UIColor whiteColor]];
        [btnTag.layer setMasksToBounds:YES];
        [btnTag.layer setBorderWidth:1];
        [btnTag.layer setBorderColor:[[UIColor grayColor] CGColor]];
        [btnTag.layer setCornerRadius:5];
        [btnTag addTarget:self action:@selector(tagClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewTag addSubview:btnTag];
        
        if ([self.arrayTagSelected containsObject:tag]) {
            [btnTag setBackgroundColor:[UIColor clearColor]];
            [btnTag setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        }
    }
    [self.viewTag setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForTag + 45)];
    [self fillTagSelected];
}

- (void)tagClick:(UIButton *)button {
    NSString *tag = button.titleLabel.text;
    if ([self.arrayTagSelected containsObject:tag]) {
        return;
    }
    [self tagCheck:tag];
}

- (void)tagCheck:(NSString *)tag {
    if ([self.arrayTagSelected containsObject:tag]) {
        [self.arrayTagSelected removeObject:tag];
    }
    else {
        if (self.arrayTagSelected.count >= 5) {
            [self.view makeToast:@"最多填写或者选择5个职位诱惑"];
            return;
        }
        [self.arrayTagSelected addObject:tag];
    }
    [self fillTag];
}

- (void)tagRemove:(UIButton *)button {
    NSString *tag = [button.titleLabel.text stringByReplacingOccurrencesOfString:@"×" withString:@""];
    [self tagCheck:tag];
}

- (void)tagAdd {
    [self.view endEditing:YES];
    NSString *tag = self.txtAdd.text;
    if (tag.length == 0) {
        [self.view makeToast:@"请输入职位诱惑"];
        return;
    }
    if (tag.length > 6) {
        [self.view makeToast:@"职位诱惑不能超过6个字符"];
        return;
    }
    if ([self.arrayTagSelected containsObject:tag]) {
        return;
    }
    [self tagCheck:tag];
    [self.txtAdd setText:@""];
}

- (void)saveClick {
    [self.delegate JobTagViewConfirm:[self.arrayTagSelected componentsJoinedByString:@"+"]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self tagAdd];
    return YES;
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
