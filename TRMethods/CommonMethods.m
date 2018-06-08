//
//  CommonMethods.m
//  SingleTest
//
//  Created by apple on 2018/5/19.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import "CommonMethods.h"
#import <CommonCrypto/CommonDigest.h>
#import <objc/runtime.h>

@implementation CommonMethods
//图片拼接技术
static void addRoundedRectToPath(CGContextRef context, CGRect rect, float ovalWidth, float ovalHeight){
    float fw, fh;
    if (ovalWidth == 0 || ovalHeight == 0){
        CGContextAddRect(context, rect);
        return;}
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight);
    fw = CGRectGetWidth(rect) / ovalWidth;
    fh = CGRectGetHeight(rect) / ovalHeight;
    
    CGContextMoveToPoint(context, fw, fh/2);  // Start at lower right corner
    CGContextAddArcToPoint(context, fw, fh, fw/2, fh, 1);  // Top right corner
    CGContextAddArcToPoint(context, 0, fh, 0, fh/2, 1); // Top left corner
    CGContextAddArcToPoint(context, 0, 0, fw/2, 0, 1); // Lower left corner
    CGContextAddArcToPoint(context, fw, 0, fw, fh/2, 1); // Back to lower right
    CGContextClosePath(context);
    CGContextRestoreGState(context);
}


#pragma mark -正则逻辑类判断
//判断邮箱格式
+(BOOL)isValidateEmail:(NSString *)email{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}
//判断是否为全部数字
+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}
//判断是否是正确的银行卡号实现
+ (BOOL) IsBankCard:(NSString *)cardNumber{
    if(cardNumber.length==0)return NO;
    NSString *digitsOnly = @"";
    char c;
    for (int i = 0; i < cardNumber.length; i++){
        c = [cardNumber characterAtIndex:i];
        if (isdigit(c)){
            digitsOnly =[digitsOnly stringByAppendingFormat:@"%c",c];
        }
    }
    int sum = 0;
    int digit = 0;
    int addend = 0;
    BOOL timesTwo = false;
    for (NSInteger i = digitsOnly.length - 1; i >= 0; i--){
        digit = [digitsOnly characterAtIndex:i] - '0';
        if (timesTwo){
            addend = digit * 2;
            if (addend > 9) {
                addend -= 9;
            }
        }else{
            addend = digit;
        }
        sum += addend;
        timesTwo = !timesTwo;
    }
    int modulus = sum % 10;
    return modulus == 0;
}

#pragma mark -MD5加密逻辑等
+ (NSString *) md5:(NSString *)input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int)strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    return  output;
  //  [output uppercaseString]?;
}

#pragma mark -字符串处理
//富文本类型
+ (NSMutableAttributedString *)disposeText:(NSString *)allText SelectText:(NSString *)selectText  Attribute:(NSDictionary *)dic{
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:allText];
    NSRange rang = [allText rangeOfString:selectText];
    if (rang.location != NSNotFound) {
        [string addAttributes:dic range:rang];
    }
    return string;
}

