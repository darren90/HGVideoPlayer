//
//  HGViewController.m
//  HGVideoPlayer
//
//  Created by 1005052145@qq.com on 04/05/2018.
//  Copyright (c) 2018 1005052145@qq.com. All rights reserved.
//

#import "HGViewController.h"
#import "HGVideoPlayer.h"
//#import <KSYMediaPlayer/KSYMoviePlayerController.h>

@interface HGViewController ()

@property (nonatomic, strong) HGVideoPlayer *player;

@end

@implementation HGViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    self.player = [HGVideoPlayer new];
    [self.view addSubview:self.player.view];
    self.player.view.frame = CGRectMake(0, 100, self.view.frame.size.width,  self.view.frame.size.width * 9 / 16.0);
    self.player.view.backgroundColor = [UIColor blackColor];
    
    NSURL *url = [NSURL URLWithString:@"http://vt1.doubanio.com/201803041206/2638b33a68e24a758ad80259b4ce73ec/view/movie/M/302260486.mp4"];
    url = [NSURL URLWithString:@"http://vt1.doubanio.com/201804142120/35e0a1f54f3ad6653392a71e0d339621/view/movie/M/302250784.mp4"];
    url = [NSURL URLWithString:@"http://vt1.doubanio.com/201804142123/7968409c7b80dd22a42c5340630d68b9/view/movie/M/302260547.mp4"];
//    
    NSString *pathstr = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    pathstr = [pathstr stringByAppendingPathComponent:@"333.rmvb"];
//    url = [NSURL fileURLWithPath:pathstr];
    
    [self.player play:url title:@"" seekToPos:0];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
