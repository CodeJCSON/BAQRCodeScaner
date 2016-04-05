//
//  BAQRCodeScaner.m
//  hookTest
//
//  Created by 博爱 on 16/4/5.
//  Copyright © 2016年 博爱之家. All rights reserved.
//

#import "BAQRCodeScaner.h"
#import "BABaseViewController.h"

CGFloat space_y = 64.0f;
// 当前设备的屏幕宽度
#define KSCREEN_WIDTH    [[UIScreen mainScreen] bounds].size.width
// 当前设备的屏幕高度
#define KSCREEN_HEIGHT   [[UIScreen mainScreen] bounds].size.height
#define scanerView_W_H 200
#define TINTCOLOR_ALPHA 0.5f //浅色透明度
#define DARKCOLOR_ALPHA 0.8f //深色透明度

@interface BAQRCodeScaner ()<AVCaptureMetadataOutputObjectsDelegate>

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *scanWindow;
@property (nonatomic, assign) CGFloat space_x;
@property (nonatomic, assign) CGFloat duration;
@property (nonatomic, strong) CABasicAnimation *scanNetAnimation;
@property (nonatomic, strong) UIImageView *QRImageView;

// 二维码
@property (nonatomic, strong) UIButton *QrCodeBtn;
//管道--连接输出 输入流
@property (nonatomic, strong) AVCaptureSession *session;
//用于展示输出流到界面上的视图
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *videoLayer;

@end

@implementation BAQRCodeScaner

- (void)viewWillAppear:(BOOL)animated
{
    /**
     *  动画不能放在viewDidLoad里面
     */
    [self setScanWindow];
    [self scanQRCode];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    self.duration = 2.0f;
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    self.space_x = (KSCREEN_WIDTH - scanerView_W_H) * 0.5;
    if (self.navigationController && !self.navigationController.navigationBarHidden)
    {
        space_y = 64.0 + 61.8;
    }
    
    [self stepBackgroundView];
}

- (void)stepBackgroundView
{
    self.backgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    [self.view addSubview:self.backgroundView];
    
    /**
     *  扫描窗口背景
     */
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRect:self.view.bounds];
    [maskPath appendPath:[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(self.space_x, space_y, KSCREEN_WIDTH - self.space_x * 2.0, scanerView_W_H) cornerRadius:1] bezierPathByReversingPath]];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.path = maskPath.CGPath;
    self.backgroundView.layer.mask = maskLayer;
}

-(void)setScanWindow
{
    /**
     *  扫描窗口
     */
    UIView *scanWindow = [[UIView alloc] initWithFrame:CGRectMake(self.space_x, space_y, KSCREEN_WIDTH - self.space_x * 2.0, scanerView_W_H)];
    scanWindow.clipsToBounds = YES;
    self.scanWindow = scanWindow;
    [self.view addSubview:scanWindow];
    
    /**
     *  扫描动画
     */
    _QRImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BAQRCodeScaner.bundle/scan_move"]];
    _QRImageView.frame = CGRectMake(0, -CGRectGetHeight(scanWindow.bounds), KSCREEN_WIDTH - 2.0 * self.space_x, KSCREEN_HEIGHT);
    [scanWindow addSubview:_QRImageView];
    
    _scanNetAnimation = [CABasicAnimation animation];
    _scanNetAnimation.keyPath = @"transform.translation.y";
    _scanNetAnimation.byValue = @(scanerView_W_H);
    _scanNetAnimation.duration = self.duration;
    _scanNetAnimation.repeatCount = MAXFLOAT;
    [_QRImageView.layer addAnimation:_scanNetAnimation forKey:nil];
    
    // 底部view
    UIView *downView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(scanWindow.frame) + 20, KSCREEN_WIDTH , KSCREEN_HEIGHT - CGRectGetMaxY(scanWindow.frame) - 20)];
    downView.alpha = TINTCOLOR_ALPHA;
    downView. backgroundColor = [[ UIColor grayColor ] colorWithAlphaComponent : TINTCOLOR_ALPHA ];
    [self.view addSubview :downView];
    
    // 用于说明的label
    UILabel *labIntroudction= [[ UILabel alloc ] init ];
    labIntroudction. backgroundColor = [ UIColor clearColor ];
    labIntroudction. frame = CGRectMake ( 0 , 20 , KSCREEN_WIDTH , 20 );
    labIntroudction. numberOfLines = 1 ;
    labIntroudction. font =[ UIFont systemFontOfSize : 15.0 ];
    labIntroudction. textAlignment = NSTextAlignmentCenter ;
    labIntroudction. textColor =[ UIColor whiteColor ];
    labIntroudction. text = @"将二维码对准方框，即可自动扫描";
    [downView addSubview :labIntroudction];

    // 取消按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:@"取消" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(0, CGRectGetHeight(downView.frame) - 40, KSCREEN_WIDTH, 30);
    [downView addSubview:button];
    
    [self setOther];
}