#pragma mark -app各项属性
+(NSString*)getLocalAppVersion{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

+(NSString*) getAppName{
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleDisplayName"];
}
#pragma mark -全局用字典赋值 用来解耦和
//全局赋值用
+ (id)object:(id)object setPropertyValues:(NSDictionary *)param{
    if (param && [param isKindOfClass:[NSDictionary class]]) {
        unsigned int outCount, i;
        objc_property_t *properties = class_copyPropertyList([object class], &outCount);
        for (i = 0; i < outCount; i++){
            objc_property_t property = properties[i];
            const char *char_f = property_getName(property);
            NSString *propertyName = [NSString stringWithUTF8String:char_f];
            id propertyValue = [param valueForKey:(NSString *)propertyName];
            if ([self judgeObjValue:propertyValue]){
                //缓存单实例到内存
                [object setValue:propertyValue forKey:propertyName];
            }
        }
        free(properties);
    }
    return object;
}

+(BOOL)judgeObjValue:(id)obj{
    if ([obj isEqual:[NSNull null]]) return NO;
    if ([obj isKindOfClass:[NSString class]]) {
        if ([(NSString *)obj isEqualToString:@""]) {
            return NO;
        }
        return YES;
    }
    if (!obj) return NO;
    return YES;
}


#pragma mark - json和类型的互转
//字典转json
+ (NSString *)converToJsonData:(id)dict{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString;
    if (!jsonData) {
        NSLog(@"%@",error);
    }else{
        jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    NSMutableString *mutStr =[NSMutableString stringWithString:jsonString];
    [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch  range:NSMakeRange(0, mutStr.length)];
    [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:NSMakeRange(0, mutStr.length)];
    return mutStr;
}
//json 转类型
+ (id)converToObject:(NSString *)jsonStr{
    if (jsonStr) {
        id tmp = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers  error:nil];
        if (tmp) {
            return tmp;
        }
    }
    return nil;
}

#pragma mark - 时间操作模块
+ (NSString *)getDateStyle:(DateStyle)style{
    //为了好看着对应，不用数组了
    NSDictionary *dic = @{@"0":@"yyyy-MM-dd",
                          @"1":@"yyyy-MM-dd HH:mm",
                          @"2":@"yyyy-MM-dd HH:mm:ss",
                          @"3":@"yy",
                          @"4":@"yyyy",
                          @"5":@"M",
                          @"6":@"MM",
                          @"7":@"MMM",
                          @"8":@"MMMM",
                          @"9":@"d",
                          @"10":@"dd",
                          @"11":@"EEE",
                          @"12":@"EEEE",
                          @"13":@"aa",
                          @"14":@"ZZZZ",
                          };
    NSString *key = [NSString stringWithFormat:@"%lu",(unsigned long)style];
    return dic[key];
}
//UTC字符串转本地字符串
+ (NSString *)UTCStrToLocationStr:(NSString *)UTCStr Style:(DateStyle)style{
    NSDate *date = [[NSDate alloc] init];
    NSString *Str = [[NSString alloc]init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:[self getDateStyle:style]];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    date = [dateFormatter dateFromString:UTCStr];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    Str = [dateFormatter stringFromDate:date];
    return  Str;
}

//本地字符串转UTC 一般用来上传服务器用
+(NSString *)LocationStrToUTCStr:(NSString *)localString Style:(DateStyle)style{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[self getDateStyle:style]];
    NSDate *dateFormatted = [dateFormatter dateFromString:localString];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:[self getDateStyle:style]];
    NSString *dateString = [dateFormatter stringFromDate:dateFormatted];
    return dateString;
}

//时间转字符串
+ (NSString *)dateToStringWithStyle:(DateStyle)style AndDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:[self getDateStyle:style]];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

//字符串转时间
+ (NSDate *)stringToDate:(DateStyle)style AndString:(NSString *)str{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:[self getDateStyle:style]];
    NSDate *date=[dateFormatter dateFromString:str];
    return date;
}

//根据日周月年不同格式  获取开始和结束范围时间  开始放在前边 结束放在后边
+ (NSArray *)getBeginTime:(id)today UnitType:(ChangeDateStyle)type{
    double interval = 0;
    NSDate *beginDate = nil;
    NSDate *endDate = nil;
    if ([today isKindOfClass:[NSString class]]){
        //这里为了方便 默认年月日
        today = [self stringToDate:DateStyleYMD AndString:today];
    }
    if (today == nil) {today = [NSDate date];}
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setFirstWeekday:2];//设定周一为周首日
    NSUInteger unit = 0;
    switch (type) {
        case ChangeTypeDay:unit = NSCalendarUnitDay;break;
        case ChangeTypeWeek:unit = NSCalendarUnitWeekOfYear;break;
        case ChangeTypeMonth:unit = NSCalendarUnitMonth;break;
        case ChangeTypeYear:unit = NSCalendarUnitYear;break;
        default:break;}
    BOOL ok = [calendar rangeOfUnit:unit startDate:&beginDate interval:&interval forDate:today];
    if (ok) {
        endDate = [beginDate dateByAddingTimeInterval:interval - 1];
    }else{return nil;}
    return @[beginDate,endDate];
}

