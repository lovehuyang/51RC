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