- (void)setOther
{
    /**
     *  四个角
     */
    UIImageView *imageView1 = [UIImageView new];
    UIImageView *imageView2 = [UIImageView new];
    UIImageView *imageView3 = [UIImageView new];
    UIImageView *imageView4 = [UIImageView new];
    
    imageView1.image = [UIImage imageNamed:@"BAQRCodeScaner.bundle/scan_1"];
    imageView2.image = [UIImage imageNamed:@"BAQRCodeScaner.bundle/scan_2"];
    imageView3.image = [UIImage imageNamed:@"BAQRCodeScaner.bundle/scan_3"];
    imageView4.image = [UIImage imageNamed:@"BAQRCodeScaner.bundle/scan_4"];
    
    const CGFloat width = 19.0;
    
    imageView1.frame = CGRectMake(self.space_x, space_y, width, width);
    imageView2.frame = CGRectMake(self.space_x + scanerView_W_H - width, space_y, width, width);
    imageView3.frame = CGRectMake(self.space_x, space_y + scanerView_W_H - width + 2, width, width);
    imageView4.frame = CGRectMake(self.space_x + scanerView_W_H - width, space_y + scanerView_W_H - width + 2, width, width);
    
    [self.view addSubview:imageView1];
    [self.view addSubview:imageView2];
    [self.view addSubview:imageView3];
    [self.view addSubview:imageView4];
}

#pragma mark 二维码的扫描
- (void)scanQRCode
{
    // 1、获取后置摄像头的管理对象, Capture:捕获
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // 2、从摄像头捕获输入流
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (error)
    {
        NSLog(@"摄像头error：%@", error);
        return;
    }
    
    // 3、创建输出流-->把图像输入到屏幕上显示
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    CGRect rectOfInterest = CGRectMake(64 / KSCREEN_HEIGHT, (KSCREEN_WIDTH - 200)*0.5 / KSCREEN_WIDTH, KSCREEN_WIDTH - (KSCREEN_WIDTH - 200)*0.5 * 2.0 / KSCREEN_HEIGHT, KSCREEN_WIDTH - (KSCREEN_WIDTH - 200)*0.5 * 2.0 / KSCREEN_WIDTH);
    output.rectOfInterest = rectOfInterest;
    // 设置代理,在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    // 4、需要一个管道连接输入和输出
    _session = [AVCaptureSession new];
    if ([self.session canAddInput:input])
    {
        [self.session addInput:input];
    }
    
    if ([self.session canAddOutput:output])
    {
        [self.session addOutput:output];
    }

    // 5、管道可以规定质量,  流畅/高清/标清
    //    AVCaptureSessionPresetPhoto
    //    AVCaptureSessionPresetMedium
    //    AVCaptureSessionPresetLow
    //    AVCaptureSessionPreset320x240
    //    AVCaptureSessionPreset352x288
    //    AVCaptureSessionPreset640x480
    
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    
#warning 设置输出流监听 二维码/条形码, 必须在管道接通之后设置!!!
    output.metadataObjectTypes = @[
                                   AVMetadataObjectTypeQRCode,
                                   AVMetadataObjectTypeEAN13Code,
                                   AVMetadataObjectTypeCode128Code,
                                   AVMetadataObjectTypeEAN8Code];
    
    // 6、把画面输入到屏幕上,给用户看
    _videoLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    _videoLayer.frame = self.view.bounds;
    _videoLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    // 插入到最底层
    [self.view.layer insertSublayer:_videoLayer atIndex:0];
    
    // 7、启动管道
    [_session startRunning];
    
    
    //扫描二维码 需要系统库  AVFoundation支持
    //1.到build phase +类库, 然后使用 #import <AVF...>
    //iOS7以后,引入系统类库 有快捷方式
    //    @import AVFoundation;
    /*扫描二维码流程
     1.打开后置摄像头
     2.从后置摄像头中读取数据输入流
     3.把输入流 输出到屏幕上进行展示-> 输出流
     4.把输入流 -> 转移到 输出流.. 中间需要一个管道-->会话
     5.让输出流(向屏幕显示) 实时过滤自己的内容, 监听是否有二维码/条形码存在.  如果有,就通过协议通知我们
     */
}

#pragma mark 当扫描到我们想要的数据时,触发
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //  metadataObjects 数组中 存放的就是扫描出的数据
    if (metadataObjects.count > 0)
    {
        //  如果扫描到, 关闭管道,去掉扫描显示
        [_session stopRunning];
        //拿扫描到的数据
        AVMetadataMachineReadableCodeObject *obj = metadataObjects.firstObject;
        NSLog(@"扫描 到得数据：%@", obj.stringValue);
        if (self.returnQRString)
        {
            self.returnQRString(obj.stringValue);
            [_videoLayer removeFromSuperlayer];
        }
    }
}

- (IBAction)cancel:(UIButton *)sender
{
    [self dismiss];
}

- (void)dismiss
{
    [_videoLayer removeFromSuperlayer];
    [_QRImageView.layer removeAllAnimations];
    [self.navigationController popViewControllerAnimated:YES];
}

+ (BOOL)pr_isAvailable
{
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!captureDevice)
    {
        return NO;
    }
    
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
    if (!input || error)
    {
        return NO;
    }
    
    return YES;
}

+ (BOOL)supportsMetadataObjectTypes:(NSArray *)metadataObjectTypes
{
    if (![self pr_isAvailable])
    {
        return NO;
    }
    
    AVCaptureDevice *captureDevice    = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
    AVCaptureMetadataOutput *output   = [[AVCaptureMetadataOutput alloc] init];
    AVCaptureSession *session         = [[AVCaptureSession alloc] init];
    
    [session addInput:deviceInput];
    [session addOutput:output];
    
    if (metadataObjectTypes == nil || metadataObjectTypes.count == 0)
    {
        metadataObjectTypes = @[AVMetadataObjectTypeQRCode];
    }
    
    for (NSString *metadataObjectType in metadataObjectTypes)
    {
        if (![output.availableMetadataObjectTypes containsObject:metadataObjectType])
        {
            return NO;
        }
    }
    return YES;
}



@end
