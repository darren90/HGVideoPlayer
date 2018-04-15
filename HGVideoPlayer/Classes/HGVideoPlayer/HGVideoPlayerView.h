//
//  HGVideoPlayerView.h
//  HGVideoPlayer
//
//  Created by Fengtf on 2018/4/5.
//

#import <UIKit/UIKit.h>

typedef enum {
    HGVideoPlayerSmall, // 小屏播放
    HGVideoPlayerCell,  //单元格播放
    HGVideoPlayerFull,  //全屏播放
} HGVideoPlayerShowState;


#import "ForwardBackView.h"


@protocol HGVideoPlayerViewDelegate <NSObject>

@property (nonatomic, readonly) UIInterfaceOrientation visibleInterfaceOrientation;

- (void)playButtonPressed;
- (void)pauseButtonPressed;

- (void)doneButtonTapped;

- (void)playerViewSingleTapped;

- (void)fulllScrenAction;

-(void)switchVideoViewModeButtonAction;

#pragma mark - 右上和右下的几个按钮被点击

- (void)shareButtonTapped;//点击分享按钮

//进度条相关

-(void)progressSliderUp:(float)value;

//得到当前的播放时间
-(long)getCurrentDuration;

//得到总的的播放时间
-(long)getTotalDuration;

-(void)progressSliderTapped:(CGFloat)percentage;
-(void)progressSliderDownAction;

//快进快推
-(void)endFastWithTime:(long)time;

//切换音轨
-(void)changeTrackTapped;

@end



@interface HGVideoPlayerView : UIView

/** 初始化播放控件 */
+(instancetype)videoPlayerView;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIButton *tracButton;
@property (weak, nonatomic) IBOutlet UIButton *lockButton;

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *fullScreenButton;
@property (weak, nonatomic) IBOutlet UILabel *curPosLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (nonatomic, weak) IBOutlet UISlider *progressSld;


@property (weak, nonatomic) IBOutlet UILabel *bubbleMsgLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityView;

/// 回退
-(IBAction)goBackButtonAction:(id)sender;

#pragma mark - 切换音轨
- (IBAction)changeTrack:(UIButton *)sender;

#pragma mark - 开始 暂停
-(IBAction)startPauseButtonAction:(UIButton *)sender;

-(IBAction)fulllScrenAction:(UIButton *)sender;


#pragma mark - 切换Model
-(IBAction)switchVideoViewModeButtonAction:(id)sender;
#pragma mark - reset
-(IBAction)resetButtonAction:(id)sender;

#pragma mark - 进度条相关
-(IBAction)progressSliderDownAction:(id)sender;
-(IBAction)progressSliderUpAction:(id)sender;
-(IBAction)dragProgressSliderAction:(id)sender;

#pragma mark - 锁屏按钮
- (IBAction)lockButtonClick:(UIButton *)sender;


//*快进view*/
@property (nonatomic,weak)ForwardBackView * forwardView;

@property (nonatomic,strong)NSURL *PrevMediaUrl;
@property (nonatomic, assign) BOOL isLockBtnEnable;//屏幕锁

/// default HGVideoPlayerSmall
@property (nonatomic, assign) HGVideoPlayerShowState showState;


/**
 *  v3是否小屏播放 - NO：展示锁屏按钮
 */
//@property (nonatomic,assign)BOOL isSmallPlayShow;

// ******//

@property (nonatomic, weak) id<HGVideoPlayerViewDelegate> delegate;


-(void)startActivityWithMsg:(NSString *)msg;

-(void)stopActivity;

-(void)setBtnEnableStatus:(BOOL)enable;

/**
 *  是否播放的是本地资源
 */
@property (nonatomic,assign)BOOL isPlayLocalFile;//我增加的字段，以便播放本地视频的时候视频不受打扰


//设置播放/暂停时按钮的状态， 播放 --> 暂停 :YES
- (void)setPlayButtonsSelected:(BOOL)selected ;

/**
 *  卸载播放器的View
 */
-(void)unInstallPlayerView;


@end
