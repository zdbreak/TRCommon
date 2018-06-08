//
//  QRCode.m
//  CollectionTest
//
//  Created by apple on 2017/12/21.
//  Copyright © 2017年 thinkrace. All rights reserved.
//

#import "QRCode.h"

@interface QRCode ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) ScanAreaView *areaView;

@end

@implementation QRCode

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSession];
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame CompletionHandler:(MetadataBlock)resultBlock{
    self = [super initWithFrame:frame];
    if (self) {
        _resultBlock = [resultBlock copy];
        [self initSession];
    }
    return self;
}


#pragma mark -初始化控件
- (void)initSession{
    //初始化 扫描区域
    CGFloat width = 220;
    CGRect scanRect = CGRectMake((CGRectGetWidth(self.frame) - width)/2.0, (CGRectGetHeight(self.frame) - width)/2.0, width, width);
    [self hollowLayer:scanRect];
    //AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    //获取摄像设备
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (!device) {
        return;
    }
    //创建输入流
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    //设置识别区域
    //深坑，这个值是按比例0~1设置，而且X、Y要调换位置，width、height调换位置    (以右上角为坐标原点处理)
    output.rectOfInterest = CGRectMake(CGRectGetMinY(scanRect)/CGRectGetHeight(self.frame), CGRectGetMinX(scanRect)/CGRectGetWidth(self.frame), CGRectGetHeight(scanRect)/CGRectGetHeight(self.frame), CGRectGetWidth(scanRect)/CGRectGetWidth(self.frame));
    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:input]) {
        [_session addInput:input];
    }
    
    if ([_session canAddOutput:output]) {
        [_session addOutput:output];
    }
    // 设置扫码支持的编码格式(如下设置条形码和二维码兼容) 此步骤需要在addoutput 之后设置
    output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code,AVMetadataObjectTypeEAN8Code,AVMetadataObjectTypeCode128Code];
    
    _areaView = [[ScanAreaView alloc]initWithFrame:scanRect];
    [self addSubview:_areaView];
    [self initLayer];
}

- (void)hollowLayer:(CGRect)myRect{
    UIColor *color = [[UIColor blackColor]colorWithAlphaComponent:0.4];
    UIView *upView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetMinY(myRect))];
    upView.backgroundColor = color;
    [self addSubview:upView];
   
    UIView *downView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(myRect), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetHeight(myRect) - CGRectGetHeight(upView.frame))];
    downView.backgroundColor = color;
    [self addSubview:downView];
    
    CGFloat lrWidth = (CGRectGetWidth(self.frame) - CGRectGetWidth(myRect))/2.0;
    CGFloat lrHeight = (CGRectGetHeight(self.frame) -CGRectGetHeight(upView.frame) - CGRectGetHeight(downView.frame));
    UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(upView.frame),lrWidth, lrHeight)];
    leftView.backgroundColor = color;
    [self addSubview:leftView];
    
    UIView *rightView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(myRect), CGRectGetMinY(leftView.frame), lrWidth, lrHeight)];
    rightView.backgroundColor = color;
    [self addSubview:rightView];
}

- (void)initLayer{
    //实例化预览图层  传递session 是为了告诉图层将来要显示什么内容
    AVCaptureVideoPreviewLayer *previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    previewLayer.frame = self.bounds;
    [self.layer insertSublayer:previewLayer atIndex:0];
    [self startScan];
}
#pragma mark -AVCaptureMetadataOutputObjectsDelegate
-(void)captureOutput:(AVCaptureOutput *)output didOutputMetadataObjects:(NSArray<__kindof AVMetadataObject *> *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [self stopScan];
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];
        NSString *code = metadataObject.stringValue;
        self.resultBlock(code);
    }
}

-(void)startScan{
    [_session startRunning];
    [_areaView startAnimaion];
}

- (void)stopScan{
    [_session stopRunning];
    [_areaView stopAnimaion];
}

- (void)OPEN:(UIButton *)btn{
    btn.selected = !btn.isSelected;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch]) {
        [device lockForConfiguration:nil];
        if (btn.selected){[device setTorchMode:AVCaptureTorchModeOn];}
        else{[device setTorchMode:AVCaptureTorchModeOff];}
        [device unlockForConfiguration];
    }
}

@end



@interface ScanAreaView ()

@property (nonatomic , strong) dispatch_source_t timer;
@property (strong , nonatomic) UIImageView *lineImageView;
@property (assign , nonatomic) CGPoint position;

@end

@implementation ScanAreaView

- (instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self initSubViews];
    }
    return self;
}

- (void)initSubViews{
    self.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc]initWithFrame:self.bounds];
    imageView.image = [UIImage imageNamed:@"frame_icon"];
    [self addSubview:imageView];
    
    _lineImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), 4.5)];
    _lineImageView.image = [UIImage imageNamed:@"line"];
    [self addSubview:_lineImageView];
    self.position = CGPointMake(CGRectGetWidth(self.frame)/2.0, CGRectGetHeight(_lineImageView.frame)/2);
    [self initTimer];
}

- (void)initTimer{
    
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
    uint64_t interval = 0.01 * NSEC_PER_SEC;
    dispatch_source_set_timer(self.timer, start, interval, 0);
    __weak ScanAreaView *temp = self;
    dispatch_source_set_event_handler(self.timer, ^{
        dispatch_async(dispatch_get_main_queue(), ^{
             [temp changeImageFrame];
        });
    });
    dispatch_resume(_timer);
}

- (void)changeImageFrame{
    
    CGPoint newPoint = self.position;
    newPoint.y += 0.5;
    if (newPoint.y >= CGRectGetHeight(self.frame) - CGRectGetHeight(_lineImageView.frame)/2) {
        newPoint.y = CGRectGetHeight(_lineImageView.frame)/2;
    }
    self.position = newPoint;
    _lineImageView.center = self.position;
    
}

#pragma mark -events

-(void)startAnimaion{
    self.position = CGPointMake(self.position.x, CGRectGetHeight(_lineImageView.frame)/2);
    if(_timer){
    }else{
       [self initTimer];
    }
}

-(void)stopAnimaion{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
       // _lineImageView.hidden = YES;
    }
}

-(void)dealloc{
    if(_timer){
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

@end


