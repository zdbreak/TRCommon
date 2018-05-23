//
//  CommonMethods.h
//  SingleTest
//
//  Created by apple on 2018/5/19.
//  Copyright © 2018年 thinkrace. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonMethods : NSObject
+ (NSString *)converToJsonData:(id)dict;

+ (id)converToObject:(NSString *)jsonStr;

@end
