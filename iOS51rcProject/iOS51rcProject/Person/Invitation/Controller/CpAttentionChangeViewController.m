//
//  CpAttentionChangeViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/23.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "CpAttentionChangeViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "UIImageView+WebCache.h"
#import "WKLabel.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import "WKNavigationController.h"
#import "JobViewController.h"

@interface CpAttentionChangeViewController ()<NetWebServiceRequestDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) UIScrollView *scrollView;
@property float heightForScroll;
@end

@implementation CpAttentionChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:SEPARATECOLOR];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [self.view addSubview:self.scrollView];
    
    UIButton *btnCancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 30)];
    [btnCancel setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [btnCancel setTitle:@"取消关注" forState:UIControlStateNormal];
    [btnCancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:BIGGERFONT];
    [btnCancel addTarget:self action:@selector(cancelClick) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btnCancel];
    
    [self getData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"GetCpAttentionChange" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.cpMainId, @"cpMainId", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)cancelClick {
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定要取消关注该职位吗？" preferredStyle:UIAlertControllerStyleAlert];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"DeleteAttention" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainId", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.attentionId, @"id", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alertDelete animated:YES completion:nil];
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrCp = [Common getArrayFromXml:requestData tableName:@"Table"];
        if (arrCp.count == 0) {
            return;
        }
        [self fillCp:[arrCp objectAtIndex:0]];
        
        NSArray *arrJob = [Common getArrayFromXml:requestData tableName:@"Table1"];
        [self fillJob:arrJob];
        
        NSDictionary *dataEnvironment = [[Common getArrayFromXml:requestData tableName:@"Table2"] objectAtIndex:0];
        [self fillEnvironment:dataEnvironment];
        
        [self.scrollView setContentSize:CGSizeMake(SCREEN_WIDTH, self.heightForScroll)];
        
        if ([arrJob count] == 0 && [[dataEnvironment objectForKey:@"Column1"] integerValue] == 0) {
            UIView *viewNoData = [[UIView alloc] initWithFrame:CGRectMake(0, self.heightForScroll + 10, SCREEN_WIDTH, 300)];
            [viewNoData setBackgroundColor:[UIColor whiteColor]];
            [viewNoData setTag:NODATAVIEWTAG];
            [self.scrollView addSubview:viewNoData];
            
            UIImageView *imgNoData = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH - 150) / 2, 60, 150, 150 * 0.86)];
            [imgNoData setImage:[UIImage imageNamed:@"img_nodata.png"]];
            [imgNoData setContentMode:UIViewContentModeScaleAspectFit];
            [viewNoData addSubview:imgNoData];
            
            WKLabel *lbNoData = [[WKLabel alloc] initWithFixedSpacing:CGRectMake((SCREEN_WIDTH - 200) / 2, VIEW_BY(imgNoData) + 20, 200, 20) content:@"该企业没有最新动态~" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR spacing:7];
            [lbNoData setTextAlignment:NSTextAlignmentCenter];
            [lbNoData setCenter:CGPointMake(SCREEN_WIDTH / 2, lbNoData.center.y)];
            [viewNoData addSubview:lbNoData];
        }
    }
    else {
        [self.navigationController popViewControllerAnimated:YES];
        [self.navigationController.view makeToast:@"已取消关注"];
    }
}

- (void)fillEnvironment:(NSDictionary *)data {
    if ([[data objectForKey:@"Column1"] integerValue] == 0) {
        return;
    }
    UIButton *btnEnvironment = [[UIButton alloc] initWithFrame:CGRectMake(0, self.heightForScroll + 10, SCREEN_WIDTH, 50)];
    [btnEnvironment setBackgroundColor:[UIColor whiteColor]];
    [btnEnvironment addTarget:self action:@selector(companyClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnEnvironment];
    
    WKLabel *lbEnvironment = [[WKLabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH - 30, 20) content:@"" size:DEFAULTFONTSIZE color:nil];
    [btnEnvironment addSubview:lbEnvironment];
    
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc] initWithString:@"近期发布了新的环境照片，立即去查看~"];
    [attributeStr addAttribute:NSFontAttributeName value:DEFAULTFONT range:NSMakeRange(0, attributeStr.string.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:NAVBARCOLOR range:NSMakeRange(12,6)];
    [lbEnvironment setAttributedText:attributeStr];
    
}

