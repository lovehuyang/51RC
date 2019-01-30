//
//  GuideViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/5/31.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "GuideViewController.h"
#import "CommonMacro.h"
#import "RoleViewController.h"

#define BACKGROUNDCOLOR UIColorWithRGBA(250, 109, 0, 1)

@interface GuideViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *viewGuideCp;
@property (nonatomic, strong) UILabel *lbSecond;
@property (nonatomic, strong) NSTimer *timerSkip;
@property int skipSecond;
@end

@implementation GuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.skipSecond = 5;
    [self.view setBackgroundColor:BACKGROUNDCOLOR];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH * 2, SCREEN_HEIGHT)];
    [self.scrollView setDelegate:self];
    [self.scrollView setPagingEnabled:YES];
    [self.scrollView setBounces:NO];
    [self.scrollView setShowsVerticalScrollIndicator:NO];
    [self.scrollView setShowsHorizontalScrollIndicator:NO];
    [self.scrollView setScrollEnabled:NO];
    [self.view addSubview:self.scrollView];
    
    UIView *viewGuidePa = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView addSubview:viewGuidePa];
    
    self.viewGuideCp = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView addSubview:self.viewGuideCp];
    
    UIImageView *imageBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - (SCREEN_WIDTH * 0.84) - 50, SCREEN_WIDTH, SCREEN_WIDTH * 0.84)];
    [imageBackground setImage:[UIImage imageNamed:@"pa_guidebg.png"]];
    [imageBackground setContentMode:UIViewContentModeScaleAspectFit];
    [imageBackground setAlpha:0];
    [viewGuidePa addSubview:imageBackground];
    
    CGRect afterRect1 = CGRectMake(0, SCREEN_HEIGHT * 0.05, SCREEN_WIDTH, SCREEN_HEIGHT * 0.15);
    CGRect beforeRect1 = afterRect1;
    beforeRect1.origin.y = 0 - beforeRect1.size.height;
    UIImageView *image1 = [[UIImageView alloc] initWithFrame:beforeRect1];
    [image1 setImage:[UIImage imageNamed:@"pa_guidepic4.png"]];
    [image1 setContentMode:UIViewContentModeScaleAspectFit];
    [viewGuidePa addSubview:image1];

    UIImageView *image2 = [[UIImageView alloc] initWithFrame:beforeRect1];
    [image2 setImage:[UIImage imageNamed:@"pa_guidepic5.png"]];
    [image2 setContentMode:UIViewContentModeScaleAspectFit];
    [viewGuidePa addSubview:image2];

    CGRect afterRect3 = CGRectMake(0, afterRect1.origin.y + afterRect1.size.height - 20, SCREEN_WIDTH, SCREEN_HEIGHT * 0.1);
    CGRect beforeRect3 = afterRect3;
    beforeRect3.origin.y = 0 - beforeRect3.size.height;
    UIImageView *image3 = [[UIImageView alloc] initWithFrame:beforeRect3];
    [image3 setImage:[UIImage imageNamed:@"pa_guidepic3.png"]];
    [image3 setContentMode:UIViewContentModeScaleAspectFit];
    [viewGuidePa addSubview:image3];
    
    CGRect afterRect4 = CGRectMake(0, afterRect3.origin.y + afterRect3.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - (afterRect3.origin.y + afterRect3.size.height));
    CGRect beforeRect4 = afterRect4;
    beforeRect4.origin.x = SCREEN_WIDTH + beforeRect4.size.width;
    UIImageView *image4 = [[UIImageView alloc] initWithFrame:beforeRect4];
    [image4 setImage:[UIImage imageNamed:@"pa_guidepic1.png"]];
    [image4 setContentMode:UIViewContentModeScaleAspectFill];
    [image4.layer setMasksToBounds:YES];
    [viewGuidePa addSubview:image4];

    CGRect afterRect5 = CGRectMake(0, afterRect3.origin.y + afterRect3.size.height + SCREEN_HEIGHT * 0.1, SCREEN_WIDTH, SCREEN_HEIGHT * 0.2);
    CGRect beforeRect5 = afterRect5;
    beforeRect5.origin.x = 0 - beforeRect5.size.width;
    UIImageView *image5 = [[UIImageView alloc] initWithFrame:beforeRect5];
    [image5 setImage:[UIImage imageNamed:@"pa_guidepic2.png"]];
    [image5 setContentMode:UIViewContentModeScaleAspectFill];
    [viewGuidePa addSubview:image5];
    
    [UIView animateWithDuration:0.5 animations:^{
        [imageBackground setAlpha:1];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            [image4 setFrame:afterRect4];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [image1 setFrame:afterRect1];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [image2 setFrame:afterRect1];
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.5 animations:^{
                        [image3 setFrame:afterRect3];
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.5 animations:^{
                            [image5 setFrame:afterRect5];
                        } completion:^(BOOL finished) {
                            [self.scrollView setScrollEnabled:YES];
                        }];
                    }];
                }];
            }];
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x >= SCREEN_WIDTH && self.viewGuideCp.subviews.count == 0) {
        UIImageView *imageBackground = [[UIImageView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - (SCREEN_WIDTH * 0.84) - 50, SCREEN_WIDTH, SCREEN_WIDTH * 0.84)];
        [imageBackground setImage:[UIImage imageNamed:@"cp_guidebg.png"]];
        [imageBackground setContentMode:UIViewContentModeScaleAspectFit];
        [imageBackground setAlpha:0];
        [self.viewGuideCp addSubview:imageBackground];
        
        CGRect afterRect1 = CGRectMake(0, SCREEN_HEIGHT * 0.1, SCREEN_WIDTH, SCREEN_HEIGHT * 0.2);
        CGRect beforeRect1 = afterRect1;
        beforeRect1.origin.y = 0 - beforeRect1.size.height;
        UIImageView *image1 = [[UIImageView alloc] initWithFrame:beforeRect1];
        [image1 setImage:[UIImage imageNamed:@"cp_guidepic1.png"]];
        [image1 setContentMode:UIViewContentModeScaleAspectFit];
        [self.viewGuideCp addSubview:image1];
        CGRect afterRect2 = CGRectMake(0, afterRect1.origin.y - 10, SCREEN_WIDTH, SCREEN_HEIGHT - afterRect1.origin.y);
        CGRect beforeRect2 = afterRect2;
        beforeRect2.origin.x = SCREEN_WIDTH + beforeRect2.size.width;
        UIImageView *image2 = [[UIImageView alloc] initWithFrame:beforeRect2];
        [image2 setImage:[UIImage imageNamed:@"cp_guidepic2.png"]];
        [image2 setContentMode:UIViewContentModeScaleAspectFill];
        [self.viewGuideCp addSubview:image2];
    
        [UIView animateWithDuration:0.5 animations:^{
            [imageBackground setAlpha:1];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.5 animations:^{
                [image2 setFrame:afterRect2];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.5 animations:^{
                    [image1 setFrame:afterRect1];
                } completion:^(BOOL finished) {
                    UIButton *btnSkip = [[UIButton alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 90, SCREEN_HEIGHT - 90, 50, 50)];
                    [btnSkip setBackgroundColor:UIColorWithRGBA(255, 217, 188, 1)];
                    [btnSkip.layer setCornerRadius:25];
                    [btnSkip.layer setBorderWidth:2];
                    [btnSkip.layer setBorderColor:[[UIColor redColor] CGColor]];
                    [btnSkip addTarget:self action:@selector(roleClick) forControlEvents:UIControlEventTouchUpInside];
                    
                    self.lbSecond = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 50, 15)];
                    [self.lbSecond setText:@"5s"];
                    [self.lbSecond setTextAlignment:NSTextAlignmentCenter];
                    [self.lbSecond setTextColor:BACKGROUNDCOLOR];
                    [self.lbSecond setFont:DEFAULTFONT];
                    [btnSkip addSubview:self.lbSecond];
                    
                    UILabel *lbSkip = [[UILabel alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.lbSecond), 50, 15)];
                    [lbSkip setText:@"跳过"];
                    [lbSkip setTextAlignment:NSTextAlignmentCenter];
                    [lbSkip setTextColor:BACKGROUNDCOLOR];
                    [lbSkip setFont:DEFAULTFONT];
                    [btnSkip addSubview:lbSkip];
                    
                    [self.view addSubview:btnSkip];
                    
                    self.timerSkip = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(intervalMethod) userInfo:nil repeats:YES];
                }];
            }];
        }];
    }
}

- (void)intervalMethod {
    self.skipSecond--;
    if (self.skipSecond == 0) {
        [self.timerSkip invalidate];
        self.timerSkip = nil;
        [self roleClick];
    }
    else {
        [self.lbSecond setText:[NSString stringWithFormat:@"%ds", self.skipSecond]];
    }
}

- (void)roleClick {
    RoleViewController *roleCtrl = [[RoleViewController alloc] init];
    [self presentViewController:roleCtrl animated:YES completion:nil];
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
