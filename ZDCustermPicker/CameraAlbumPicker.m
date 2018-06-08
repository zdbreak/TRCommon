//
//  CameraAlbumPicker.m
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import "CameraAlbumPicker.h"

@implementation CameraAlbumPicker

-(instancetype)initJumpVC:(UIViewController *)jumpVC CompletionHandler:(ImageBlock)completionHandler{
    
    self = [super init];
    if (self) {
        self.jumpVC = jumpVC;
        self.resultBlock = [completionHandler copy];
    }
    return self;
}
#pragma mark -Events
-(void)showSheetView{
    
        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"App_Camera", @"相机") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [self showCamera];
            }];
            [sheet addAction:cameraAction];
        }
        
        UIAlertAction *albumAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"App_Album", @"相册") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self showAlbum];
        }];
        [sheet addAction:albumAction];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"App_Cancel", @"取消") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }];
        [sheet addAction:cancelAction];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_jumpVC presentViewController:sheet animated:YES completion:NULL];
        });
}
- (void)showAlbum{
    [self jumpTo:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showCamera{
    [self jumpTo:UIImagePickerControllerSourceTypeCamera];
}

- (void)jumpTo:(NSInteger)sourseType{
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = YES;
    imagePickerController.sourceType = sourseType;
    imagePickerController.navigationBar.translucent = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [_jumpVC presentViewController:imagePickerController animated:YES completion:nil];
    });
}


#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    self.resultBlock(image);
    [picker dismissViewControllerAnimated:YES completion:nil];
    
}
@end
