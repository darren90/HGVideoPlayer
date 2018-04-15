//
//  HGVideoPlayer.m
//  HGVideoPlayer
//
//  Created by Fengtf on 2018/4/5.
//

#import "HGVideoPlayer.h"
//#import <KSYMediaPlayer/KSYMoviePlayerController.h>
#import "TFPlayerTools.h"
//#import "KSYMoviePlayerDefines.h"
//#import <KSYMediaPlayer/KSYMoviePlayerController.h>
//#import "KSYMoviePlayerController.h"

@interface HGVideoPlayer () <HGVideoPlayerViewDelegate>

@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, assign) BOOL progressDragging;

/** 上一次的观看时间 单位：秒 */
@property (nonatomic,assign) long lastWatchPos;

//音轨的数组
@property (nonatomic,strong) NSMutableArray * trackArray;

/** 是否在进入后台前是播放的播放 */
@property (nonatomic,assign) BOOL isBeforePlaying;

//我增加的字段，以便播放本地视频的时候视频不受打扰
//@property (nonatomic,assign) BOOL isPlayLocalFile;

@end

@implementation HGVideoPlayer

-(void)playerWillAppear {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self.view becomeFirstResponder];
}

-(void)playerDidDisAppear {
    [[UIApplication sharedApplication] endReceivingRemoteControlEvents];
    [self.view resignFirstResponder];
}

- (id)init {
    self = [super init];
    if (self) {
        self.view = [HGVideoPlayerView videoPlayerView];
        [self initialize];
    }
    return self;
}

- (void)setShowState:(HGVideoPlayerShowState)showState {
    _showState = showState;
    self.view.showState = showState;
}

#pragma mark - initialize

- (void)initialize {
    self.view.delegate = self;
    if (!_mPlayer) {
        self.showState = HGVideoPlayerSmall;
        _mPlayer = [[KSYMoviePlayerController alloc] initWithContentURL:nil fileList:nil sharegroup:nil];
        [self setupObservers:_mPlayer];
        _mPlayer.controlStyle = MPMovieControlStyleNone;
        [_mPlayer.view setFrame: self.view.bounds];  // player's frame must match parent's
//        [self.view addSubview: _mPlayer.view];
        [self.view insertSubview:_mPlayer.view atIndex:0];
        self.view.autoresizesSubviews = true;
        _mPlayer.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        //设置播放参数
        _mPlayer.videoDecoderMode = MPMovieVideoDecoderMode_Software;
        _mPlayer.scalingMode = MPMovieScalingModeNone;
        _mPlayer.shouldAutoplay = YES;
        _mPlayer.deinterlaceMode = MPMovieVideoDeinterlaceMode_Auto;
        _mPlayer.shouldLoop = NO;
        _mPlayer.bInterruptOtherAudio = YES;
        _mPlayer.bufferTimeMax = 3600;
        _mPlayer.bufferSizeMax = 100;
        [_mPlayer setTimeout:100 readTimeout:100];
        
        NSKeyValueObservingOptions opts = NSKeyValueObservingOptionNew;
        [_mPlayer addObserver:self forKeyPath:@"currentPlaybackTime" options:opts context:nil];
        [_mPlayer addObserver:self forKeyPath:@"clientIP" options:opts context:nil];
        [_mPlayer addObserver:self forKeyPath:@"localDNSIP" options:opts context:nil];
//        [self addObserver:self forKeyPath:@"mPlayer" options:NSKeyValueObservingOptionNew context:nil];
//        prepared_time = (long long int)([self getCurrentTime] * 1000);
        [_mPlayer prepareToPlay];
    }
}

-(void)playUrls:(NSArray *)urls title:(NSString *)title seekToPos:(long)pos {

}

- (void)setPlayUrl:(NSURL *)playUrl {
    _playUrl = playUrl;
    
    [self play:playUrl title:self.title seekToPos:0];
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.view.titleLabel.text = title;
}

-(void)play:(NSURL *)url title:(NSString *)title seekToPos:(long)pos {
    self.title = title;
    [self quicklyStopMovie];
    if (pos > 5)  pos -= 5;//时间自动向前5秒，提升用户体验
    self.lastWatchPos = pos;//lastWatchPos：秒，pos：毫秒   -- 1秒=1000毫秒
    
    [self.mPlayer setUrl:url];
    [self.mPlayer prepareToPlay];
    [self.view startActivityWithMsg:@"Loading..."];
}


