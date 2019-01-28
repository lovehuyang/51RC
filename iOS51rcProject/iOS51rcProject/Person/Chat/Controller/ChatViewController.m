//
//  ChatViewController.m
//  iOS51rcProject
//
//  Created by Lucifer on 2017/6/26.
//  Copyright © 2017年 Lucifer. All rights reserved.
//

#import "ChatViewController.h"
#import "CommonMacro.h"
#import "UIImage+GIF.h"
#import "FLAnimatedImage.h"
#import "NetWebServiceRequest.h"
#import "UIView+Toast.h"
#import <MobileCoreServices/UTCoreTypes.h>
#import "MLImageCrop.h"
#import "WKNavigationController.h"
#import "JobViewController.h"
#import "PreviewViewController.h"
@import WebKit;

@interface ChatViewController ()<WKNavigationDelegate, WKScriptMessageHandler, UITextFieldDelegate, UIScrollViewDelegate, NetWebServiceRequestDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MLImageCropDelegate>

@property (nonatomic, strong) NetWebServiceRequest *runningRequest;
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UIView *viewContent;
@property (nonatomic, strong) UIView *viewChat;
@property (nonatomic, strong) UIView *viewEmotion;
@property (nonatomic, strong) UIScrollView *viewScroll;
@property (nonatomic, strong) NSArray *arrayData;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *messageType;
@property float widthForEmotion;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.widthForEmotion = SCREEN_WIDTH / 5;
    self.viewContent = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT + self.widthForEmotion * 2 + 50)];
    [self.view addSubview:self.viewContent];
    
    WKWebViewConfiguration *config =
    [[WKWebViewConfiguration alloc] init];
    [config.userContentController addScriptMessageHandler:self name:@"jobView"];
    [config.userContentController addScriptMessageHandler:self name:@"cvView"];
    [config.userContentController addScriptMessageHandler:self name:@"companyView"];
    [config.userContentController addScriptMessageHandler:self name:@"chatClick"];
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT + STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT - NAVIGATION_BAR_HEIGHT - STATUS_BAR_HEIGHT - TAB_BAR_HEIGHT) configuration:config];
    [self.webView.scrollView setBounces:NO];
    [self.webView setNavigationDelegate:self];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/chatonline/palogmobile?ca=%@&cv=%@&paMainId=%@&code=%@&app=1", [USER_DEFAULT valueForKey:@"subsite"], self.caMainId, self.cvMainId, PAMAINID, [USER_DEFAULT valueForKey:@"paMainCode"]]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    [self.viewContent addSubview:self.webView];
    
    [[self.view viewWithTag:LOADINGTAG] setHidden:NO];
    
    //[self.webView setUserInteractionEnabled:YES];
    //[self.webView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(webViewClick)]];
    
    self.viewChat = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT - TAB_BAR_HEIGHT, SCREEN_WIDTH, TAB_BAR_HEIGHT)];
    [self.viewContent addSubview:self.viewChat];
    
    UIView *viewSeparate = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
    [viewSeparate setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
    [self.viewChat addSubview:viewSeparate];
    
    UITextField *txtChat = [[UITextField alloc] initWithFrame:CGRectMake(20, 8, SCREEN_WIDTH - 35 - TAB_BAR_HEIGHT * 2, TAB_BAR_HEIGHT - 16)];
    [txtChat setDelegate:self];
    [txtChat setReturnKeyType:UIReturnKeySend];
    [txtChat.layer setBorderColor:[UIColorWithRGBA(215, 215, 215, 1) CGColor]];
    [txtChat.layer setBorderWidth:1];
    [txtChat.layer setCornerRadius:5];
    UIView *viewLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, VIEW_H(txtChat))];
    [txtChat setLeftViewMode:UITextFieldViewModeAlways];
    [txtChat setLeftView:viewLeft];
    [self.viewChat addSubview:txtChat];
    
    UIButton *btnEmotion = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(txtChat) + 10, 0, TAB_BAR_HEIGHT, TAB_BAR_HEIGHT)];
    [btnEmotion setImage:[UIImage imageNamed:@"chat_emotion.png"] forState:UIControlStateNormal];
    [btnEmotion.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnEmotion setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [btnEmotion addTarget:self action:@selector(emotionClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewChat addSubview:btnEmotion];
    
    UIButton *btnPhoto = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnEmotion), 0, TAB_BAR_HEIGHT, TAB_BAR_HEIGHT)];
    [btnPhoto setImage:[UIImage imageNamed:@"chat_photo.png"] forState:UIControlStateNormal];
    [btnPhoto.imageView setContentMode:UIViewContentModeScaleAspectFit];
    [btnPhoto setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [btnPhoto addTarget:self action:@selector(photoClick) forControlEvents:UIControlEventTouchUpInside];
    [self.viewChat addSubview:btnPhoto];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 添加对键盘的监控
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.runningRequest cancel];
}

