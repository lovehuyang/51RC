//
//  WKLoginView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKLoginView.h"
#import "CommonMacro.h"
#import "WKLabel.h"
#import "WKButton.h"

@implementation WKLoginView

- (id)initLoginView:(UIViewController *)viewController {
    self.viewController = viewController;
    self = [super initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - (NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT + TAB_BAR_HEIGHT))];
    if (self) {
        [self setBackgroundColor:SEPARATECOLOR];
        
        UIView *viewLogin = [[UIView alloc] init];
        [self addSubview:viewLogin];
        
        UIImageView *imgTips = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, VIEW_W(self) * 0.6, VIEW_W(self) * 0.6 * 0.86)];
        [imgTips setImage:[UIImage imageNamed:@"img_nodata.png"]];
        [imgTips setContentMode:UIViewContentModeScaleAspectFit];
        [imgTips setCenter:CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2 - 50)];
        [viewLogin addSubview:imgTips];
        
        WKLabel *lbTips = [[WKLabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(imgTips) + 15, VIEW_W(self), 20) content:[NSString stringWithFormat:@"登录之后才可以查看%@", @""] size:BIGGERFONTSIZE color:TEXTGRAYCOLOR];
        [lbTips setTextAlignment:NSTextAlignmentCenter];
        [viewLogin addSubview:lbTips];
        
        WKButton *btnLogin = [[WKButton alloc] initWithFrame:CGRectMake(50, VIEW_BY(lbTips) + 15, VIEW_W(self) - 100, 40)];
        [btnLogin setTitle:@"登录" forState:UIControlStateNormal];
        [btnLogin addTarget:self action:@selector(loginClick) forControlEvents:UIControlEventTouchUpInside];
        [viewLogin addSubview:btnLogin];
        
        [viewLogin setFrame:CGRectMake(0, 0, VIEW_W(self), VIEW_BY(btnLogin))];
        
        [viewLogin setCenter:CGPointMake(viewLogin.center.x, viewLogin.center.y)];
    }
    return self;
}

- (void)loginClick {
    UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self.viewController presentViewController:loginCtrl animated:YES completion:nil];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