+ (NSDate *)getFrontAndBackWith:(id)date Style:(ChangeDateStyle)style isAdd:(BOOL)isAdd{
    if ([date isKindOfClass:[NSString class]]) {
        date = [self stringToDate:DateStyleYMD AndString:date];
    }
    if (!date) {date = [NSDate date];}
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    NSInteger index;
    if (isAdd) {index = +1;}else{index = -1;}
    switch (style){
        case ChangeTypeDay:{dateComponents.day = index;}break;
        case ChangeTypeWeek:{dateComponents.weekOfYear = index;}break;
        case ChangeTypeMonth:{dateComponents.month = index;}break;
        case ChangeTypeYear:{dateComponents.year = index;}break;
        default: break;
    }
    NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

#pragma mark -日历有关的
/*某个月多少天*/
+(NSInteger)getDaysOfMonth:(NSDate *)date{
    return [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
}

/*某个月份第一天*/
+(NSDate *)getFirstDayOfMonth:(NSDate *)date{
    NSDate *startDate = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:date];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return startDate;
}

/*某个月第一个星期几*/
+ (NSUInteger)getWeeklyOrdinality:(NSDate *)date{
    NSDate *startDate = nil;
    BOOL ok = [[NSCalendar currentCalendar] rangeOfUnit:NSCalendarUnitMonth startDate:&startDate interval:NULL forDate:date];
    NSAssert1(ok, @"Failed to calculate the first day of the month based on %@", self);
    return [[NSCalendar currentCalendar] ordinalityOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitWeekOfYear forDate:startDate];
}
//获取时间具体信息
+ (NSDateComponents *)getDateComonent:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:date];
    return dateComponent;
}

#pragma mark -有关数组的操作
//返回数组的数值和
+ (NSNumber *)getSumNumFrom:(NSArray *)array{
    if (array.count == 0 || !array) {return @0;}
    NSNumber *sum = [array valueForKeyPath:@"@sum.floatValue"];
    return sum;
}
//返回数组的最大值
+ (NSNumber *)getMaxNumFrom:(NSArray *)array{
    if (array.count == 0 || !array) {return @0;}
    NSNumber *max = [array valueForKeyPath:@"@max.floatValue"];
    return max;
}
//-返回数组的最小值
+ (NSNumber *)getMinNumFrom:(NSArray *)array{
    if (array.count == 0 || !array) {return @0;}
    NSNumber *min = [array valueForKeyPath:@"@min.floatValue"];
    return min;
}
//返回数组的平均值
+ (NSNumber *)getAvgNumFrom:(NSArray *)array{
    if (array.count == 0 || !array) {return @0;}
    NSNumber *avg = [array valueForKeyPath:@"@avg.floatValue"];
    return avg;
}
//根据数组的值进行正序排序
+ (NSArray *)ascendingOrderWith:(NSArray *)array{
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedDescending;
        }else if ([obj1 integerValue] < [obj2 integerValue]){
            return NSOrderedAscending;
        }
        return NSOrderedSame;
        //如果是nsnumber类型的 可以用边的判断
        //   return [obj1 compare:obj2];
    }];
    return result;
}
//根据数组的值进行倒序排序
+ (NSArray *)descendingOrderWith:(NSArray *)array{
    NSArray *result = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        if ([obj1 integerValue] > [obj2 integerValue]) {
            return NSOrderedAscending;
        }else if ([obj1 integerValue] < [obj2 integerValue]){
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    return result;
}
//对数组的位置顺序进行反排列
+ (NSArray *)reverseEnumeratorWith:(NSArray *)array{
    return [[array reverseObjectEnumerator]allObjects];
}

#pragma mark -UI操作的
 // 输入字数限制声明
+(void)limitInputNumberOfWordsWithMaxLength:(NSUInteger)maxLength  inputView:(id<UITextInput>)inputView inputString:(NSString *)string{
    //获取高亮部分
    UITextRange *selectedRange = [inputView markedTextRange];
    UITextPosition *position = [inputView positionFromPosition:selectedRange.start offset:0];
    if (!position || !selectedRange) {
        if (string.length > maxLength) {
            NSRange range1 = [string rangeOfComposedCharacterSequenceAtIndex:maxLength];
            if (range1.length == 1) {
                if ([inputView isKindOfClass:[UITextField class]]) {//textfield
                    UITextField *field = (UITextField *)inputView;
                    field.text = [string substringToIndex:maxLength];
                }else if([inputView isKindOfClass:[UITextView class]]){
                    UITextView *textView = (UITextView *)inputView;
                    textView.text = [string substringToIndex:maxLength];
                }
            }else{
                NSRange range2 = [string rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, maxLength)];
                if ([inputView isKindOfClass:[UITextField class]]) {
                    //textfield
                    UITextField *field = (UITextField *)inputView;
                    field.text = [string substringWithRange:range2];
                }else if([inputView isKindOfClass:[UITextView class]]){
                    UITextView *textView = (UITextView *)inputView;
                    textView.text = [string substringWithRange:range2];
                }
            }
        }
    }
}