- (void)fillJob:(NSArray *)arrJob {
    if (arrJob.count == 0) {
        return;
    }
    CGRect frameViewJob = CGRectMake(0, self.heightForScroll + 10, SCREEN_WIDTH, 500);
    UIView *viewJob = [[UIView alloc] initWithFrame:frameViewJob];
    [viewJob setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewJob];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, 15, 300, 20) content:@"近期发布的职位" size:BIGGERFONTSIZE color:TEXTGRAYCOLOR];
    [viewJob addSubview:lbTitle];
    float heightForViewJob = VIEW_BY(lbTitle) + 5;
    
    float maxWidth = SCREEN_WIDTH - 30 - 80;
    for (NSDictionary *dataJob in arrJob) {
        WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(15, heightForViewJob + 10, maxWidth, 20) content:[dataJob objectForKey:@"Name"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
        [viewJob addSubview:lbJob];
        
        WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 80, VIEW_Y(lbJob), 65, 20) content:[Common getSalary:[dataJob objectForKey:@"dcSalaryID"] salaryMin:[dataJob objectForKey:@"Salary"] salaryMax:[dataJob objectForKey:@"SalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
        [lbSalary setTextAlignment:NSTextAlignmentRight];
        [viewJob addSubview:lbSalary];
        
        NSString *experience = [dataJob objectForKey:@"Experience"];
        if ([experience isEqualToString:@"不限"]) {
            experience = @"经验不限";
        }
        NSString *education = [dataJob objectForKey:@"Education"];
        if ([education length] == 0) {
            education = @"学历不限";
        }
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob) + 5, maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@ | %@", [dataJob objectForKey:@"Region"], experience, education, [dataJob objectForKey:@"NeedNuberDesc"]] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [viewJob addSubview:lbDetail];
        
        WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - 65, VIEW_Y(lbDetail), 50, 20) content:[Common stringFromDateString:[dataJob objectForKey:@"AddDate"] formatType:@"MM-dd"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [lbDate setTextAlignment:NSTextAlignmentRight];
        [viewJob addSubview:lbDate];
        
        UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
        [viewSeparate setBackgroundColor:SEPARATECOLOR];
        [viewJob addSubview:viewSeparate];
        
        UIButton *btnJob = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_Y(lbJob), SCREEN_WIDTH, VIEW_BY(viewSeparate) - VIEW_Y(lbJob))];
        [btnJob setBackgroundColor:[UIColor clearColor]];
        [btnJob setTitle:[dataJob objectForKey:@"ID"] forState:UIControlStateNormal];
        [btnJob setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnJob addTarget:self action:@selector(jobClick:) forControlEvents:UIControlEventTouchUpInside];
        [viewJob addSubview:btnJob];
        
        heightForViewJob = VIEW_BY(btnJob);
    }
    frameViewJob.size.height = heightForViewJob - 1;
    [viewJob setFrame:frameViewJob];
    
    self.heightForScroll = VIEW_BY(viewJob);
}

- (void)fillCp:(NSDictionary *)dataCp {
    UIView *viewCp = [[UIView alloc] init];
    [viewCp setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewCp];
    
    UIImageView *imgLogo = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 50, 50)];
    [imgLogo sd_setImageWithURL:[NSURL URLWithString:[dataCp objectForKey:@"LogoUrl"]] placeholderImage:[UIImage imageNamed:@"img_defaultlogo.png"]];
    [viewCp addSubview:imgLogo];
    
    float maxWidth = SCREEN_WIDTH - VIEW_BX(imgLogo) - 30;
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgLogo) + 15, VIEW_Y(imgLogo) - 5, maxWidth, 25) content:[dataCp objectForKey:@"Name"] size:BIGGERFONTSIZE color:nil];
    [viewCp addSubview:lbCompany];
    
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [dataCp objectForKey:@"DcCompanyKindName"], [dataCp objectForKey:@"CompanySizeName"], [dataCp objectForKey:@"Industry"]] size:DEFAULTFONTSIZE color:nil spacing:0];
    [viewCp addSubview:lbDetail];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbDetail), maxWidth, 20) content:[NSString stringWithFormat:@"%@关注", [Common stringFromDateString:[dataCp objectForKey:@"AddDate"] formatType:@"MM-dd"]] size:DEFAULTFONTSIZE color:nil];
    [lbDate setTextAlignment:NSTextAlignmentCenter];
    [viewCp addSubview:lbDate];
    [viewCp setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(lbDate) + 10)];
    UIButton *btnCp = [[UIButton alloc] initWithFrame:viewCp.frame];
    [btnCp setBackgroundColor:[UIColor clearColor]];
    [btnCp addTarget:self action:@selector(companyClick) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:btnCp];
    self.heightForScroll = VIEW_BY(viewCp);
}

- (void)companyClick {
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.companyId = self.cpMainId;
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)jobClick:(UIButton *)button {
    WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
    JobViewController *jobCtrl = jobNav.viewControllers[0];
    jobCtrl.jobId = button.titleLabel.text;
    [self presentViewController:jobNav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
