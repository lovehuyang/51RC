//
//  CpLogoViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2018/1/15.
//  Copyright © 2018年 Lucifer. All rights reserved.
//  企业Logo页面

#import "CpLogoViewController.h"
#import "WKLabel.h"
#import "CommonMacro.h"
#import "Common.h"
#import "NetWebServiceRequest.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "UIImageView+WebCache.h"

@interface CpLogoViewController ()<NetWebServiceRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MLImageCropDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) NSString *imageId;
@end

@implementation CpLogoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"企业Logo";
    [self.view setBackgroundColor:SEPARATECOLOR];
    [Common changeFontSize:self.view];
    [self getData];
}

- (void)getData {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"GetCpLogo" Params:[NSMutableDictionary dictionaryWithObjectsAndKeys:CAMAINID, @"caMainId", CAMAINCODE, @"code", nil] viewController:self];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        NSArray *arrayCpLogo = [Common getArrayFromXml:requestData tableName:@"dtLogo"];
        if (arrayCpLogo.count == 0) {
            [self.lbLogo setText:@"贵企业的LOGO图还没有上传。您的LOGO图上传后，将自动出现在电脑版网站首页LOGO区、手机站的职位搜索列表及企业页面！"];
            [self.viewUpload setHidden:NO];
            [self.viewDelete setHidden:YES];
        }
        else {
            [self.viewUpload setHidden:YES];
            [self.viewDelete setHidden:NO];
            NSDictionary *dataCpLogo = [arrayCpLogo objectAtIndex:0];
            self.imageId = [dataCpLogo objectForKey:@"ID"];
            if (self.imgLogo.image == nil) {
                [self.imgLogo sd_setImageWithURL:[NSURL URLWithString:[dataCpLogo objectForKey:@"ImgFile"]]];
            }
            if ([[dataCpLogo objectForKey:@"HasPassed"] boolValue]) {
                [self.lbLogo setText:@"贵企业的LOGO图已经通过我们的审核，已经出现在网站首页，您每登录一次，会出现在最新的位置。"];
            }
            else {
                if ([[dataCpLogo objectForKey:@"HasPassed"] length] == 0) {
                    [self.lbLogo setText:@"贵企业的LOGO图已经上传，但还没有经过我们的审核。我们将在一个工作日内完成审核，请耐心等待。"];
                }
                else {
                    [self.lbLogo setText:[dataCpLogo objectForKey:@"CheckMessage"]];
                    [self.lbLogo setTextColor:[UIColor redColor]];
                    [self.viewUpload setHidden:NO];
                    [self.viewDelete setHidden:YES];
                }
            }
        }
    }
    else {
        [self getData];
    }
}

- (IBAction)uploadClick:(id)sender {
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
        imgCrop.ratioOfWidthAndHeight = 1.0f/1.0f;
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
    [self.imgLogo setImage:cropImage];
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0.1);
    [self uploadLogo:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadLogo:(NSString *)dataPhoto {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"UploadLogo" Params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", CAMAINID, @"caMainId", CAMAINCODE, @"code", @"1", @"intImgType", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (IBAction)deleteClick:(id)sender {
    UIAlertController *alertDelete = [UIAlertController alertControllerWithTitle:@"确定要删除吗？" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrlCp:@"DeleteLogo" Params:[NSDictionary dictionaryWithObjectsAndKeys:self.imageId, @"imageId", CAMAINID, @"caMainId", CAMAINCODE, @"code", @"1", @"intImgType", nil] viewController:self];
        [request setTag:3];
        [request setDelegate:self];
        [request startAsynchronous];
        self.runningRequest = request;
    }]];
    [alertDelete addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self presentViewController:alertDelete animated:YES completion:nil];
}

@end