//生成二维码
+ (UIImage *)encodeQRImageWithContent:(NSString *)content size:(CGSize)size {
    UIImage *codeImage = nil;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0f){
        NSData *stringData = [content dataUsingEncoding: NSUTF8StringEncoding];
        //生成
        CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
        [qrFilter setValue:stringData forKey:@"inputMessage"];
        [qrFilter setValue:@"M" forKey:@"inputCorrectionLevel"];
        UIColor *onColor = [UIColor blackColor];
        UIColor *offColor = [UIColor clearColor];
        //上色
        CIFilter *colorFilter = [CIFilter filterWithName:@"CIFalseColor"
                                           keysAndValues:
                                 @"inputImage",qrFilter.outputImage,
                                 @"inputColor0",[CIColor colorWithCGColor:onColor.CGColor],
                                 @"inputColor1",[CIColor colorWithCGColor:offColor.CGColor],
                                 nil];
        CIImage *qrImage = colorFilter.outputImage;
        CGImageRef cgImage = [[CIContext contextWithOptions:nil] createCGImage:qrImage fromRect:qrImage.extent];
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetInterpolationQuality(context, kCGInterpolationNone);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextDrawImage(context, CGContextGetClipBoundingBox(context), cgImage);
        codeImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        CGImageRelease(cgImage);
    } else {}
    return codeImage;
}

//Label获取自适应宽高
+ (CGSize )adaptive:(UILabel *)label WithSize:(CGSize )size{
    CGSize leftSize=[label.text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:label.font,NSFontAttributeName, nil] context:nil].size;
    return leftSize;
}
//获取图片原比例  宽比高的比例
+ (CGFloat)scalesByImageView:(UIImageView *)imageView{
    CGSize scanSize = [imageView intrinsicContentSize];
    CGFloat scales = scanSize.width/scanSize.height;
    return scales;
}

