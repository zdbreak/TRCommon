//
//  TRPicker.h
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^TRStringBlock)(NSString *selectedString);

@interface TRPicker : UIView

//传入的数组都默认按照字符串数组处理
- (instancetype)initStringPickerWithTitle:(NSString *)title DataSource:(NSArray *)dataSource  Result:(TRStringBlock)resultBlock;

//returnType 是返回的时间转化为字符串的类型
- (instancetype)initDatePickerWithTitle:(NSString *)title DateModel:(UIDatePickerMode)pickerMode ReturnType:(NSString *)typeString Result:(TRStringBlock)resultBlock;

//传入的字符串   传空也可以/即是默认第一项
- (void)show:(NSString *)showString;
- (void)setMaxDate:(NSDate *)maxDate;
- (void)setMinDate:(NSDate *)minDate;


@end
