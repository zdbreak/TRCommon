//
//  TRPicker.m
//  CollectionTest
//
//  Created by apple on 2018/1/2.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import "TRPicker.h"

#define W_Width CGRectGetWidth([UIScreen mainScreen].bounds)
#define W_Height CGRectGetHeight([UIScreen mainScreen].bounds)
#define C_Height 260.0
#define P_Height 216.0

@interface TRPicker ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong , nonatomic) UIPickerView *picker;
@property (strong , nonatomic) NSArray *pickerArray;
@property (strong , nonatomic) UIDatePicker *datePicker;

@property (nonatomic , strong) UIView *backView;
@property (strong , nonatomic) UIView *contentView;
@property (strong , nonatomic) UIView *topView;

@property (strong , nonatomic) UIButton *leftB;
@property (strong , nonatomic) UIButton *rightB;
@property (strong , nonatomic) UILabel *titleLabel;



@property (copy , nonatomic) TRStringBlock strBlock;
@property (strong , nonatomic) NSString *rType;

@end


@implementation TRPicker

-(instancetype)initStringPickerWithTitle:(NSString *)title DataSource:(NSArray *)dataSource  Result:(TRStringBlock)resultBlock{
    self = [super init];
    if (self) {
        _strBlock = [resultBlock copy];
        _pickerArray = dataSource;
        [self initSubViews];
        self.titleLabel.text = title;
        [self picker];
    }
    return self;
}

-(instancetype)initDatePickerWithTitle:(NSString *)title DateModel:(UIDatePickerMode)pickerMode ReturnType:(NSString *)typeString Result:(TRStringBlock)resultBlock{
    self = [super init];
    if (self) {
        _strBlock = [resultBlock copy];
        _rType = typeString;
        [self initSubViews];
        self.titleLabel.text = title;
        self.datePicker.datePickerMode = pickerMode;
    }
    return self;
}

- (void)initSubViews{
    self.frame = CGRectMake(0, 0, W_Width, W_Height);
    [self backView];
    [self contentView];
    [self topView];
    [self leftB];
    [self rightB];
    [self titleLabel];
}

-(void)setMaxDate:(NSDate *)maxDate{
    self.datePicker.maximumDate = maxDate;
}

-(void)setMinDate:(NSDate *)minDate{
    self.datePicker.minimumDate = minDate;
}
#pragma mark -初始化
- (UIView *)backView{
    if (!_backView) {
        _backView = [[UIView alloc]initWithFrame:self.bounds];
        _backView.backgroundColor = [UIColor colorWithWhite:0.2 alpha:0.2];
        _backView.userInteractionEnabled  = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismiss)];
        [_backView addGestureRecognizer:tap];
        [self addSubview:_backView];
    }
    return _backView;
}

- (UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, W_Height, W_Width, C_Height)];
        _contentView.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIView *)topView{
    if (!_topView) {
        _topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, W_Width, C_Height - P_Height)];
        _topView.backgroundColor = [UIColor colorWithRed:253/255.0 green:253/255.0 blue:253/255.0 alpha:1];
        [self.contentView addSubview:_topView];
    }
    return _topView;
}

- (UIButton *)leftB{
    if (!_leftB) {
        _leftB = [[UIButton alloc]initWithFrame:CGRectMake(10,(CGRectGetHeight(_topView.frame) - 30)/2.0, 60, 30)];
        [_leftB setTitle:NSLocalizedString(@"App_Cancel", @"取消") forState:UIControlStateNormal];
        [_leftB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _leftB.titleLabel.font = [UIFont systemFontOfSize:13];
        [_leftB addTarget:self action:@selector(abolishAction) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:_leftB];
    }
    return _leftB;
}

-(UIButton *)rightB{
    if (!_rightB) {
        _rightB = [[UIButton alloc]initWithFrame:CGRectMake(W_Width - CGRectGetWidth(self.leftB.frame) - CGRectGetMinX(self.leftB.frame) ,CGRectGetMinY(self.leftB.frame), CGRectGetWidth(self.leftB.frame), CGRectGetHeight(self.leftB.frame))];
        [_rightB setTitle:NSLocalizedString(@"App_Confirm", @"确定") forState:UIControlStateNormal];
        [_rightB setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        _rightB.titleLabel.font = [UIFont systemFontOfSize:13];
        [_rightB addTarget:self action:@selector(completeAction) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:_rightB];
    }
    return _rightB;
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, CGRectGetHeight(self.leftB.frame))];
        _titleLabel.center = CGPointMake(W_Width/2.0, self.leftB.center.y);
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:13];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.topView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (UIDatePicker *)datePicker{
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, C_Height - P_Height, W_Width, P_Height)];
        [self.contentView addSubview:_datePicker];
    }
    return _datePicker;
}

- (UIPickerView *)picker{
    if (!_picker) {
        _picker = [[UIPickerView alloc]initWithFrame:CGRectMake(0, C_Height - P_Height, W_Width, P_Height)];
        _picker.delegate = self;
        _picker.dataSource = self;
        [self.contentView addSubview:_picker];
    }
    return _picker;
}

#pragma mark -Events
- (void)show:(NSString *)showString{
    if (_datePicker) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:_rType];
        NSDate *sDate = [formatter dateFromString:showString];
        if (sDate) {
            self.datePicker.date = sDate;
        }
    }else if (_picker){
        NSInteger index = [_pickerArray indexOfObject:showString];
        if (index != NSNotFound) {
            [_picker selectRow:index inComponent:0 animated:NO];
        }
    }
    [self show];
}


- (void)completeAction{
    [self dismiss];
    NSString *rString;
    if (_picker) {
        NSInteger row = [self.picker selectedRowInComponent:0];
        rString = _pickerArray[row]?:@"";
    }else if(_datePicker){
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        if (_rType) {
           [dateFormatter setDateFormat:_rType];
        }
        rString = [dateFormatter stringFromDate:_datePicker.date];
    }
    
    if (rString.length > 0) {
      _strBlock(rString);
    }
    
}

- (void)abolishAction{
    [self dismiss];
}

- (void)show{
    CGRect frame = self.contentView.frame;
    frame.origin.y -= C_Height;
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss{
    CGRect frame = self.contentView.frame;
    frame.origin.y += C_Height;
    [UIView animateWithDuration:0.25 animations:^{
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark -UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return _pickerArray.count;
}

#pragma mark - UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    return _pickerArray[row];
}


@end
