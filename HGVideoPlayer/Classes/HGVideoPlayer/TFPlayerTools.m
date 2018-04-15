//
//  TFPlayerTools.m
//  FileMaster
//
//  Created by Tengfei on 2017/4/29.
//  Copyright © 2017年 tengfei. All rights reserved.
//

#import "TFPlayerTools.h"

@implementation TFPlayerTools

+ (NSString *)timeToHumanString:(unsigned long)ms {
    unsigned long seconds, h, m, s;
    char buff[128] = { 0 };
    NSString *nsRet = nil;
    
    seconds = ms ;
    h = seconds / 3600;
    m = (seconds - h * 3600) / 60;
    s = seconds - h * 3600 - m * 60;
    snprintf(buff, sizeof(buff), "%02ld:%02ld:%02ld", h, m, s);
    nsRet = [[NSString alloc] initWithCString:buff
                                     encoding:NSUTF8StringEncoding];
    
    return nsRet;
}

+ (BOOL)isLocalMedia:(NSURL*)url {
    static NSString * const local = @"/";
    static NSString * const local2 = @"file://localhost/";
    static NSString * const local3 = @"file://";
    static NSString * const iPod = @"ipod-library://";
    static NSString * const camera = @"assets-library://";
    
    NSString * urlStr = [url absoluteString];
    if ( [urlStr hasPrefix:local] ) return YES;
    if ( [urlStr hasPrefix:local2] ) return YES;
    if ( [urlStr hasPrefix:local3] ) return YES;
    if ( [urlStr hasPrefix:iPod] ) return YES;
    if ( [urlStr hasPrefix:camera] ) return YES;
    
    return NO;
}

+ (BOOL)iPhoneX {
    if (@available(iOS 11.0, *)){
        return [UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && (NSInteger)[UIScreen mainScreen].nativeBounds.size.height == 2436; //nativeBounds
    }
    return NO;
}

+ (CGFloat)homeIndeicatrHeight {
    return [self iPhoneX] ? 34 : 0;
}

+ (CGFloat)statusBarHeight {
    return [self iPhoneX] ? 44 : 20;
}


@end
