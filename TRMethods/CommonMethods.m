//
//  CommonMethods.m
//  SingleTest
//
//  Created by apple on 2018/5/19.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import "CommonMethods.h"

@implementation CommonMethods
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

+ (id)converToObject:(NSString *)jsonStr{
    if (jsonStr) {
        id tmp = [NSJSONSerialization JSONObjectWithData:[jsonStr dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments | NSJSONReadingMutableLeaves | NSJSONReadingMutableContainers  error:nil];
        if (tmp) {
            return tmp;
        }
    }
    return nil;
}

@end
