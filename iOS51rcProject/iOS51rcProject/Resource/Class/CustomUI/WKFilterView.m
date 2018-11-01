//
//  WKFilterView.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/7/21.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "WKFilterView.h"
#import "CommonMacro.h"
#import "WKLabel.h"

@implementation WKFilterView

- (id)initWithButton:(UIButton *)button {
    self.filterType = (WKFilterType)button.tag;
    UIWindow * window = [[[UIApplication sharedApplication] delegate] window];
    CGRect rectButton = [button convertRect: button.bounds toView:window];
    self = [super initWithFrame:CGRectMake(0, rectButton.origin.y + rectButton.size.height, SCREEN_WIDTH, SCREEN_HEIGHT - (rectButton.origin.y + rectButton.size.height))];
    
    if (self) {
        [self setTag:button.tag];
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
        [self.layer setMasksToBounds:YES];
        [self filterSet];
    }
    return self;
}

- (void)showFilterView:(UIViewController *)viewController {
    [viewController.view.window addSubview:self];
    [self setAlpha:0];
    CGRect rectView = self.frame;
    [self setFrame:CGRectMake(rectView.origin.x, rectView.origin.y, rectView.size.width, 0)];
    [UIView animateWithDuration:0.2 animations:^{
        [self setAlpha:1];
        [self setFrame:rectView];
    }];
    if (self.filterType == WKFilterTypeOther) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableViewLeft selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
        if ([self.tableViewLeft.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
            [self.tableViewLeft.delegate tableView:self.tableViewLeft didSelectRowAtIndexPath:indexPath];
        }
    }
}

