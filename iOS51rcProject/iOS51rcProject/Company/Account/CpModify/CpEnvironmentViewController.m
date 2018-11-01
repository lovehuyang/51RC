//
//  CpEnvironmentViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//

#import "CpEnvironmentViewController.h"
#import "Common.h"
#import "CommonMacro.h"
#import "NetWebServiceRequest.h"
#import "WKLabel.h"
#import "UIImageView+WebCache.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "UIImage+Size.h"

@interface CpEnvironmentViewController ()<NetWebServiceRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MLImageCropDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSArray *arrData;
@property (nonatomic, strong) UIScrollView *scrollView;
@property CGFloat heigthForScroll;
@end

@implementation CpEnvironmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"环境照片";
    [self.view setBackgroundColor:SEPARATECOLOR];
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT)];
    [self.view addSubview:self.scrollView];
    [self getData];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpEnvironment" Params:[NSDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainId", CAMAINCODE, @"code", CPMAINID, @"cpMainID", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        self.arrData = [Common getArrayFromXml:requestData tableName:@"dtCpEnvironment"];
        [self fillData];
    }
    else {
        [self getData];
    }
}

- (void)fillData {
    for (UIView *view in self.scrollView.subviews) {
        [view removeFromSuperview];
    }
    UIView *viewTitle = [[UIView alloc] init];
    [viewTitle setBackgroundColor:[UIColor whiteColor]];
    [self.scrollView addSubview:viewTitle];
    
    WKLabel *lbTitle = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, 15, SCREEN_WIDTH - 30, 10) content:@"可以上传办公环境、公司周边、员工活动等公司相关的照片，有助于吸引更多的求职者投递简历，最多上传10张。" size:DEFAULTFONTSIZE color:nil spacing:10];
    [viewTitle addSubview:lbTitle];
    
    [viewTitle setFrame:CGRectMake(0, 10, SCREEN_WIDTH, VIEW_BY(lbTitle) + 15)];
    self.heigthForScroll = VIEW_BY(viewTitle);
    NSMutableArray *arrayPass = [[NSMutableArray alloc] init];
    NSMutableArray *arrayNotPass = [[NSMutableArray alloc] init];
    for (NSDictionary *data in self.arrData) {
        if ([[data objectForKey:@"HasPassed"] boolValue] || [[data objectForKey:@"HasPassed"] length] == 0) {
            [arrayPass addObject:data];
        }
        else {
            [arrayNotPass addObject:data];
        }
    }
    if (self.arrData.count < 10) {
        [arrayPass addObject:[NSDictionary dictionaryWithObjectsAndKeys:@"1", @"Add", nil]];
    }
    [self fillEnvironment:arrayPass];
    
    if (arrayNotPass.count > 0) {
        WKLabel *lbWarning = [[WKLabel alloc] initWithFixedSpacing:CGRectMake(15, self.heigthForScroll + 10, SCREEN_WIDTH - 30, 10) content:@"以下环境照片未审核通过，请删除后重新上传" size:DEFAULTFONTSIZE color:[UIColor redColor] spacing:10];
        [self.scrollView addSubview:lbWarning];
        self.heigthForScroll = VIEW_BY(lbWarning);
        
        [self fillEnvironment:arrayNotPass];
    }
}

