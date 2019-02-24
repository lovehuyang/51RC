//
//  JobViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "JobViewController.h"
#import "CommonMacro.h"
#import "Common.h"
#import "WKLabel.h"
#import "ChatViewController.h"
#import "JobInfoViewController.h"
#import "CompanyInfoViewController.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "OneMinuteCVViewController.h"

@interface JobViewController ()<NetWebServiceRequestDelegate, CompanyInfoViewDelegate>

@property (nonatomic, strong) JobInfoViewController *jobInfoCtrl;
@property (nonatomic, strong) CompanyInfoViewController *companyInfoCtrl;
@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSDictionary *jobData;
@property (nonatomic, strong) NSDictionary *companyData;
@end

@implementation JobViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.navigationController.navigationBar setBarTintColor:NAVBARCOLOR];
    [self.btnAttention.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.btnShare.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [self.viewTitle.layer setCornerRadius:VIEW_H(self.viewTitle) / 2];
    [self.viewTitileBackground.layer setCornerRadius:VIEW_H(self.viewTitileBackground) / 2];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.view addGestureRecognizer:swipeLeft];
    
    [self getData];
}

- (void)swipe:(UISwipeGestureRecognizer *)swipe {
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        [self companyClickWithAnimated:YES];
    }
    else {
        [self jobClickWithAnimated:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    if (self.jobId.length > 0) {
        NSMutableDictionary *paramDict = [NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", self.jobId, @"jobId", nil];
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetJobInfoWithCpInfo" Params:paramDict viewController:self];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
    else {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCpInfo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", self.companyId, @"cpMainId", nil] viewController:self];
        [request setTag:1];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrJob = [Common getArrayFromXml:requestData tableName:@"Table"];
        self.jobData = (arrJob.count > 0 ? [arrJob objectAtIndex:0] : nil);
        self.companyData = [[Common getArrayFromXml:requestData tableName:@"Table1"] objectAtIndex:0];
        self.jobInfoCtrl = [[JobInfoViewController alloc] init];
        self.jobInfoCtrl.jobData = self.jobData;
        self.jobInfoCtrl.companyData = self.companyData;
        [self addChildViewController:self.jobInfoCtrl];
        [self.view addSubview:self.jobInfoCtrl.view];
        
        self.companyInfoCtrl = [[CompanyInfoViewController alloc] init];
        [self.companyInfoCtrl setDelegate:self];
        self.companyInfoCtrl.companyData = self.companyData;
        self.companyInfoCtrl.arrEnvironment = [Common getArrayFromXml:requestData tableName:@"Table2"];
        CGRect frameCompany = self.companyInfoCtrl.view.frame;
        frameCompany.origin.x = SCREEN_WIDTH;
        [self.companyInfoCtrl.view setFrame:frameCompany];
        [self addChildViewController:self.companyInfoCtrl];
        [self.view addSubview:self.companyInfoCtrl.view];
        
        if (self.companyId.length > 0) {
            WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(0, 0, 100, 20) content:@"企业信息" size:17 color:[UIColor whiteColor]];
            [lbTitle setFont:[UIFont boldSystemFontOfSize:17]];
            self.navigationItem.titleView = lbTitle;
            [self companyClickWithAnimated:NO];
        }
        else {
            [self jobClickWithAnimated:NO];
        }
    }
    else {
        if (self.btnAttention.tag == 1) {
            [self.companyInfoCtrl changeAttention];
        }
        else {
            [self.jobInfoCtrl changeAttention];
        }
        [self.btnAttention setTag:0];
        [self.btnAttention setImage:[UIImage imageNamed:@"img_favorite1.png"] forState:UIControlStateNormal];
        UIImageView *imgFavoriteAnimate = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_heart.png"]];
        imgFavoriteAnimate.center = self.view.superview.window.center;
        [imgFavoriteAnimate setFrame:CGRectMake((SCREEN_WIDTH - 100) / 2, SCREEN_HEIGHT, 100, 80)];
        [self.view.superview.window addSubview:imgFavoriteAnimate];
        [UIView animateWithDuration:0.6 animations:^{
            imgFavoriteAnimate.center = self.view.superview.window.center;
            [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate) - 30, VIEW_W(imgFavoriteAnimate), VIEW_H(imgFavoriteAnimate))];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                imgFavoriteAnimate.center = self.view.superview.window.center;
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:1 animations:^{
                    [imgFavoriteAnimate setFrame:CGRectMake(VIEW_X(imgFavoriteAnimate), VIEW_Y(imgFavoriteAnimate), SCREEN_HEIGHT, (SCREEN_HEIGHT * 4) / 5)];
                    imgFavoriteAnimate.center = self.view.superview.window.center;
                    [imgFavoriteAnimate setAlpha:0];
                } completion:^(BOOL finished) {
                    [imgFavoriteAnimate removeFromSuperview];
                }];
            }];
        }];
    }
}

