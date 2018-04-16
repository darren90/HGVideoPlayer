//
//  HGVideoPlayer.h
//  HGVideoPlayer
//
//  Created by Fengtf on 2018/4/5.
//

#import <Foundation/Foundation.h>
#import "HGVideoPlayerView.h"
//#import "KSYMoviePlayerController.h"
//#import "KSYMoviePlayerController.h"
//@import KSYMoviePlayerController.h
#import <KSYMediaPlayer/KSYMoviePlayerController.h>
//#import <KSYMediaPlayer.framework/KSYMoviePlayerController.h>

//#import <ks>

typedef enum {
    HGVideoPlayerStateUnknown,
    HGVideoPlayerStateContentLoading,
    HGVideoPlayerStateContentPlaying,
    HGVideoPlayerStateContentPaused,
    HGVideoPlayerStateSuspend,
    HGVideoPlayerStateDismissed,
    HGVideoPlayerStateError
} HGVideoPlayerState;

typedef enum {
    HGVideoPlayerControlEventTapPlayerView,
    HGVideoPlayerControlEventTapNext,
    HGVideoPlayerControlEventTapPrevious,
    HGVideoPlayerControlEventTapDone,
    HGVideoPlayerControlEventTapFullScreen,
    HGVideoPlayerControlEventTapCaption,
    HGVideoPlayerControlEventTapVideoQuality,
    HGVideoPlayerControlEventSwipeNext,
    HGVideoPlayerControlEventSwipePrevious,
    HGVideoPlayerControlEventShare,//分享
    HGVideoPlayerControlEventPause,//暂停
    HGVideoPlayerControlEventPlay,//播放
} HGVideoPlayerControlEvent;


@class HGVideoPlayer;
@protocol HGVideoPlayerDelegate <NSObject>

@optional
- (BOOL)shouldVideoPlayer:(HGVideoPlayer *)videoPlayer changeStateTo:(HGVideoPlayerState)toState;
- (void)videoPlayer:(HGVideoPlayer *)videoPlayer willChangeStateTo:(HGVideoPlayerState)toState;
- (void)videoPlayer:(HGVideoPlayer *)videoPlayer didChangeStateFrom:(HGVideoPlayerState)fromState;

- (void)videoPlayer:(HGVideoPlayer *)videoPlayer didControlByEvent:(HGVideoPlayerControlEvent)event;
- (void)videoPlayer:(HGVideoPlayer *)videoPlayer didChangeSubtitleFrom:(NSString*)fronLang to:(NSString*)toLang;
- (void)videoPlayer:(HGVideoPlayer *)videoPlayer willChangeOrientationTo:(UIInterfaceOrientation)orientation;
- (void)videoPlayer:(HGVideoPlayer *)videoPlayer didChangeOrientationFrom:(UIInterfaceOrientation)orientation;

@end


@interface HGVideoPlayer : NSObject

+ (HGVideoPlayer *) sharedPlayer;

@property (nonatomic, strong) HGVideoPlayerView *view;

@property (strong, nonatomic) KSYMoviePlayerController *mPlayer;

@property (nonatomic, weak) id<HGVideoPlayerDelegate> delegate;

@property (nonatomic,strong) NSURL *playUrl;

@property (nonatomic,copy) NSString *title;

@property (nonatomic, assign) HGVideoPlayerShowState showState;

@property (nonatomic,assign)BOOL isPlayLocalFile;

/**
 * 是否是软解码 默认软解码
 */
@property (nonatomic, assign) BOOL isSoftwareDecoderMode;

/**
 * 视频总时间 单位：秒s
 */
@property (nonatomic,assign)double totalDuraion;

/**
 * 视频当前播放到那个时间 单位：秒s
 */
@property (nonatomic, assign, readonly) double currentDuation;

/**
 * 正在播放的过程中切换了播放地址，进行播放的时候用这个  时间：秒
 */
-(void)play:(NSURL *)url title:(NSString *)title seekToPos:(long)pos;

/**
 * 数组播放，urls：NSString或者NSURL均可以
 */
-(void)playUrls:(NSArray *)urls title:(NSString *)title seekToPos:(long)pos;

/**
 * 播放
 */
- (void)playContent;

/**
 * 暂停
 */
- (void)pauseContent;

#pragma mark - 卸载播放器
-(void)unInstallPlayer;

-(void)playerWillAppear;
-(void)playerDidDisAppear;


@end
