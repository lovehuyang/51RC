//
//  MBProgressHUD+Gif.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/11/5.
//  Copyright © 2018年 Jerry. All rights reserved.
//

#import "MBProgressHUD+Gif.h"
#import <WebKit/WebKit.h>

#define LOAD_W 100
#define LOAD_H 100
#define GIF_IMAGE_NAME @"loading"


static UIImageView *webGifImageView;
static WKWebView *webGifWebView;
static MBProgressHUD *utilHUD;

@implementation MBProgressHUD (Gif)
+ (instancetype)showGifHUD:(UIView *)view animated:(BOOL)animated
{
    if (!webGifImageView)
    {
        webGifImageView = [[UIImageView alloc] init];
        webGifImageView.layer.cornerRadius = 10;
        webGifImageView.clipsToBounds = YES;
        webGifImageView.image = [self getImageBySize:CGSizeMake(LOAD_W, LOAD_H)];
        
        webGifWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, LOAD_W, LOAD_H)];
        webGifWebView.backgroundColor = [UIColor redColor];
//        [webGifImageView addSubview:webGifWebView];
    }
    NSData *gifData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:GIF_IMAGE_NAME ofType:@"gif"]];
    [webGifWebView loadData:gifData MIMEType:@"image/gif" characterEncodingName:@"UTF8" baseURL:[NSURL URLWithString:@""]];
    webGifImageView.alpha = 0;
    if (utilHUD)
    {
        [utilHUD hideGifHUD:YES];
    }
    utilHUD = [MBProgressHUD showHUDAddedTo:view animated:YES];
    utilHUD.bezelView.backgroundColor = [UIColor clearColor];
//    utilHUD.
    utilHUD.customView = webGifImageView;
    utilHUD.subviews[1].subviews[0].subviews[1].backgroundColor = [UIColor clearColor];
    utilHUD.mode = MBProgressHUDModeCustomView;
    [utilHUD showAnimated:YES];
    
    NSTimeInterval duration = 0;
    if (animated)
    {
        duration = 0.15;
    }
    [UIView animateWithDuration:duration animations:^{
        webGifImageView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    return utilHUD;
}

- (void)hideGifHUD:(BOOL)animated
{
    NSTimeInterval duration = 0;
    if (animated)
    {
        duration = 0.1;
    }
    [UIView animateWithDuration:duration animations:^{
        webGifImageView.alpha = 0;
    } completion:^(BOOL finished) {
        [webGifImageView stopAnimating];
        [webGifImageView removeFromSuperview];
        [utilHUD hideAnimated:YES];
        utilHUD = nil;
    }];
}

/**
 *  建议Appdelegate初始化调用，可减少初次调用的显示时间
 */
+ (void)initAnimationGif{
    
    webGifImageView = [[UIImageView alloc] init];
    webGifImageView.layer.cornerRadius = 15;
    webGifImageView.clipsToBounds = YES;
    webGifImageView.image = [self getImageBySize:CGSizeMake(LOAD_W, LOAD_H)];

    webGifWebView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, LOAD_W, LOAD_H)];
    webGifWebView.backgroundColor = [UIColor redColor];
    [webGifImageView addSubview:webGifWebView];
    NSData *gifData = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:GIF_IMAGE_NAME ofType:@"gif"]];
    [webGifWebView loadData:gifData MIMEType:@"image/gif" characterEncodingName:@"UTF8" baseURL:[NSURL URLWithString:@""]];
}

+ (UIImage *)getImageBySize:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, 0, [UIScreen mainScreen].scale);
    //图片颜色
    [[UIColor  clearColor] set];
    UIRectFill(CGRectMake(0, 0, size.width, size.height));
    return UIGraphicsGetImageFromCurrentImageContext();
}
@end
