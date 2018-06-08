//
//  CommonMethods.h
//  SingleTest
//
//  Created by apple on 2018/5/19.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger , ChangeDateStyle) {
    ChangeTypeDay = 0,
    ChangeTypeWeek,
    ChangeTypeMonth,
    ChangeTypeYear,
};

typedef NS_ENUM(NSUInteger , DateStyle){
    DateStyleYMD = 0,
    DateStyleYMDHM = 1,
    DateStyleYMDHMS = 2,
    DateStyleYYYY = 3,
    //显示年份后两位
    DateStyleYY = 4,
    //显示成1~12，1位数或2位数
    DateStyleM = 5,
    //显示成01~12，不足2位数会补0
    DateStyleMM = 6,
    //英文月份的缩写，例如：Jan
    DateStyleMMM = 7,
    //英文月份完整显示，例如：January
    DateStyleMMMM = 8,
    //显示成1~31，1位数或2位数
    DateStyleD = 9,
    //显示成01~31，不足2位数会补0
    DateStyleDD = 10,
    //EEE：星期的英文缩写，如Sun
    DateStyleEEE = 11,
    //EEEE：星期的英文完整显示，如，Sunday
    DateStyleEEEE = 12,
    //aa：显示AM或PM
    DateStyleAA = 13,
    //-08:00
    DateStyleZZZZ = 14,
};


@interface CommonMethods : NSObject


#pragma mark -正则逻辑类判断
+(BOOL)isValidateEmail:(NSString *)email;
+ (BOOL)isPureInt:(NSString *)string;
//判断是否是正确的银行卡号实现
+ (BOOL) IsBankCard:(NSString *)cardNumber;

#pragma mark -MD5加密逻辑等
+ (NSString *) md5:(NSString *)input;

#pragma mark -字符串处理
//富文本类型
+ (NSMutableAttributedString *)disposeText:(NSString *)allText SelectText:(NSString *)selectText  Attribute:(NSDictionary *)dic;

#pragma mark -app各项属性
+(NSString*) getLocalAppVersion;
+(NSString*) getAppName;

#pragma mark -全局用字典赋值 用来解耦和
+ (id)object:(id)object setPropertyValues:(NSDictionary *)param;
+(BOOL)judgeObjValue:(id)obj;

#pragma mark - json转对象对象转json
//对象转换json
+ (NSString *)converToJsonData:(id)dict;
//json转对象
+ (id)converToObject:(NSString *)jsonStr;

#pragma mark - 时间操作模块
//UTC 转本地
+ (NSString *)UTCStrToLocationStr:(NSString *)UTCStr Style:(DateStyle)style;
//本地转UTC
+(NSString *)LocationStrToUTCStr:(NSString *)localString Style:(DateStyle)style;
//时间转字符串
+ (NSString *)dateToStringWithStyle:(DateStyle)style AndDate:(NSDate *)date;
//字符串转时间
+ (NSDate *)stringToDate:(DateStyle)style AndString:(NSString *)str;
//根据当前日期获取前一段时间和后一段时间  类型包括前一日 前一周  前一月 前一年
+ (NSDate *)getFrontAndBackWith:(id)date Style:(ChangeDateStyle)style isAdd:(BOOL)isAdd;
//根据当前日期获取开始和结束时间    类型包括 日  周 月 年
+ (NSArray *)getBeginTime:(id)today UnitType:(ChangeDateStyle)type;
#pragma mark -日历有关的

/*某个月多少天*/
+ (NSInteger)getDaysOfMonth:(NSDate *)date;
/*某个月份第一天*/
+(NSDate *)getFirstDayOfMonth:(NSDate *)date;
/*某个月第一个星期几*/
+ (NSUInteger)getWeeklyOrdinality:(NSDate *)date;
//获取时间具体信息
+ (NSDateComponents *)getDateComonent:(NSDate *)date;

#pragma mark -有关数组的操作
//获取数组总和
+ (NSNumber *)getSumNumFrom:(NSArray *)array;
//获取最大值
+ (NSNumber *)getMaxNumFrom:(NSArray *)array;
//获取最小值
+ (NSNumber *)getMinNumFrom:(NSArray *)array;
//获取平均
+ (NSNumber *)getAvgNumFrom:(NSArray *)array;
//按值大小正序排序
+ (NSArray *)ascendingOrderWith:(NSArray *)array;
//按值大小倒序排序
+ (NSArray *)descendingOrderWith:(NSArray *)array;
//位置反转
+ (NSArray *)reverseEnumeratorWith:(NSArray *)array;

#pragma mark -UI操作的
// 输入字数限制声明
+(void)limitInputNumberOfWordsWithMaxLength:(NSUInteger)maxLength  inputView:(id<UITextInput>)inputView inputString:(NSString *)string;
//生成二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size;
//label自适应
+ (CGSize )adaptive:(UILabel *)label WithSize:(CGSize )size;
//获取图片原比例  宽比高的比例
+ (CGFloat)scalesByImageView:(UIImageView *)imageView;
//给指定view 添加下划线
+ (void)addUnderlineToView:(UIView*)thisview Color:(UIColor *)color;
//截屏代码
+ (UIImage *)ScreenShot:(CGSize )size  View:(UIView *)view;
//颜色转图片
+(UIImage*)createImageWithColor:(UIColor*)color;
//截取view生成一张图片
+ (UIImage *)shotWithView:(UIView *)view;
//截取view中某个区域生成一张图片
+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope;

//传入两个图片 进行拼接  拼接rect 在方法内部，暂时先留着 将来做自定义
+ (UIImage *)combine:(UIImage*)leftImage :(UIImage*)rightImage;
+ (UIImage *)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r;

//画虚线   可分为横向和纵向的
+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal;
//添加高斯模糊
+ (void)addBurEffect:(UIView *)view;

#pragma mark -颜色处理
+ (UIColor *)colorWithHexString:(NSString *)color;

#pragma mark -文件类
//清楚缓存
+ (void)removeCache;
// 计算清除的缓存大小
+ (CGFloat)floatWithPath:(NSString *)path;
//计算单个文件大小
+ (long long)fileSizeAtPath:(NSString *)file;

@end
