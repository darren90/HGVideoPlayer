//
//  HGVideoPlayer+Utils.m
//  HGVideoPlayer
//
//  Created by Fengtf on 2018/4/15.
//

#import "HGVideoPlayer+Utils.h"

@implementation HGVideoPlayer (Utils)

@end


@implementation UIImage (Utils)

+ (UIImage *)hg_imageNamed:(NSString *)name {
    NSBundle *currentBundle = [NSBundle bundleForClass:[HGVideoPlayer class]];
    if (@available(iOS 8.0, *)) {
        return [UIImage imageNamed:name inBundle:currentBundle compatibleWithTraitCollection:nil];
    } else {
        // Fallback on earlier versions
        return [UIImage imageNamed:name];
    }
}

@end