- (void)filterSet {
    UIButton *btnTap = [[UIButton alloc] initWithFrame:self.frame];
    [btnTap addTarget:self action:@selector(backgroundClick) forControlEvents:UIControlEventTouchUpInside];
    [btnTap setBackgroundColor:[UIColor clearColor]];
    [self addSubview:btnTap];
    
    if (self.filterType == WKFilterTypeOther) {
        self.arrayOther = @[@"在线状态", @"学历要求", @"工作年限", @"工作性质", @"公司规模", @"福利待遇"];
        [self clearFilter];
        self.tableViewLeft = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 150, self.frame.size.height - (IS_IPHONE_5 ? 70 : 150)) style:UITableViewStylePlain];
        [self.tableViewLeft setBackgroundColor:SEPARATECOLOR];
        [self.tableViewLeft setTag:1];
        [self.tableViewLeft setDataSource:self];
        [self.tableViewLeft setDelegate:self];
        [self.tableViewLeft setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:self.tableViewLeft];
        
        self.tableViewRight = [[UITableView alloc] initWithFrame:CGRectMake(VIEW_BX(self.tableViewLeft), 0, self.frame.size.width - VIEW_W(self.tableViewLeft), VIEW_H(self.tableViewLeft)) style:UITableViewStylePlain];
        [self.tableViewRight setTag:2];
        [self.tableViewRight setDataSource:self];
        [self.tableViewRight setDelegate:self];
        [self.tableViewRight setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        [self addSubview:self.tableViewRight];
        
        UIView *viewBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.tableViewLeft), VIEW_W(self), 60)];
        [viewBottom setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:viewBottom];
        
        UIButton *btnClear = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 150, 40)];
        [btnClear setTitle:@"清空条件" forState:UIControlStateNormal];
        [btnClear setTitleColor:TEXTGRAYCOLOR forState:UIControlStateNormal];
        [btnClear.titleLabel setFont:DEFAULTFONT];
        [btnClear.layer setCornerRadius:5];
        [btnClear.layer setBorderColor:[SEPARATECOLOR CGColor]];
        [btnClear.layer setBorderWidth:1];
        [btnClear addTarget:self action:@selector(clearFilter) forControlEvents:UIControlEventTouchUpInside];
        [viewBottom addSubview:btnClear];
        
        UIButton *btnConfirm = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnClear) + 20, VIEW_Y(btnClear), VIEW_W(self) - VIEW_BX(btnClear) - 40, 40)];
        [btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        [btnConfirm setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btnConfirm setBackgroundColor:NAVBARCOLOR];
        [btnConfirm.titleLabel setFont:DEFAULTFONT];
        [btnConfirm.layer setCornerRadius:5];
        [btnConfirm addTarget:self action:@selector(confirmFilter) forControlEvents:UIControlEventTouchUpInside];
        [viewBottom addSubview:btnConfirm];
    }
    else {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 100) collectionViewLayout:layout];
        [collectionView setBackgroundColor:[UIColor clearColor]];
        [collectionView setTag:self.filterType];
        [collectionView setDataSource:self];
        [collectionView setDelegate:self];
        [self addSubview:collectionView];
        
        [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        
        UITapGestureRecognizer *backgroundTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundClick)];
        [backgroundTap setDelegate:self];
        [collectionView addGestureRecognizer:backgroundTap];
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrayData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    cell.backgroundColor = [UIColor whiteColor];
    cell.layer.borderColor = [SEPARATECOLOR CGColor];
    cell.layer.borderWidth = 0.5;
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    if ([[data objectForKey:@"return"] isEqualToString:@"1"]) {
        WKLabel *lbReturn = [[WKLabel alloc] initWithFixedHeight:CGRectMake(50, 0, SCREEN_WIDTH, 40) content:@"返回上一级" size:DEFAULTFONTSIZE color:nil];
        [cell.contentView addSubview:lbReturn];
        UIImageView *imgReturn = [[UIImageView alloc] initWithFrame:CGRectMake(VIEW_BX(lbReturn) + 5, 0, 6, 40)];
        [imgReturn setImage:[UIImage imageNamed:@"img_arrowright.png"]];
        [imgReturn setContentMode:UIViewContentModeScaleAspectFit];
        [cell.contentView addSubview:imgReturn];
        return cell;
    }
    if ([[data objectForKey:@"blank"] isEqualToString:@"1"]) {
        return cell;
    }
    WKLabel *lbItem = [[WKLabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height) content:([[data objectForKey:@"Description"] length] > 0 ? [data objectForKey:@"Description"] : [data objectForKey:@"Name"]) size:DEFAULTFONTSIZE color:nil];
    [lbItem setTextAlignment:NSTextAlignmentCenter];
    [cell.contentView addSubview:lbItem];
    
    if ([[data objectForKey:@"Selected"] isEqualToString:@"1"]) {
        [lbItem setTextColor:NAVBARCOLOR];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    if ([[data objectForKey:@"return"] isEqualToString:@"1"]) {
        return CGSizeMake(SCREEN_WIDTH, 40);
    }
    else {
        return CGSizeMake(SCREEN_WIDTH / 2, 40);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
    [self.delegate WKFilterItemClick:self.filterType selectedItem:data];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView.tag == 1) {
        return self.arrayOther.count;
    }
    else {
        return self.arrayData.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    [cell setBackgroundColor:[UIColor clearColor]];
    WKLabel *lbTitle = [[WKLabel alloc] initWithFrame:CGRectMake(20, 0, tableView.frame.size.width - 20, 50) content:@"" size:DEFAULTFONTSIZE color:nil];
    [cell.contentView addSubview:lbTitle];
    
    if (tableView.tag == 1) {
        [lbTitle setText:[self.arrayOther objectAtIndex:indexPath.row]];
    }
    else {
        NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
        NSString *selId = [self.arraySelect objectAtIndex:self.selectRow];
        [lbTitle setText:[data objectForKey:@"value"]];
        if (self.selectRow == 5) {
            UIImageView *imgCheck = [[UIImageView alloc] initWithFrame:CGRectMake(20, 15, 20, 20)];
            [imgCheck setImage:[UIImage imageNamed:@"img_check2.png"]];
            [imgCheck setContentMode:UIViewContentModeScaleAspectFit];
            [cell.contentView addSubview:imgCheck];
            
            [lbTitle setFrame:CGRectMake(VIEW_BX(imgCheck) + 5, VIEW_Y(lbTitle), VIEW_W(lbTitle), VIEW_H(lbTitle))];
            
            NSArray *arrayWelFareId = [selId componentsSeparatedByString:@","];
            if ([arrayWelFareId containsObject:[data objectForKey:@"id"]]) {
                [lbTitle setTextColor:NAVBARCOLOR];
                [imgCheck setImage:[UIImage imageNamed:@"img_check1.png"]];
            }
        }
        else if ([selId isEqualToString:[data objectForKey:@"id"]]) {
            [lbTitle setTextColor:NAVBARCOLOR];
        }
    }
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(10, 49, tableView.frame.size.width - 20, 1)];
    [viewSeparate setBackgroundColor:UIColorWithRGBA(232, 232, 232, 1)];
    [cell.contentView addSubview:viewSeparate];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == 1) {
        for (UITableViewCell *cell in tableView.visibleCells) {
            if (cell == [tableView cellForRowAtIndexPath:indexPath]) {
                [cell setBackgroundColor:[UIColor whiteColor]];
            }
            else {
                [cell setBackgroundColor:[UIColor clearColor]];
            }
        }
        self.selectRow = indexPath.row;
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setBackgroundColor:[UIColor whiteColor]];
        [self setupFilterArray:indexPath.row];
        [self.tableViewRight reloadData];
    }
    else {
        NSDictionary *data = [self.arrayData objectAtIndex:indexPath.row];
        if (self.selectRow == 5) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            WKLabel *lbTitle = [cell.contentView.subviews objectAtIndex:0];
            UIImageView *imgCheck = [cell.contentView.subviews objectAtIndex:1];
            NSMutableArray *arrayWelFareId = [[[self.arraySelect objectAtIndex:self.selectRow] componentsSeparatedByString:@","] mutableCopy];
            if ([[self.arraySelect objectAtIndex:self.selectRow] length] == 0) {
                arrayWelFareId = [[NSMutableArray alloc] init];
            }
            if ([arrayWelFareId containsObject:[data objectForKey:@"id"]]) {
                [lbTitle setTextColor:[UIColor blackColor]];
                [imgCheck setImage:[UIImage imageNamed:@"img_check2.png"]];
                [arrayWelFareId removeObject:[data objectForKey:@"id"]];
            }
            else {
                [lbTitle setTextColor:NAVBARCOLOR];
                [imgCheck setImage:[UIImage imageNamed:@"img_check1.png"]];
                [arrayWelFareId addObject:[data objectForKey:@"id"]];
            }
            [self.arraySelect replaceObjectAtIndex:self.selectRow withObject:[arrayWelFareId componentsJoinedByString:@","]];
            //修改左侧内容
            UITableViewCell *cellLeft = [self.tableViewLeft cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow inSection:0]];
            WKLabel *lbOther = [cellLeft.contentView.subviews objectAtIndex:0];
            NSMutableArray *arrayWelFare = [[NSMutableArray alloc] init];
            for (NSDictionary *data in self.arrayData) {
                if ([arrayWelFareId containsObject:[data objectForKey:@"id"]]) {
                    [arrayWelFare addObject:[data objectForKey:@"value"]];
                }
            }
            [lbOther setText:[arrayWelFare componentsJoinedByString:@"、"]];
            
            if ([arrayWelFareId count] == 0) {
                [lbOther setText:[self.arrayOther objectAtIndex:self.selectRow]];
            }
        }
        else {
            for (UITableViewCell *cell in tableView.visibleCells) {
                WKLabel *lbTitle = [cell.contentView.subviews objectAtIndex:0];
                if (cell == [tableView cellForRowAtIndexPath:indexPath]) {
                    [lbTitle setTextColor:NAVBARCOLOR];
                    [self.arraySelect replaceObjectAtIndex:self.selectRow withObject:[data objectForKey:@"id"]];
                    //修改左侧内容
                    UITableViewCell *cell = [self.tableViewLeft cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.selectRow inSection:0]];
                    WKLabel *lbOther = [cell.contentView.subviews objectAtIndex:0];
                    if ([[data objectForKey:@"value"] isEqualToString:@"不限"]) {
                        [lbOther setText:[self.arrayOther objectAtIndex:self.selectRow]];
                    }
                    else {
                        [lbOther setText:[data objectForKey:@"value"]];
                    }
                }
                else {
                    [lbTitle setTextColor:[UIColor blackColor]];
                }
            }
        }
    }
}

