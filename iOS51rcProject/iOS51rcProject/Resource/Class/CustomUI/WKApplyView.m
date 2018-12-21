//
//  WKApplyView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/8/2.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKApplyView.h"
#import "WKLabel.h"
#import "Common.h"
#import "CommonMacro.h"
#import "WKButton.h"
#import "UIView+Toast.h"
#import "OnlineLab.h"

@implementation WKApplyView

- (id)initWithArrayCv:(NSArray *)arrayCv {
    self = [super init];
    if (self) {
        WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(30, 10, SCREEN_WIDTH - 60, 20) content:@"请选择一份简历来进行操作" size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
        [self addSubview:lbTitle];
        float heightForView = VIEW_BY(lbTitle) + 10;
        for (NSInteger i = 0; i < arrayCv.count; i++) {
            NSDictionary *data = [arrayCv objectAtIndex:i];
            UIButton *btnCv = [[UIButton alloc] initWithFrame:CGRectMake(0, heightForView, SCREEN_WIDTH, 46)];
            [btnCv setTitle:[data objectForKey:@"ID"] forState:UIControlStateNormal];
            [btnCv setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            [btnCv addTarget:self action:@selector(cvClick:) forControlEvents:UIControlEventTouchUpInside];
            [self addSubview:btnCv];
            heightForView = VIEW_BY(btnCv);
            
            UIImageView *imgApply = [[UIImageView alloc] initWithFrame:CGRectMake(30, 13, 20, 20)];
            if (i == 0) {
                self.cvMainId = [data objectForKey:@"ID"];
                [imgApply setImage:[UIImage imageNamed:@"img_check1.png"]];
            }
            else {
                [imgApply setImage:[UIImage imageNamed:@"img_check2.png"]];
            }
            [btnCv addSubview:imgApply];
            
            WKLabel *lbApply = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgApply) + 10, 13, 200, 20) content:[data objectForKey:@"Name"] size:DEFAULTFONTSIZE color:nil];
            [btnCv addSubview:lbApply];
        }
        [self setFrame:CGRectMake(0, 0, SCREEN_WIDTH, heightForView + 10)];
    }
    return self;
}

- (void)cvClick:(UIButton *)button {
    self.cvMainId = button.titleLabel.text;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            for (UIView *viewFromButton in view.subviews) {
                if ([viewFromButton isKindOfClass:[UIImageView class]]) {
                    if (button == view) {
                        [(UIImageView *)viewFromButton setImage:[UIImage imageNamed:@"img_check1.png"]];
                    }
                    else {
                        [(UIImageView *)viewFromButton setImage:[UIImage imageNamed:@"img_check2.png"]];
                    }
                    break;
                }
            }
        }
    }
}

- (void)show:(UIViewController *)viewController {
    WKPopView *applyPop = [[WKPopView alloc] initWithCustomView:self];
    [applyPop setDelegate:self];
    [applyPop showPopView:viewController];
}

- (void)WKPopViewConfirm:(WKPopView *)popView {
    [self.delegate WKApplyViewConfirm:self arrayJobId:self.cvMainId];
    [popView cancelClick];
}

- (id)initWithRecommendJob:(NSArray *)arrayJob {
    self.arrayJob = arrayJob;
    self.arrSelected = [[NSMutableArray alloc] init];
    self = [super initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    if (self) {
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 30, (SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT) * 0.8)];
        [view.layer setCornerRadius:VIEW_W(view) / 30];
        [view setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:view];
        
        UIView *viewTop = [[UIView alloc] init];
        [view addSubview:viewTop];
        
        UIImageView *imgSuccess = [[UIImageView alloc] initWithFrame:CGRectMake(0, 6, 38, 38)];
        [imgSuccess setImage:[UIImage imageNamed:@"job_applysuccess.png"]];
        [viewTop addSubview:imgSuccess];
        
        WKLabel *lbTitle = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(imgSuccess) + 10, 0, 300, 25) content:@"申请成功" size:BIGGERFONTSIZE color:nil];
        [viewTop addSubview:lbTitle];
        
        WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbTitle), VIEW_BY(lbTitle), 300, 25) content:@"申请该职位的人还申请了以下职位" size:DEFAULTFONTSIZE color:nil];
        [viewTop addSubview:lbDetail];
        
        [viewTop setFrame:CGRectMake(0, 20, VIEW_BX(lbDetail), VIEW_BY(lbDetail) + 20)];
        [viewTop setCenter:CGPointMake(view.center.x, viewTop.center.y)];
        
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewTop), VIEW_W(view), VIEW_H(view) - VIEW_BY(viewTop) - 60) style:UITableViewStylePlain];
        [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self.tableView setDelegate:self];
        [self.tableView setDataSource:self];
        [view addSubview:self.tableView];
        
        WKButton *btnOk = [[WKButton alloc] initWithFrame:CGRectMake(10, VIEW_BY(self.tableView) + 10, (VIEW_W(view) - 30) * 0.65, 40)];
        [btnOk setTitle:@"立即申请" forState:UIControlStateNormal];
        [btnOk addTarget:self action:@selector(applyClick) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnOk];
        
        WKButton *btnCancel = [[WKButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnOk) + 10, VIEW_Y(btnOk), (VIEW_W(view) - 30) * 0.35, 40)];
        [btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        [btnCancel setBackgroundColor:UIColorWithRGBA(182, 182, 182, 1)];
        [btnCancel addTarget:self action:@selector(cancelRecommend) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:btnCancel];
        
        [view setCenter:self.center];
    }
    return self;
}