-(void)quicklyStopMovie {
    self.view.progressSld.value = 0.0;
    self.view.progressSld.value = 0.0;
    self.view.curPosLabel.text = @"00:00:00";
    self.view.durationLabel.text = @"00:00:00";
    self.view.bubbleMsgLabel.text = nil;
    [self.view stopActivity];
    [self.view setBtnEnableStatus:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    self.lastWatchPos = 0;
}

-(void)syncUIStatus {
    if (!self.progressDragging) {
        CGFloat progress = _mPlayer.currentPlaybackTime / _mPlayer.duration;
        [self.view.progressSld setValue:progress animated:YES];
        self.view.curPosLabel.text = [TFPlayerTools timeToHumanString: _mPlayer.currentPlaybackTime];
        self.view.durationLabel.text = [TFPlayerTools timeToHumanString:_mPlayer.duration];
    }
}

- (void)registerObserver:(NSString *)notification player:(KSYMoviePlayerController*)player {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handlePlayerNotify:) name:(notification) object:player];
}

- (void)setupObservers:(KSYMoviePlayerController*)player {
    [self registerObserver:MPMediaPlaybackIsPreparedToPlayDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStateDidChangeNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackDidFinishNotification player:player];
    [self registerObserver:MPMoviePlayerLoadStateDidChangeNotification player:player];
    [self registerObserver:MPMovieNaturalSizeAvailableNotification player:player];
    [self registerObserver:MPMoviePlayerFirstVideoFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerFirstAudioFrameRenderedNotification player:player];
    [self registerObserver:MPMoviePlayerSuggestReloadNotification player:player];
    [self registerObserver:MPMoviePlayerPlaybackStatusNotification player:player];
    [self registerObserver:MPMoviePlayerNetworkStatusChangeNotification player:player];
    [self registerObserver:MPMoviePlayerSeekCompleteNotification player:player];
    
    NSNotificationCenter *def = [NSNotificationCenter defaultCenter];
    [def addObserver:self selector:@selector(applicationDidEnterForeground:) name:UIApplicationDidBecomeActiveNotification object:[UIApplication sharedApplication]];
    [def addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationWillResignActiveNotification object:[UIApplication sharedApplication]];
}