- (void)keyBoardWillShow:(NSNotification *)note {
    [self emotionCancel];
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘高度
    CGRect keyBoardBounds  = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyBoardHeight = keyBoardBounds.size.height;
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    if (SCREEN_HEIGHT - VIEW_BY(self.viewChat) < keyBoardHeight) {
        [UIView animateWithDuration:animationTime animations:^{
            CGRect frameView = self.view.frame;
            frameView.origin.y = SCREEN_HEIGHT - VIEW_BY(self.viewChat) - keyBoardHeight;
            [self.view setFrame:frameView];
        }];
    }
}

- (void)keyBoardWillHide:(NSNotification *)note {
    // 获取用户信息
    NSDictionary *userInfo = [NSDictionary dictionaryWithDictionary:note.userInfo];
    // 获取键盘动画时间
    CGFloat animationTime  = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [UIView animateWithDuration:animationTime animations:^{
        CGRect frameView = self.view.frame;
        frameView.origin.y = 0;
        [self.view setFrame:frameView];
    }];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation {
    [[self.view viewWithTag:LOADINGTAG] setHidden:YES];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSString *param = message.body;
    if ([message.name isEqualToString:@"jobView"]) {
        WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
        JobViewController *jobCtrl = jobNav.viewControllers[0];
        jobCtrl.jobId = param;
        [self presentViewController:jobNav animated:YES completion:nil];
    }
    else if ([message.name isEqualToString:@"companyView"]) {
        WKNavigationController *jobNav = [[UIStoryboard storyboardWithName:@"Person" bundle:nil] instantiateViewControllerWithIdentifier:@"jobView"];
        JobViewController *jobCtrl = jobNav.viewControllers[0];
        jobCtrl.companyId = param;
        [self presentViewController:jobNav animated:YES completion:nil];
    }
    else if ([message.name isEqualToString:@"cvView"]) {
//        PreviewViewController *previewCtrl = [[PreviewViewController alloc] init];
//        previewCtrl.cvMainId = param;
//        [self.navigationController pushViewController:previewCtrl animated:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger page = scrollView.contentOffset.x / SCREEN_WIDTH;
    [self.pageControl setCurrentPage:page];
}

- (void)emotionClick {
    [self.view endEditing:YES];
    if (self.viewEmotion == nil) {
        self.viewEmotion = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, VIEW_H(self.viewContent) - VIEW_H(self.view))];
        
        UIView *viewSeparateTop = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 0.5)];
        [viewSeparateTop setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
        [self.viewEmotion addSubview:viewSeparateTop];
        
        self.viewScroll = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, self.widthForEmotion * 2 + 10)];
        [self.viewScroll setDelegate:self];
        [self.viewScroll setContentSize:CGSizeMake(SCREEN_WIDTH * 3, VIEW_H(self.viewScroll))];
        [self.viewScroll setShowsHorizontalScrollIndicator:NO];
        [self.viewScroll setShowsVerticalScrollIndicator:NO];
        [self.viewScroll setPagingEnabled:YES];
        [self.viewEmotion addSubview:self.viewScroll];
        
        self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewScroll) - 15, 50, 10)];
        [self.pageControl setCenter:CGPointMake(self.view.center.x, self.pageControl.center.y)];
        [self.pageControl setNumberOfPages:3];
        [self.pageControl setPageIndicatorTintColor:SEPARATECOLOR];
        [self.pageControl setCurrentPageIndicatorTintColor:[UIColor grayColor]];
        [self.viewEmotion addSubview:self.pageControl];
        
        UIView *viewSeparateBottom = [[UIView alloc] initWithFrame:CGRectMake(0, VIEW_BY(self.viewScroll), SCREEN_WIDTH, 0.5)];
        [viewSeparateBottom setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
        [self.viewEmotion addSubview:viewSeparateBottom];
        
        UIButton *btnItem1 = [[UIButton alloc] initWithFrame:CGRectMake(0, VIEW_BY(viewSeparateBottom), 50, 40)];
        [btnItem1 setTag:9000];
        [btnItem1 setImage:[UIImage imageNamed:@"ico_emoitem1.png"] forState:UIControlStateNormal];
        [btnItem1.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnItem1 setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [btnItem1 addTarget:self action:@selector(emotionItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewEmotion addSubview:btnItem1];
        
        UIButton *btnItem2 = [[UIButton alloc] initWithFrame:CGRectMake(VIEW_BX(btnItem1), VIEW_Y(btnItem1), VIEW_W(btnItem1), VIEW_H(btnItem1))];
        [btnItem2 setTag:9001];
        [btnItem2 setImage:[UIImage imageNamed:@"ico_emoitem2.png"] forState:UIControlStateNormal];
        [btnItem2.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [btnItem2 setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
        [btnItem2 addTarget:self action:@selector(emotionItemClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewEmotion addSubview:btnItem2];
        
        [self fillEmotion:0];
    }
    if (self.viewEmotion.tag == 1) {
        [self emotionCancel];
        return;
    }
    [self.viewEmotion setTag:1];
    [self.viewContent addSubview:self.viewEmotion];
    
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.viewContent.frame;
        frameView.origin.y = 0 - VIEW_H(self.viewEmotion);
        [self.viewContent setFrame:frameView];
    }];
}

- (void)emotionItemClick:(UIButton *)button {
    [self fillEmotion:button.tag - 9000];
}

- (void)fillEmotion:(NSInteger)index {
    UIButton *btnItem1 = [self.viewEmotion viewWithTag:9000];
    UIButton *btnItem2 = [self.viewEmotion viewWithTag:9001];
    if (index == 0) {
        [btnItem1 setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
        [btnItem2 setBackgroundColor:[UIColor clearColor]];
    }
    else {
        [btnItem1 setBackgroundColor:[UIColor clearColor]];
        [btnItem2 setBackgroundColor:UIColorWithRGBA(215, 215, 215, 1)];
    }
    
    for (UIView *view in self.viewScroll.subviews) {
        [view removeFromSuperview];
    }
    float x = 0;
    float y = 0;
    for (NSInteger i = 0; i < 24; i++) {
        NSString *imgFile = [NSString stringWithFormat:@"%ld.gif", (index * 24 + i + 1)];
        UIButton *btnEmotion = [[UIButton alloc] initWithFrame:CGRectMake(x, y, self.widthForEmotion, self.widthForEmotion)];
        [btnEmotion setTitle:imgFile forState:UIControlStateNormal];
        [btnEmotion setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [btnEmotion addTarget:self action:@selector(emotionSelect:) forControlEvents:UIControlEventTouchUpInside];
        [self.viewScroll addSubview:btnEmotion];

        FLAnimatedImageView *imgLoading = [[FLAnimatedImageView alloc] initWithFrame:CGRectMake(10, 10, VIEW_W(btnEmotion) - 20, VIEW_W(btnEmotion) - 20)];
        [imgLoading setAnimatedImage:[FLAnimatedImage animatedImageWithGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:imgFile ofType:nil]]]];
        [btnEmotion addSubview:imgLoading];
        
        x = VIEW_BX(btnEmotion);
        switch (i + 1) {
            case 5:
                x = 0;
                y = self.widthForEmotion;
                break;
            case 10:
                x = SCREEN_WIDTH;
                y = 0;
                break;
            case 15:
                x = SCREEN_WIDTH;
                y = self.widthForEmotion;
                break;
            case 20:
                x = SCREEN_WIDTH * 2;
                y = 0;
                break;
            default:
                break;
        }
        NSLog(@"%f", x);
    }
    [self.viewScroll setContentOffset:CGPointMake(0, 0) animated:NO];
}

- (void)emotionSelect:(UIButton *)button {
    self.message = button.titleLabel.text;
    self.messageType = @"2";
    [self sendMessage];
}

- (void)emotionCancel {
    [self.viewEmotion setTag:0];
    [UIView animateWithDuration:0.5 animations:^{
        CGRect frameView = self.viewContent.frame;
        frameView.origin.y = 0;
        [self.viewContent setFrame:frameView];
    } completion:^(BOOL finished) {
        [self.viewEmotion removeFromSuperview];
    }];
}

- (void)webViewClick {
    [self.view endEditing:YES];
    [self emotionCancel];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField.text.length == 0) {
        [self.view makeToast:@"请输入消息"];
    }
    else {
        self.message = textField.text;
        self.messageType = @"1";
        [textField setText:@""];
        [self sendMessage];
    }
    return YES;
}

- (void)photoClick {
    [self emotionCancel];
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
        imgCrop.ratioOfWidthAndHeight = 3.0f/4.0f;
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
    NSData *dataPhoto = UIImageJPEGRepresentation(cropImage, 0.1);
    [self uploadPhoto:[dataPhoto base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
}

- (void)uploadPhoto:(NSString *)dataPhoto {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"UploadChatFile" Params:[NSDictionary dictionaryWithObjectsAndKeys:dataPhoto, @"stream", PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", [USER_DEFAULT objectForKey:@"provinceId"], @"subsiteID", nil] viewController:self];
    [request setTag:2];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)sendMessage {
    NetWebServiceRequest *request = [NetWebServiceRequest serviceRequestUrl:@"SendMessage" Params:[NSDictionary dictionaryWithObjectsAndKeys:PAMAINID, @"paMainID", [USER_DEFAULT objectForKey:@"paMainCode"], @"code", self.caMainId, @"caMainId", self.cvMainId, @"cvMainId", self.message, @"message", self.messageType, @"messageType", self.jobId, @"JobID", nil] viewController:nil];
    [request setTag:1];
    [request setDelegate:self];
    [request startAsynchronous];
    self.runningRequest = request;
}

- (void)netRequestFinished:(NetWebServiceRequest *)request
      finishedInfoToResult:(NSString *)result
              responseData:(GDataXMLDocument *)requestData {
    if (request.tag == 1) {
        [self.webView evaluateJavaScript:@"fillPaLog();" completionHandler:nil];
    }
    else if (request.tag == 2) {
        self.message = result;
        self.messageType = @"3";
        [self sendMessage];
    }
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