- (void)setupFilterArray:(NSInteger)row {
    if (row == 0) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"value", @"", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"在线", @"value", @"1", @"id", nil], nil];
    }
    else if (row == 1) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"value", @"", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"初中", @"value", @"1", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"高中/中技/中专", @"value", @"2", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"大专", @"value", @"5", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"本科", @"value", @"6", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"硕士", @"value", @"7", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"博士", @"value", @"8", @"id", nil], nil];
    }
    else if (row == 2) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"value", @"", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"1~2年", @"value", @"1", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"3~5年", @"value", @"2", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"6~10年", @"value", @"3", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"10年以上", @"value", @"4", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"应届毕业生", @"value", @"5", @"id", nil], nil];
    }
    else if (row == 3) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"value", @"", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"全职", @"value", @"1", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"兼职", @"value", @"3", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"实习", @"value", @"4", @"id", nil], nil];
    }
    else if (row == 4) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"不限", @"value", @"", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"少于50人", @"value", @"1", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"50~100人", @"value", @"2", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"101~200人", @"value", @"3", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"201~500人", @"value", @"4", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"501~1000人", @"value", @"5", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"1000人以上", @"value", @"6", @"id", nil], nil];
    }
    else if (row == 5) {
        self.arrayData = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:@"社会保险", @"value", @"1", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"公积金", @"value", @"2", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"奖金提成", @"value", @"13", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"双休", @"value", @"3", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"8小时工作制", @"value", @"9", @"id", nil], [NSDictionary dictionaryWithObjectsAndKeys:@"提供住宿", @"value", @"10", @"id", nil], nil];
    }
}

- (void)confirmFilter {
    [self.delegate WKFilterOtherClick:self.arraySelect];
}

- (void)clearFilter {
    self.arraySelect = [NSMutableArray arrayWithObjects:@"", @"", @"", @"", @"", @"", nil];
    self.arrayData = nil;
    [self.tableViewLeft reloadData];
    [self.tableViewRight reloadData];
}

- (void)backgroundClick {
    [self.delegate WKFilterViewClose];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UICollectionView class]]) {
        return YES;
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