- (void)releaseObservers:(KSYMoviePlayerController *)player {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidEnterForeground:(NSNotification *)notification {
    if (![self.mPlayer isPlaying]) {
        if (self.isBeforePlaying) {
            self.isBeforePlaying = NO;
            [self.mPlayer play];//视频不再自动播放
            [self.view setPlayButtonsSelected:NO];
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    if ([self.mPlayer isPlaying]) {
        [self.mPlayer pause];
        [self.view setPlayButtonsSelected:YES];//设置按钮的状态
        self.isBeforePlaying = YES;
    }
}

- (void)onQuit:(id)sender {
    if(_mPlayer) {
        [_mPlayer stop];
        [_mPlayer removeObserver:self forKeyPath:@"currentPlaybackTime" context:nil];
        [_mPlayer removeObserver:self forKeyPath:@"clientIP" context:nil];
        [_mPlayer removeObserver:self forKeyPath:@"localDNSIP" context:nil];
        [self releaseObservers:_mPlayer];
        [_mPlayer.view removeFromSuperview];
        _mPlayer = nil;
    }
}


#pragma mark kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqual:@"currentPlaybackTime"]) {
//        progressView.playProgress = _player.currentPlaybackTime / _player.duration;
         self.progressDragging = NO;
        [self syncUIStatus];
    } else if([keyPath isEqual:@"clientIP"]) {
        NSLog(@"client IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    } else if([keyPath isEqual:@"localDNSIP"]) {
        NSLog(@"local DNS IP is %@\n", [change objectForKey:NSKeyValueChangeNewKey]);
    }  else if ([keyPath isEqualToString:@"mPlayer"]) {
//        if (_player) {
//            progressView.hidden = NO;
//            __weak typeof(_player) weakPlayer = _player;
//            progressView.dragingSliderCallback = ^(float progress){
//                typeof(weakPlayer) strongPlayer = weakPlayer;
//                double seekPos = progress * strongPlayer.duration;
//                //strongPlayer.currentPlaybackTime = progress * strongPlayer.duration;
//                //使用currentPlaybackTime设置为依靠关键帧定位
//                //使用seekTo:accurate并且将accurate设置为YES时为精确定位
//                [strongPlayer seekTo:seekPos accurate:YES];
//            };
//        } else {
//            progressView.hidden = YES;
//        }
    }
}

- (void)readyToPlay{
    [self.view setPlayButtonsSelected:NO];//设置按钮的状态
    
    [self.view setBtnEnableStatus:YES];
    [self.view stopActivity];
}

#pragma mark - NSNotification

-(void)handlePlayerNotify:(NSNotification *)notify {
    if (!_mPlayer) { return; }
    
    if (MPMediaPlaybackIsPreparedToPlayDidChangeNotification ==  notify.name) {
        [self readyToPlay];
        self.view.durationLabel.text = [TFPlayerTools timeToHumanString:_mPlayer.duration];
        if(_mPlayer.shouldAutoplay == YES) {
            [_mPlayer seekTo:self.lastWatchPos accurate:NO];
            [_mPlayer play];
        }
    }
    if (MPMoviePlayerPlaybackStateDidChangeNotification ==  notify.name) {
        NSLog(@"------------------------");
        NSLog(@"player playback state: %ld", (long)_mPlayer.playbackState);
        NSLog(@"------------------------");
    }
    if (MPMoviePlayerLoadStateDidChangeNotification ==  notify.name) {
         self.progressDragging = YES;
        NSLog(@"player load state: %ld", (long)_mPlayer.loadState);
        if (MPMovieLoadStateStalled & _mPlayer.loadState) {
            NSLog(@"player start caching");
            [self.view stopActivity];
        }
        if (_mPlayer.bufferEmptyCount &&
            (MPMovieLoadStatePlayable & _mPlayer.loadState ||
             MPMovieLoadStatePlaythroughOK & _mPlayer.loadState)){
                NSLog(@"player finish caching");
                NSString *message = [[NSString alloc]initWithFormat:@"loading occurs, %d - %0.3fs",
                                     (int)_mPlayer.bufferEmptyCount,
                                     _mPlayer.bufferEmptyDuration];
                NSLog(@"--caching message: %@", message);
//                [self toast:message];
                //缓冲
            }
    }
    if (MPMoviePlayerPlaybackDidFinishNotification ==  notify.name) {
        NSLog(@"player finish state: %ld", (long)_mPlayer.playbackState);
        NSLog(@"player download flow size: %f MB", _mPlayer.readSize);
        NSLog(@"buffer monitor  result: \n   empty count: %d, lasting: %f seconds",
              (int)_mPlayer.bufferEmptyCount,
              _mPlayer.bufferEmptyDuration);
    }
    if (MPMovieNaturalSizeAvailableNotification ==  notify.name) {
        NSLog(@"video size %.0f-%.0f, rotate:%ld\n", _mPlayer.naturalSize.width, _mPlayer.naturalSize.height, (long)_mPlayer.naturalRotate);
        if(((_mPlayer.naturalRotate / 90) % 2  == 0 && _mPlayer.naturalSize.width > _mPlayer.naturalSize.height) ||
           ((_mPlayer.naturalRotate / 90) % 2 != 0 && _mPlayer.naturalSize.width < _mPlayer.naturalSize.height))
        {
            //如果想要在宽大于高的时候横屏播放，你可以在这里旋转
        }
    }
    if (MPMoviePlayerFirstVideoFrameRenderedNotification == notify.name)  {
//        fvr_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);
//        NSLog(@"first video frame show, cost time : %dms!\n", fvr_costtime);
    }
    if (MPMoviePlayerFirstAudioFrameRenderedNotification == notify.name) {
//        far_costtime = (int)((long long int)([self getCurrentTime] * 1000) - prepared_time);
//        NSLog(@"first audio frame render, cost time : %dms!\n", far_costtime);
    }
    if (MPMoviePlayerSuggestReloadNotification == notify.name) {
        NSLog(@"suggest using reload function!\n");
    }
    
    if(MPMoviePlayerPlaybackStatusNotification == notify.name) {
        int status = [[[notify userInfo] valueForKey:MPMoviePlayerPlaybackStatusUserInfoKey] intValue];
        if(MPMovieStatusVideoDecodeWrong == status)
            NSLog(@"Video Decode Wrong!\n");
        else if(MPMovieStatusAudioDecodeWrong == status)
            NSLog(@"Audio Decode Wrong!\n");
        else if (MPMovieStatusHWCodecUsed == status )
            NSLog(@"Hardware Codec used\n");
        else if (MPMovieStatusSWCodecUsed == status )
            NSLog(@"Software Codec used\n");
        else if(MPMovieStatusDLCodecUsed == status)
            NSLog(@"AVSampleBufferDisplayLayer  Codec used");
    }
    
    if(MPMoviePlayerNetworkStatusChangeNotification == notify.name) {
        int currStatus = [[[notify userInfo] valueForKey:MPMoviePlayerCurrNetworkStatusUserInfoKey] intValue];
        int lastStatus = [[[notify userInfo] valueForKey:MPMoviePlayerLastNetworkStatusUserInfoKey] intValue];
        NSLog(@"network reachable change from %@ to %@\n", [self netStatus2Str:lastStatus], [self netStatus2Str:currStatus]);
    }
    
    if(MPMoviePlayerSeekCompleteNotification == notify.name) {
        NSLog(@"Seek complete");
        [self.view stopActivity];
    }
}


- (NSString *) netStatus2Str:(KSYNetworkStatus)networkStatus{
    NSString *netString = nil;
    if(networkStatus == KSYNotReachable)
        netString = @"NO INTERNET";
    else if(networkStatus == KSYReachableViaWiFi)
        netString = @"WIFI";
    else if(networkStatus == KSYReachableViaWWAN)
        netString = @"WWAN";
    else
        netString = @"Unknown";
    return netString;
}

- (void)setIsSoftwareDecoderMode:(BOOL)isSoftwareDecoderMode {
    _isSoftwareDecoderMode = isSoftwareDecoderMode;
    self.mPlayer.videoDecoderMode = self.isSoftwareDecoderMode ? MPMovieVideoDecoderMode_Software : MPMovieVideoDecoderMode_Hardware;
}

#pragma mark - HGVideoPlayerViewDelegate 方法

- (void)playButtonPressed {
    [self.mPlayer play];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:HGVideoPlayerControlEventPlay];
    }
}

