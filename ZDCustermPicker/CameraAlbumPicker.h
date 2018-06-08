//
//  CameraAlbumPicker.h
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

typedef void(^ImageBlock)(UIImage *selectedImage);

@interface CameraAlbumPicker : NSObject <UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property (weak, nonatomic) UIViewController *jumpVC;
@property (copy, nonatomic) ImageBlock resultBlock;

- (instancetype)initJumpVC:(UIViewController *)jumpVC CompletionHandler:(ImageBlock)completionHandler;

- (void)showSheetView;
- (void)showCamera;
- (void)showAlbum;

@end