- (void)showRecommend:(UIViewController *)viewController {
    [viewController.view.window addSubview:self];
}

- (void)cancelRecommend {
    [self removeFromSuperview];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return MIN(self.arrayJob.count, 5);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    NSDictionary *data = [self.arrayJob objectAtIndex:indexPath.row];
    UIButton *btnCheck = [[UIButton alloc] initWithFrame:CGRectMake(5, 15, 50, 50)];
    [btnCheck setTag:0];
    [btnCheck setTitle:[data objectForKey:@"ID"] forState:UIControlStateNormal];
    [btnCheck setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    [btnCheck addTarget:self action:@selector(checkClick:) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:btnCheck];
    
    UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 20, 20)];
    [imgCheck setImage:[UIImage imageNamed:@"img_checksmall2.png"]];
    [btnCheck addSubview:imgCheck];
    
    if ([self.arrSelected containsObject:[data objectForKey:@"ID"]]) {
        [btnCheck setTag:1];
        [imgCheck setImage:[UIImage imageNamed:@"img_checksmall1.png"]];
    }
    
    float maxWidth = VIEW_W(tableView) - VIEW_BX(btnCheck) - 20;
    WKLabel *lbJob = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_BX(btnCheck) + 5, VIEW_Y(btnCheck) - 5, maxWidth - 70, 20) content:[data objectForKey:@"JobName"] size:BIGGERFONTSIZE color:[UIColor blackColor]];
    [cell.contentView addSubview:lbJob];
    
    if ([[data objectForKey:@"IsOnline"] boolValue]) {
        
        OnlineLab *onlineLab = [[OnlineLab alloc]initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 30, 16)];
        [cell.contentView addSubview:onlineLab];
        
        // “聊”图标
//        UIImageView *imgOnline = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbJob) + 3, VIEW_Y(lbJob) + 2, 16, 16)];
//        [imgOnline setImage:[UIImage imageNamed:@"pa_chat.png"]];
//        [cell.contentView addSubview:imgOnline];
    }
    
    WKLabel *lbSalary = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_W(tableView) - 70, VIEW_Y(lbJob), 55, 20) content:[Common getSalary:[data objectForKey:@"dcSalaryID"] salaryMin:[data objectForKey:@"dcSalary"] salaryMax:[data objectForKey:@"dcSalaryMax"] negotiable:@""] size:DEFAULTFONTSIZE color:NAVBARCOLOR];
    [lbSalary setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbSalary];
    
    WKLabel *lbCompany = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbJob), VIEW_BY(lbJob), maxWidth - 65, 20) content:[data objectForKey:@"cpName"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbCompany];
    
    WKLabel *lbDate = [[WKLabel alloc] initWithFrame:CGRectMake(VIEW_W(tableView) - 65, VIEW_Y(lbCompany), 50, 20) content:[Common stringFromDateString:[data objectForKey:@"RefreshDate"] formatType:@"MM-dd"] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [lbDate setTextAlignment:NSTextAlignmentRight];
    [cell.contentView addSubview:lbDate];
    
    NSString *experience = [data objectForKey:@"ExperienceName"];
    if ([experience isEqualToString:@"不限"]) {
        experience = @"经验不限";
    }
    NSString *education = [data objectForKey:@"EducationName"];
    if ([education length] == 0) {
        education = @"学历不限";
    }
    WKLabel *lbDetail = [[WKLabel alloc] initWithFixedHeight:CGRectMake(VIEW_X(lbCompany), VIEW_BY(lbCompany), maxWidth, 20) content:[NSString stringWithFormat:@"%@ | %@ | %@", [data objectForKey:@"Region"], experience, education] size:DEFAULTFONTSIZE color:TEXTGRAYCOLOR];
    [cell.contentView addSubview:lbDetail];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(15, VIEW_BY(lbDetail) + 10, SCREEN_WIDTH - 30, 1)];
    [viewSeparate setBackgroundColor:SEPARATECOLOR];
    [cell.contentView addSubview:viewSeparate];
    
    [cell setFrame:CGRectMake(0, 0, SCREEN_WIDTH, VIEW_BY(viewSeparate))];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.frame.size.height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            [self checkClick:(UIButton *)view];
        }
    }
}

- (void)checkClick:(UIButton *)button {
    UIImageView *imgCheck;
    for (UIView *view in button.subviews) {
        if ([view isKindOfClass:[UIImageView class]]) {
            imgCheck = (UIImageView *)view;
        }
    }
    if (imgCheck == nil) {
        return;
    }
    NSString *jobId = button.titleLabel.text;
    if ([self.arrSelected containsObject:jobId]) {
        [self.arrSelected removeObject:jobId];
    }
    else {
        [self.arrSelected addObject:jobId];
    }
    [self.tableView reloadData];
}

- (void)applyClick {
    if (self.arrSelected.count == 0) {
        [self.window makeToast:@"请选择要申请的职位"];
        return;
    }
    [self.delegate WKApplyViewApplyBatch:self.arrSelected];
    [self removeFromSuperview];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