- (void)pauseButtonPressed {
    [self.mPlayer pause];
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:HGVideoPlayerControlEventPause];
    }
}

- (void)doneButtonTapped {
    if (self.showState != HGVideoPlayerFull) {
        [self unInstallPlayer];
        [self.mPlayer stop];
    }
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:HGVideoPlayerControlEventTapDone];
    }
}

- (void)playerViewSingleTapped {
    
}

- (void)fulllScrenAction {
    if ([self.delegate respondsToSelector:@selector(videoPlayer:didControlByEvent:)]) {
        [self.delegate videoPlayer:self didControlByEvent:HGVideoPlayerControlEventTapFullScreen];
    }
}

-(void)switchVideoViewModeButtonAction {
    
}

#pragma mark - 右上和右下的几个按钮被点击

- (void)shareButtonTapped {//点击分享按钮

}

//进度条相关

-(void)progressSliderUp:(float)value {
    NSLog(@"-progressSliderUp-:%@",@(value));
    [self.view startActivityWithMsg:@"Buffering"];
    [self.mPlayer seekTo:(long)(value * self.mPlayer.duration) accurate:YES];
    if (!self.mPlayer.isPlaying) {//没有播放的时候，拖动进度条后，进行播放
        [self.mPlayer play];
    }
}

//得到当前的播放时间
- (long)getCurrentDuration {
    return self.mPlayer.currentPlaybackTime;
}

//得到总的的播放时间
-(long)getTotalDuration {
    return self.mPlayer.duration;
}

-(void)progressSliderTapped:(CGFloat)percentage {
    long seek = percentage * self.mPlayer.duration;
    [self moveProgressWithTime:seek];
}

-(void)progressSliderDownAction {
    self.progressDragging = YES;
}

//快进快推
-(void)endFastWithTime:(long)time {
    [self moveProgressWithTime:time];
}


-(void)moveProgressWithTime:(long)time {
    [self.view startActivityWithMsg:@"Buffering"];
    [self.mPlayer seekTo:time accurate:NO];
    [self playContent];
}

- (double)currentDuation {
    return _mPlayer.currentPlaybackTime;
}

//切换音轨
-(void)changeTrackTapped {
    
}

- (void)playContent {
    if (!self.mPlayer.isPlaying) {
        [self.mPlayer play];
        [self.view setPlayButtonsSelected:NO];//设置按钮的状态
    }
}

- (void)pauseContent {
    if (self.mPlayer.isPlaying) {
        [self.mPlayer pause];
        [self.view setPlayButtonsSelected:YES];//设置按钮的状态
    }
}

- (void)dealloc {
    //    [self removeObserver:self forKeyPath:@"mPlayer"];
    [self unInstallPlayer];
}

-(void)unInstallPlayer {
    [self onQuit:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self quicklyStopMovie];
    _mPlayer = nil;
    [_view unInstallPlayerView];
    [_view.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_view removeFromSuperview];
}

@end