//给指定view 添加下划线
+ (void)addUnderlineToView:(UIView*)thisview Color:(UIColor *)color{
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.frame = CGRectMake(0.0f, thisview.bounds.origin.y+thisview.bounds.size.height-2, thisview.bounds.size.width, 1.0f);
    bottomBorder.backgroundColor = color?color.CGColor:[UIColor grayColor].CGColor;
    [thisview.layer addSublayer:bottomBorder];
}
//截屏
+ (UIImage *)ScreenShot:(CGSize )size  View:(UIView *)view{
    UIGraphicsBeginImageContextWithOptions(size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//颜色转图片
+(UIImage*)createImageWithColor:(UIColor*)color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

//截取view生成一张图片
+ (UIImage *)shotWithView:(UIView *)view{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

//截取view中某个区域生成一张图片
+ (UIImage *)shotWithView:(UIView *)view scope:(CGRect)scope{
    CGImageRef imageRef = CGImageCreateWithImageInRect([self shotWithView:view].CGImage, scope);
    UIGraphicsBeginImageContext(scope.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect rect = CGRectMake(0, 0, scope.size.width, scope.size.height);
    CGContextTranslateCTM(context, 0, rect.size.height);//下移
    CGContextScaleCTM(context, 1.0f, -1.0f);//上翻
    CGContextDrawImage(context, rect, imageRef);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRelease(imageRef);
    CGContextRelease(context);
    return image;
}

//传入两个图片 进行拼接  拼接rect 在方法内部，暂时先留着 将来做自定义
+ (UIImage *)combine:(UIImage*)leftImage :(UIImage*)rightImage {
    CGFloat width = leftImage.size.width;
    CGFloat height = leftImage.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    // UIGraphicsBeginImageContext(offScreenSize);
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    CGRect rect = CGRectMake(0, 0, width, height);
    [leftImage drawInRect:rect];
    
    rect.origin.x = width *0.15;
    rect.origin.y = height *0.04;
    rect.size.width = width *0.7;
    rect.size.height = width *0.7;
    [[self createRoundedRectImage:rightImage size:CGSizeMake(100, 100) radius:50] drawInRect:rect];
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imagez;
}

+ (UIImage *)createRoundedRectImage:(UIImage*)image size:(CGSize)size radius:(NSInteger)r{
    // the size of CGContextRef
    int w = size.width;
    int h = size.height;
    UIImage *img = image;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, r, r);
    CGContextClosePath(context);
    CGContextClip(context);
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), img.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    img = [UIImage imageWithCGImage:imageMasked];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    return img;
}
//画虚线   可分为横向和纵向的
+ (void)drawLineOfDashByCAShapeLayer:(UIView *)lineView lineLength:(int)lineLength lineSpacing:(int)lineSpacing lineColor:(UIColor *)lineColor lineDirection:(BOOL)isHorizonal {
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    [shapeLayer setBounds:lineView.bounds];
    if (isHorizonal) {
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame))];
    } else{
        [shapeLayer setPosition:CGPointMake(CGRectGetWidth(lineView.frame) / 2, CGRectGetHeight(lineView.frame)/2)];
    }
    [shapeLayer setFillColor:[UIColor clearColor].CGColor];
    //  设置虚线颜色为blackColor
    [shapeLayer setStrokeColor:lineColor.CGColor];
    //  设置虚线宽度
    if (isHorizonal) {
        [shapeLayer setLineWidth:CGRectGetHeight(lineView.frame)];
    } else {
        [shapeLayer setLineWidth:CGRectGetWidth(lineView.frame)];
    }
    [shapeLayer setLineJoin:kCALineJoinRound];
    //  设置线宽，线间距
    [shapeLayer setLineDashPattern:[NSArray arrayWithObjects:[NSNumber numberWithInt:lineLength], [NSNumber numberWithInt:lineSpacing], nil]];
    //  设置路径
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, 0, 0);
    if (isHorizonal) {
        CGPathAddLineToPoint(path, NULL,CGRectGetWidth(lineView.frame), 0);
    }else{
        CGPathAddLineToPoint(path, NULL, 0, CGRectGetHeight(lineView.frame));
    }
    [shapeLayer setPath:path];
    CGPathRelease(path);
    //  把绘制好的虚线添加上来
    [lineView.layer addSublayer:shapeLayer];
}

+ (void)addBurEffect:(UIView *)view{
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    effectView.frame = view.bounds;
    [view addSubview:effectView];
}
#pragma mark -颜色处理
//十六进制转颜色
+ (UIColor *)colorWithHexString:(NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

#pragma mark -文件类
+ (void)removeCache{
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSLog(@"%@",cachePath);
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:cachePath];
    for (NSString *p in files) {
        NSString *path = [NSString stringWithFormat:@"%@/%@", cachePath, p];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        }
    }
}
// 计算清除的缓存大小
+ (CGFloat)floatWithPath:(NSString *)path{
    CGFloat num = 0;
    NSFileManager *man = [NSFileManager defaultManager];
    if ([man fileExistsAtPath:path]) {
        NSEnumerator *childFile = [[man subpathsAtPath:path] objectEnumerator];
        NSString *fileName;
        while ((fileName = [childFile nextObject]) != nil) {
            NSString *fileSub = [path stringByAppendingPathComponent:fileName];
            num += [self fileSizeAtPath:fileSub];
        }
    }
    return num / (1024.0 * 1024.0);
}
//计算单个文件大小
+ (long long)fileSizeAtPath:(NSString *)file{
    NSFileManager *man = [NSFileManager defaultManager];
    if ([man fileExistsAtPath:file]) {
        return [[man attributesOfItemAtPath:file error:nil] fileSize];
    }
    return 0;
}

@end