- (IBAction)jobClick:(UIButton *)sender {
    [self jobClickWithAnimated:YES];
}

- (void)jobClickWithAnimated:(BOOL)animated {
    [self.jobInfoCtrl setTitleButton:self.btnAttention btnShare:self.btnShare];
    [UIView animateWithDuration:(animated ? 0.5 : 0) animations:^{
        CGRect frame = self.viewTitileBackground.frame;
        frame.origin.x = 1;
        [self.viewTitileBackground setFrame:frame];
        
        [self.btnJob setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.btnCompany setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        
        CGRect frameJob = self.jobInfoCtrl.view.frame;
        frameJob.origin.x = 0;
        [self.jobInfoCtrl.view setFrame:frameJob];
        CGRect frameCompany = self.companyInfoCtrl.view.frame;
        frameCompany.origin.x = SCREEN_WIDTH;
        [self.companyInfoCtrl.view setFrame:frameCompany];
    }];
}

- (void)jobClickWithJobId:(NSString *)jobId {
    self.jobId = jobId;
    [self.jobInfoCtrl getData:jobId];
    [self jobClickWithAnimated:YES];
}

- (IBAction)companyClick:(UIButton *)sender {
    [self companyClickWithAnimated:YES];
}

- (void)companyClickWithAnimated:(BOOL)animated {
    [self.companyInfoCtrl setTitleButton:self.btnAttention btnShare:self.btnShare];
    [UIView animateWithDuration:(animated ? 0.5 : 0) animations:^{
        CGRect frame = self.viewTitileBackground.frame;
        frame.origin.x = 91;
        [self.viewTitileBackground setFrame:frame];
        
        [self.btnJob setTitleColor:NAVBARCOLOR forState:UIControlStateNormal];
        [self.btnCompany setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        CGRect frameJob = self.jobInfoCtrl.view.frame;
        frameJob.origin.x = 0 - SCREEN_WIDTH;
        [self.jobInfoCtrl.view setFrame:frameJob];
        
        CGRect frameCompany = self.companyInfoCtrl.view.frame;
        frameCompany.origin.x = 0;
        [self.companyInfoCtrl.view setFrame:frameCompany];
    }];
}

- (IBAction)closeClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)shareClick:(UIButton *)sender {
    NSString *content, *url;
    if (sender.tag == 0) {
        content = [NSString stringWithFormat:@"%@正在招聘%@，速来围观", [self.jobData objectForKey:@"cpName"], [self.jobData objectForKey:@"Name"]];
        url = [NSString stringWithFormat:@"http://%@/personal/jb%@.html", [USER_DEFAULT objectForKey:@"subsite"], [self.jobData objectForKey:@"enjobid"]];
    }
    else {
        content = [NSString stringWithFormat:@"%@正在招聘，一定有你的菜儿哦", [self.companyData objectForKey:@"Name"]];
        url = [NSString stringWithFormat:@"http://%@/personal/cp%@.html", [USER_DEFAULT objectForKey:@"subsite"], [self.companyData objectForKey:@"secondId"]];
    }
    [Common share:@"真心推荐" content:content url:url imageUrl:[self.companyData objectForKey:@"LogoFile"]];
}

- (IBAction)attentionClick:(UIButton *)sender {
    if ([[USER_DEFAULT objectForKey:@"userType"] isEqualToString:@"2"]) {
        [self.view.window makeToast:@"您当前的角色为企业，请切换至求职者后方可操作"];
        return;
    }
    if (!PERSONLOGIN) {
        [self loginClick];
        return;
    }
    if (sender.tag == 0) {
        return;
    }

    NSDictionary *paramDict = [NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", nil];
    [AFNManager requestWithMethod:POST ParamDict:paramDict url:@"GetCvListApply" tableName:@"Table" successBlock:^(NSArray *requestData, NSDictionary *dataDict) {
        if(requestData.count == 0){
            OneMinuteCVViewController *oneCV = [[OneMinuteCVViewController alloc]init];
            oneCV.pageType = PageType_JobInfo;
            [self.navigationController pushViewController:oneCV animated:NO];
        }else{
            NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"Attention" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT valueForKey:@"paMainCode"], @"code", sender.titleLabel.text, @"attentionId", [NSString stringWithFormat:@"%ld", sender.tag], @"attentionType", nil] viewController:self];
            [request setTag:2];
            [request setDelegate:self];
            [request startAsynchronous];
            self.runningRequest = request;
        }
    } failureBlock:^(NSInteger errCode, NSString *msg) {
    
    }];
}

- (void)loginClick {
    UIViewController *loginCtrl = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"loginView"];
    [self presentViewController:loginCtrl animated:YES completion:nil];
}

- (void)jobClickFromCompany:(NSString *)jobId {
    self.navigationItem.titleView = self.viewTitle;
    [self jobClickWithJobId:jobId];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
