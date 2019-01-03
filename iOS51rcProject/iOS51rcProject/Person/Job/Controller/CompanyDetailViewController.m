//
//  CompanyDetailViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/29.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CompanyDetailViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "UIImageView+WebCache.h"

@interface CompanyDetailViewController ()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIScrollView *scrollPhoto;
@property (nonatomic, strong) UIButton *btnImagePrev;
@property (nonatomic, strong) UIButton *btnImageNext;
@end

@implementation CompanyDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    [self.scrollView setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.scrollView];
    [self fillEnvironment];
    [self fillBrief];
}

- (void)fillBrief {
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(self.scrollPhoto), SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    if (self.arrEnvironment.count > 0) {
        [self.scrollView addSubview:viewSeparate];
    }
    WKLabel *lbBrief = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, VIEW_BY(viewSeparate) + 15, SCREEN_WIDTH - 30, 20) content:[self.companyData objectForKey:@"Brief"] size:DEFAULTFONTSIZE color:nil spacing:7];
    [self.scrollView addSubview:lbBrief];
    
    [self.scrollView setContentSize:CGSizeMake(VIEW_W(self.scrollView), VIEW_BY(lbBrief) + 15)];
}

- (void)fillEnvironment {
    if (self.arrEnvironment.count == 0) {
        return;
    }
    self.scrollPhoto = [[UIScrollView alloc] init];
    [self.scrollPhoto setBounces:NO];
    [self.scrollPhoto setShowsHorizontalScrollIndicator:NO];
    [self.scrollPhoto setShowsVerticalScrollIndicator:NO];
    [self.scrollPhoto setPagingEnabled:YES];
    [self.scrollPhoto setDelegate:self];
    [self.scrollView addSubview:self.scrollPhoto];
    
    float imgWidth = SCREEN_WIDTH - 60;
    float imgHeight = (SCREEN_WIDTH - 60) * (320.00f / 620.00f);
    float scrollHeight = imgHeight;
    for (NSInteger index = 0; index < self.arrEnvironment.count; index++) {
        NSDictionary *data = [self.arrEnvironment objectAtIndex:index];
        UIView *viewEnvironment = [[UIView alloc] init];
        [self.scrollPhoto addSubview:viewEnvironment];
        UIImageView *imgEnvironment = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imgWidth, imgHeight)];
        [imgEnvironment sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://down.51rc.com/ImageFolder/operational/Environment/%@", [data objectForKey:@"ImgFile"]]]];
        [imgEnvironment setBackgroundColor:[UIColor redColor]];
        [viewEnvironment addSubview:imgEnvironment];
        WKLabel *lbDescription = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(0, VIEW_BY(imgEnvironment) + 15, imgWidth, 20) content:[NSString stringWithFormat:@"%@（第%ld张，共%ld张）", [data objectForKey:@"Description"], (index + 1), self.arrEnvironment.count] size:DEFAULTFONTSIZE color:nil spacing:0];
        [lbDescription setCenter:CGPointMake(imgEnvironment.center.x, lbDescription.center.y)];
        
        NSMutableAttributedString *attrString = [lbDescription.attributedText mutableCopy];
        NSRange range = NSMakeRange([[data objectForKey:@"Description"] length], attrString.string.length - [[data objectForKey:@"Description"] length]);
        [attrString addAttribute:NSForegroundColorAttributeName value:TEXTGRAYCOLOR range:range];
        [attrString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:range];
        [lbDescription setAttributedText:attrString];
        
        [viewEnvironment addSubview:lbDescription];
        [viewEnvironment setFrame:CGRectMake(imgWidth * index, 0, VIEW_W(self.scrollPhoto), VIEW_BY(lbDescription) + 15)];
        scrollHeight = MAX(scrollHeight, VIEW_BY(viewEnvironment));
    }
    [self.scrollPhoto setFrame:CGRectMake(30, 20, imgWidth, scrollHeight)];
    [self.scrollPhoto setContentSize:CGSizeMake(VIEW_W(self.scrollPhoto) * self.arrEnvironment.count, VIEW_H(self.scrollPhoto))];
    //图片按钮
    self.btnImagePrev = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_Y(self.scrollPhoto), 30, imgHeight)];
    [self.btnImagePrev setTag:0];
    [self.btnImagePrev setImage:[UIImage imageNamed:@"img_prev2.png"] forState:UIControlStateNormal];
    [self.btnImagePrev.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnImagePrev setImageEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [self.btnImagePrev addTarget:self action:@selector(imageGo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.btnImagePrev];
    
    self.btnImageNext = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(self.scrollView) - 30, VIEW_Y(self.scrollPhoto), 30, imgHeight)];
    if (self.arrEnvironment.count == 1) {
        [self.btnImageNext setImage:[UIImage imageNamed:@"img_next2.png"] forState:UIControlStateNormal];
        [self.btnImageNext setTag:0];
    }
    else {
        [self.btnImageNext setImage:[UIImage imageNamed:@"img_next1.png"] forState:UIControlStateNormal];
        [self.btnImageNext setTag:2];
    }
    [self.btnImageNext.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnImageNext setImageEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 7)];
    [self.btnImageNext addTarget:self action:@selector(imageGo:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.btnImageNext];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.x == 0) {
        [self.btnImagePrev setImage:[UIImage imageNamed:@"img_prev2.png"] forState:UIControlStateNormal];
        [self.btnImagePrev setTag:0];
    }
    else if (scrollView.contentOffset.x == VIEW_W(scrollView) * (self.arrEnvironment.count - 1)) {
        [self.btnImageNext setImage:[UIImage imageNamed:@"img_next2.png"] forState:UIControlStateNormal];
        [self.btnImageNext setTag:0];
    }
    else {
        [self.btnImagePrev setImage:[UIImage imageNamed:@"img_prev1.png"] forState:UIControlStateNormal];
        [self.btnImagePrev setTag:1];
        
        [self.btnImageNext setImage:[UIImage imageNamed:@"img_next1.png"] forState:UIControlStateNormal];
        [self.btnImageNext setTag:2];
    }
}

- (void)imageGo:(UIButton *)button {
    if (button.tag == 0) {
        return;
    }
    int page = self.scrollPhoto.contentOffset.x / VIEW_W(self.scrollPhoto);
    if (button.tag == 1) {
        page = page - 1;
    }
    else {
        page = page + 1;
    }
    [self.scrollPhoto setContentOffset:CGPointMake(VIEW_W(self.scrollPhoto) * page, 0) animated:YES];
}

- (void)adjustHeight:(float)height {
    CGRect frameScroll = self.scrollView.frame;
    frameScroll.size.height = height;
    [self.scrollView setFrame:frameScroll];
    
    CGRect frameView = self.view.frame;
    frameView.size.height = height;
    [self.view setFrame:frameView];
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