- (void)fillEnvironment:(NSArray *)array {
    CGFloat xForImage = 5;
    CGFloat widthForImage = (SCREEN_WIDTH - 50) / 3;
    for (NSInteger i = 0; i < array.count; i++) {
        NSDictionary *data = [array objectAtIndex:i];
        CGRect rect = CGRectMake(xForImage + 10, self.heigthForScroll + 10, widthForImage, widthForImage);
        if ([[data objectForKey:@"Add"] isEqualToString:@"1"]) {
            UIButton *btnAdd = [[UIButton alloc] initWithFrame:rect];
            [btnAdd setImage:[UIImage imageNamed:@"cp_logoadd.png"] forState:UIControlStateNormal];
            [btnAdd.imageView setContentMode:UIViewContentModeScaleAspectFit];
            [btnAdd setImageEdgeInsets:UIEdgeInsetsMake(30, 30, 30, 30)];
            [btnAdd addTarget:self action:@selector(uploadClick) forControlEvents:UIControlEventTouchUpInside];
            [btnAdd setBackgroundColor:[UIColor whiteColor]];
            [self.scrollView addSubview:btnAdd];
        }
        else {
            UIImageView *imgEnvironment = [[UIImageView alloc] initWithFrame:rect];
            [imgEnvironment setContentMode:UIViewContentModeScaleAspectFit];
            [imgEnvironment setBackgroundColor:[UIColor whiteColor]];
            [imgEnvironment sd_setImageWithURL:[NSURL URLWithString:[data objectForKey:@"ImgFile"]]];
            [self.scrollView addSubview:imgEnvironment];
            
            [imgEnvironment setUserInteractionEnabled:YES];
            
            UIButton *btnDel = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_W(imgEnvironment) - 30, 0, 30, 30)];
            [btnDel setTag:[[data objectForKey:@"ID"] integerValue]];
            [btnDel setImage:[UIImage imageNamed:@"cp_imgclose"] forState:UIControlStateNormal];
            [btnDel addTarget:self action:@selector(delClick:) forControlEvents:UIControlEventTouchUpInside];
            [imgEnvironment addSubview:btnDel];
        }
        if ((i + 1) % 3 == 0 || i == array.count - 1) {
            xForImage = 5;
            self.heigthForScroll = rect.origin.y + rect.size.height;
        }
        else {
            xForImage = rect.origin.x + rect.size.width;
        }
    }
}

- (void)uploadClick {
    UIAlertController *alerPhoto = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPhoto:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"从手机相册选择" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self getPhoto:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alerPhoto addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alerPhoto animated:YES completion:nil];
}

- (void)getPhoto:(UIImagePickerControllerSourceType)sourceType {
    NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
    if ([UIImagePickerController isSourceTypeAvailable:sourceType] &&[mediatypes count] > 0) {
        NSArray *mediatypes = [UIImagePickerController availableMediaTypesForSourceType:sourceType];
        UIImagePickerController *pickerPhoto = [[UIImagePickerController alloc] init];
        pickerPhoto.mediaTypes = mediatypes;
        pickerPhoto.delegate = self;
        pickerPhoto.sourceType = sourceType;
        NSString *requiredmediatype = (NSString *)kUTTypeImage;
        NSArray *arrmediatypes = [NSArray arrayWithObject:requiredmediatype];
        [pickerPhoto setMediaTypes:arrmediatypes];
        [self presentViewController:pickerPhoto animated:YES completion:nil];
    }
    else {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"当前设备不支持拍摄功能" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeImage]) {
        UIImage *imgSelect = [info objectForKey:UIImagePickerControllerOriginalImage];
        MLImageCrop *imgCrop = [[MLImageCrop alloc] init];
        imgCrop.delegate = self;
        imgCrop.image = imgSelect;
        imgCrop.ratioOfWidthAndHeight = 31.0f/16.0f;
        [imgCrop showWithAnimation:true];
    }
    else if ([[info objectForKey:UIImagePickerControllerMediaType] isEqual:(NSString *) kUTTypeMovie]) {
        UIAlertController *alertError = [UIAlertController alertControllerWithTitle:@"提示" message:@"系统只支持图片格式" preferredStyle:UIAlertControllerStyleAlert];
        [alertError addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertError animated:YES completion:nil];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)cropImage:(UIImage*)cropImage forOriginalImage:(UIImage*)originalImage {
    cropImage = [cropImage transformtoSize:CGSizeMake(620, 320)];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 1.0);
    [self uploadEnvironment:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadEnvironment:(NSString *)dataPhoto {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UploadLogo" Params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", CAMAINID, @"caMainId", CAMAINCODE, @"code", @"3", @"intImgType", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)delClick:(UIButton *)button {
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteLogo" Params:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:@"%ld", button.tag], @"imageId", CAMAINID, @"caMainId", CAMAINCODE, @"code", @"3", @"intImgType", nil] viewController:self];
        [request setTag:2];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertDelete animated:YES completion:nil];
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
