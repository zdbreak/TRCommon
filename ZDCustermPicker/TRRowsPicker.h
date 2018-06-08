//
//  TRRowsPicker.h
//  tangyuan
//
//  Created by apple on 2018/2/6.
//  Copyright © 2018年 Guo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TRStringBlock)(NSString *selectedString);

@interface TRRowsPicker : UIView

-(instancetype)initStringPickerWithTitle:(NSString *)title DataSource:(NSArray *)dataSource  Result:(TRStringBlock)resultBlock;

- (void)show:(NSString *)showString;

@end
