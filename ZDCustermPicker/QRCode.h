//
//  QRCode.h
//  CollectionTest
//
//  Created by apple on 2017/12/21.
//  Copyright © 2017年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^MetadataBlock)(NSString *valueString);

@interface ScanAreaView:UIView

- (void)startAnimaion;
- (void)stopAnimaion;

@end


@interface QRCode : UIView <AVCaptureMetadataOutputObjectsDelegate>

@property (copy, nonatomic) MetadataBlock resultBlock;

- (instancetype)initWithFrame:(CGRect)frame CompletionHandler:(MetadataBlock)resultBlock;

- (void)startScan;
- (void)stopScan;


@end




