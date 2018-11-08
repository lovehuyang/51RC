//
//  WKNavigationController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/6.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKNavigationController.h"
#import "CommonMacro.h"

@interface WKNavigationController ()<UINavigationControllerDelegate>

@end

@implementation WKNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"1"]) {
        [self.navigationBar setBarTintColor:NAVBARCOLOR];
    }
    else {
        [self.navigationBar setBarTintColor:CPNAVBARCOLOR];
    }
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    self.delegate = self;
    
    // 添加页面右滑返回手势
    __weak typeof(self) weakself = self;
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = (id)weakself;
    }
}

#pragma mark - UIGestureRecognizerDelegate 右滑返回手势
//这个方法是在手势将要激活前调用：返回YES允许右滑手势的激活，返回NO不允许右滑手势的激活
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        //屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起死机问题
        if (self.viewControllers.count < 2 ||
            self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    //这里就是非右滑手势调用的方法啦，统一允许激活
    return YES;
}
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.wantClose) {
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_close.png"] style:UIBarButtonItemStyleDone target:self action:@selector(dismissModalViewControllerAnimated:)];
        viewController.navigationItem.leftBarButtonItem = leftBarItem;
    }
    else if (navigationController.viewControllers.count > 1) {
        UIBarButtonItem *leftBarItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"img_back"] style:UIBarButtonItemStyleDone target:self action:@selector(popViewControllerAnimated:)];
        viewController.navigationItem.leftBarButtonItem = leftBarItem;
    }
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [viewController setHidesBottomBarWhenPushed:true];
    [super pushViewController:viewController animated:animated];
}

@end
