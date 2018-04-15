//
//  TFPlayerTools.h
//  FileMaster
//
//  Created by Tengfei on 2017/4/29.
//  Copyright © 2017年 tengfei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TFPlayerTools : NSObject

+(NSString *)timeToHumanString:(unsigned long)ms;

+(BOOL)isLocalMedia:(NSURL*)url;

+ (CGFloat)homeIndeicatrHeight;

+ (CGFloat)statusBarHeight;

@end
