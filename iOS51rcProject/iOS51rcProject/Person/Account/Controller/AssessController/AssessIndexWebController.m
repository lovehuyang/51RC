//
//  AssessIndexWebController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2019/3/6.
//  Copyright © 2019年 Jerry. All rights reserved.
//

#import "AssessIndexWebController.h"
#import <WebKit/WebKit.h>

@interface AssessIndexWebController ()<WKNavigationDelegate>
@property (strong, nonatomic) UIProgressView *progressView;// 加载进度条
@property (nonatomic ,strong) WKWebView *webView;// 加载模板的容器

@end

@implementation AssessIndexWebController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self createWebView];
     NSURL *url = [NSURL URLWithString:self.urlString];
    [self.webView loadRequest:[NSURLRequest requestWithURL:url]];
}


- (void)createWebView{
    
    self.webView = [[WKWebView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH , SCREEN_HEIGHT - 0)];
    [self.view addSubview:self.webView];
    
    self.webView.navigationDelegate = self;
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.scrollView.backgroundColor = [UIColor whiteColor];
    self.webView.allowsBackForwardNavigationGestures = YES;
    [self.webView setNeedsUpdateConstraints];
    
    _progressView = [[UIProgressView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH,2)];
    _progressView.tintColor =[UIColor redColor];
    _progressView.trackTintColor = [UIColor grayColor];
    [self.view addSubview:_progressView];
    
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew| NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - 进度条

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        self.progressView.progress = self.webView.estimatedProgress;
        if (self.progressView.progress == 1) {
            
            __weak typeof (self)weakSelf = self;
            [UIView animateWithDuration:0.25f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                weakSelf.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.4f);
            } completion:^(BOOL finished) {
                weakSelf.progressView.hidden = YES;
                
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.hidden = NO;
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.5f);
    [self.view bringSubviewToFront:self.progressView];
    
    
    NSString *requestString = webView.URL.absoluteString;
    if([requestString containsString:@"assess/mytest"]){
        [self.navigationController popViewControllerAnimated:YES];
        [webView stopLoading];
    }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    self.title = webView.title;
    if([self.title isEqualToString:@"测评"] || [self.title isEqualToString:@"恭喜，测评完成"]){
        [self.navigationController setNavigationBarHidden:YES];
        
    }else{
        [self.navigationController setNavigationBarHidden:NO];
    }
    
    [webView evaluateJavaScript:@"$('a:first').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
    
    [webView evaluateJavaScript:@"$('header').remove()" completionHandler:^(id _Nullable id, NSError * _Nullable error) {
        [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
    }];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}
//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
//}
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self.navigationController setNavigationBarHidden:NO animated:animated];
//}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

@end
