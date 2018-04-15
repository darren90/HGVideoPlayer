//
//  HGVideoPlayerView.m
//  HGVideoPlayer
//
//  Created by Fengtf on 2018/4/5.
//

#import "HGVideoPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Masonry.h"
#import "BrightnessView.h"
#import "UISlider+VDTrackHeight.h"
#import "TFPlayerTools.h"
#import "HGVideoPlayer+Utils.h"

#define PADDING 8

//手指移动的方向
typedef NS_ENUM(NSInteger,PanDirection) {
    PanDirectionHorizontalMoved,
    PanDirectionVerticalMoved,
} ;

@interface HGVideoPlayerView()
@property (strong, nonatomic) UITapGestureRecognizer *singleGesture;
@property (strong, nonatomic) UITapGestureRecognizer *doubleGesture;

/** 调节声音，亮度；快进快推的手势 */
@property (nonatomic,strong)UIPanGestureRecognizer * panGesture;

@property (nonatomic, assign) PanDirection panDirection;//滑动方向

@property (nonatomic,assign)BOOL isVolume;//是否是音量 亮度
@property (nonatomic,assign)long sumTime;//快进的总量
@property (nonatomic,assign)BOOL isEndFast;//判断是否快进
@property (nonatomic,strong)UISlider * volumeViewSlider;//音量view

/**NSTimer对象 */
@property (nonatomic,strong)NSTimer * timer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;

@property (strong, nonatomic) CAGradientLayer *topGLayer;
@property (strong, nonatomic) CAGradientLayer *bottomGLayer;

@end

@implementation HGVideoPlayerView

+ (instancetype)videoPlayerView{
    return [[NSBundle bundleForClass:[self class]] loadNibNamed:@"HGVideoPlayerView" owner:nil options:nil].firstObject;
}

- (instancetype)init{
    if (self = [super init]) {
        self = [HGVideoPlayerView videoPlayerView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    [self initialize];
    [self setupLayer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.clipsToBounds = YES;
}


#define isIPad   ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
//#define THEMEFONT(key, fontSize) [VKSharedThemeManager font:key size:fontSize]
#define DEVICEVALUE(ipadValue, iphoneValue) (isIPad ? (ipadValue) : (iphoneValue))
#define RRTHMEFONT(FONTVALUE) ([UIFont systemFontOfSize:FONTVALUE])


-(void)initialize {
    self.tracButton.hidden = YES;
    
    self.singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap)];
    self.doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTwoTap)];
    self.doubleGesture.numberOfTapsRequired = 2;
    [self addGestureRecognizer:self.singleGesture];
    [self addGestureRecognizer:self.doubleGesture];
    
    self.titleLabel.font = RRTHMEFONT(DEVICEVALUE(22.0f, 14.0f));
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = @"";
    
    self.curPosLabel.font = RRTHMEFONT(DEVICEVALUE(16.0f, 12.0f));
    self.curPosLabel.textColor = [UIColor whiteColor];
    self.durationLabel.font =RRTHMEFONT(DEVICEVALUE(16.0f, 12.0f));
    self.durationLabel.textColor = [UIColor whiteColor];
    
    [self.lockButton setImage:[UIImage hg_imageNamed:@"TFPlayer_unlock-nor"] forState:UIControlStateNormal];
    
    self.progressSld.vd_trackHeight = 5.0;
    //当前点点的位置
    [self.progressSld setThumbImage:[UIImage hg_imageNamed:@"TFPlayer_slider@3x.png"] forState:UIControlStateNormal];
    //已播放的条的颜色
    [self.progressSld setMinimumTrackImage:[UIImage hg_imageNamed:@"pb-seek-bar-fr@2x.png"] forState:UIControlStateNormal];
    //未播放的条的颜色
    [self.progressSld setMaximumTrackImage:[UIImage hg_imageNamed:@"pb-seek-bar-bg@2x.png"] forState:UIControlStateNormal];
    
    //2: Conrol
    //这句话的意思时，只有当doubleTapGesture识别失败的时候(即识别出这不是双击操作)，singleTapGesture才能开始识别，同我们一开始讲的是同一个问题。
    [self.singleGesture requireGestureRecognizerToFail:self.doubleGesture];
    
    //添加手势 音量 亮度 快进
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panDirection:)];
        [self addGestureRecognizer:self.panGesture];
    }
    
    
    [self addHiddeControlTimer];
    
    //声音调节的空间
    [self configureVolume];
    //快进快推
    [self configureSpeedView];
    
    // 亮度view加到window最上层
    BrightnessView *brightnessView = [BrightnessView sharedBrightnessView];
    [[UIApplication sharedApplication].keyWindow insertSubview:self belowSubview:brightnessView];
    
    self.showState = HGVideoPlayerSmall;
}

- (void)setShowState:(HGVideoPlayerShowState)showState {
    _showState = showState;

    switch (showState) {
        case HGVideoPlayerSmall:{
            self.topView.hidden = YES;
            self.lockButton.hidden = YES;
            self.topViewHeight.constant = 42;
            self.bottomViewHeight.constant = 37;
            [self.fullScreenButton setImage:[UIImage hg_imageNamed:@"TFPlayer_fullscreen"] forState:UIControlStateNormal];
        }
            break;
        case HGVideoPlayerCell:{
            self.topViewHeight.constant = 0;
            self.topView.hidden = YES;
            self.lockButton.hidden = YES;
            self.lockButton.hidden = YES;
            self.bottomViewHeight.constant = 30;
            [self.fullScreenButton setImage:[UIImage hg_imageNamed:@"TFPlayer_fullscreen"] forState:UIControlStateNormal];
        }
            break;
        case HGVideoPlayerFull:{
            //            if (self.doneButton.hidden == NO) {
            self.topView.hidden = NO;
            self.bottomView.hidden = NO;
            self.lockButton.hidden = NO;
            self.topViewHeight.constant = 55;
            self.bottomViewHeight.constant = 50;
            [self.fullScreenButton setImage:[UIImage hg_imageNamed:@"TFPlayer_shrinkscreen"] forState:UIControlStateNormal];
            //刚转到大屏，不隐藏状态栏以及上下控制条
            [[UIApplication sharedApplication] setStatusBarHidden:self.bottomView.hidden withAnimation:UIStatusBarAnimationNone];
            //            }
        }
            break;
    }
}


- (void)delPlayerPanGesture{
    [self removeGestureRecognizer:self.panGesture];
    [self removeGestureRecognizer:self.singleGesture];
    [self removeGestureRecognizer:self.doubleGesture];
    
    self.panGesture = nil;
    self.singleGesture = nil;
    self.doubleGesture = nil;
}

-(IBAction)goBackButtonAction:(id)sender{
    NSLog(@"%s",__func__);
    [self.delegate doneButtonTapped];
}

#pragma mark - 切换音轨
- (IBAction)changeTrack:(UIButton *)sender{
    [self.delegate changeTrackTapped];
}

#pragma mark - 开始 暂停
-(IBAction)startPauseButtonAction:(UIButton *)sender{
    if (self.isLockBtnEnable) return;
    if (sender.selected)  {//播放
        [self.delegate playButtonPressed];
        [self setPlayButtonsSelected:NO];
    } else {//暂停
        [self.delegate pauseButtonPressed];
        [self setPlayButtonsSelected:YES];
    }
}

-(IBAction)prevButtonAction:(id)sender{
    
}

-(IBAction)nextButtonAction:(id)sender{
    
}

-(IBAction)fulllScrenAction:(UIButton *)sender {
    [self.delegate fulllScrenAction];
}

-(void)setBtnEnableStatus:(BOOL)enable{
    self.playButton.enabled = enable;
 
}

//设置播放/暂停时按钮的状态， 播放 --> 暂停 :YES
- (void)setPlayButtonsSelected:(BOOL)selected {
    self.playButton.selected = selected;
}

#pragma mark - 切换Model
-(IBAction)switchVideoViewModeButtonAction:(id)sender{
    [self.delegate switchVideoViewModeButtonAction];
}

#pragma mark - reset
-(IBAction)resetButtonAction:(id)sender{
    
}

#pragma mark - 进度条相关
-(IBAction)progressSliderDownAction:(id)sender{
    NSLog(@"-progressSliderDownAction--");
    [self.delegate progressSliderDownAction];
}

-(IBAction)progressSliderUpAction:(id)sender{
    UISlider *sld = (UISlider *)sender;
    NSLog(@"-progressSliderUpAction--:%@",@(sld.value));
    
    [self.delegate progressSliderUp:sld.value];
}

-(IBAction)dragProgressSliderAction:(id)sender{
    NSLog(@"-dragProgressSliderAction--");
    UISlider *sld = (UISlider *)sender;
    long toalDuration = [self.delegate getTotalDuration];
    self.curPosLabel.text = [TFPlayerTools timeToHumanString:(long)(sld.value * toalDuration)];
//    long seek = percentage * [self.delegate getCurrentDuration];
//    self.curPosLabel.text = [TFPlayerTools timeToHumanString:seek];
    [self.delegate progressSliderTapped:sld.value];
}

#pragma mark - 进度条的点击代理 -- 滑动 -- UISlide上也可以左右滑动手势
-(void)progressSliderPanGesture:(UIPanGestureRecognizer *)pan{
    if (self.isLockBtnEnable) return;
    CGPoint velocity = [pan velocityInView:self.progressSld];
    NSLog(@"--手势滑动-");
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            // 给sumTime初值
            self.sumTime = [self.delegate getCurrentDuration];
        }
            break;
        case UIGestureRecognizerStateChanged:{ // 正在移动
            // 每次滑动需要叠加时间
            self.sumTime += velocity.x / 3.0;
            
            long totalMovieDuration = [self.delegate getTotalDuration];
            if (self.sumTime > totalMovieDuration) {
                self.sumTime = totalMovieDuration;
            }else if (self.sumTime < 0){
                self.sumTime = 0;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:{ // 结束移动
            [self.delegate endFastWithTime:self.sumTime];
            self.sumTime = 0;
        }
            break;
        default:
            break;
    }
}

#pragma mark - 进度条的点击代理，目前不执行 -- 点击进度条直接跳转到哪个地方
-(void)progressSliderGesture:(UIGestureRecognizer *)g{
    UISlider* s = (UISlider*)g.view;
    if (s.highlighted)
        return;
    CGPoint pt = [g locationInView:s];
    CGFloat percentage = pt.x / s.bounds.size.width;
    CGFloat delta = percentage * (s.maximumValue - s.minimumValue);
    CGFloat value = s.minimumValue + delta;
    [s setValue:value animated:YES];
    long seek = percentage * [self.delegate getCurrentDuration];
    self.curPosLabel.text = [TFPlayerTools timeToHumanString:seek];
    [self.delegate progressSliderTapped:percentage];
}

#pragma mark Others

-(void)startActivityWithMsg:(NSString *)msg {
    if (self.isPlayLocalFile) return;
    msg = @"正在缓冲...";
    self.bubbleMsgLabel.hidden = NO;
    self.bubbleMsgLabel.text = msg;
    [self.activityView startAnimating];
}

-(void)stopActivity{
    self.bubbleMsgLabel.hidden = YES;
    self.bubbleMsgLabel.text = nil;
    [self.activityView stopAnimating];
}

#pragma mark - 单击 手势
- (void)handleSingleTap{
    self.topView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.8];
    if (self.isLockBtnEnable) {
        return;
    }
    
    switch (self.showState) {
        case HGVideoPlayerSmall:{
            self.topView.hidden = YES;
            self.bottomView.hidden = !self.bottomView.hidden;
            self.topView.hidden = YES;//NO;
            self.backButton.hidden = NO;
            
//            return;
        }
            break;
        case HGVideoPlayerCell:{
            self.topView.hidden = YES;
            self.lockButton.hidden = YES;
            self.lockButton.hidden = YES;
            self.bottomView.hidden = !self.bottomView.hidden;
            
//            return;
        }
            break;
        case HGVideoPlayerFull:{
            self.bottomView.hidden = !self.bottomView.hidden;
            self.topView.hidden = self.bottomView.hidden;
            self.backButton.hidden = self.bottomView.hidden;
        }
            break;
        default:
            break;
    }
    
    //销毁计时器
    [self destroyHiddeControlTimer];
    //代理做
    if (self.isLockBtnEnable) {
        self.lockButton.hidden = !self.lockButton.hidden;
        [[UIApplication sharedApplication] setStatusBarHidden:self.lockButton.hidden withAnimation:UIStatusBarAnimationFade];
    }else{
        [[UIApplication sharedApplication]setStatusBarHidden:self.bottomView.hidden withAnimation:UIStatusBarAnimationNone];
    }
    
    //添加计时器
    [self addHiddeControlTimer];
}

- (void)handleTwoTap{
    if (self.isLockBtnEnable) {
        return;
    }
    
    [self startPauseButtonAction:self.playButton];
}

#pragma mark - 顶部和底部控制按钮的 增加定时器
-(void)addHiddeControlTimer{
    //     NSLog(@"---addTimer");
    if (!self.timer && !self.isLockBtnEnable) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:8 target:self selector:@selector(hiddenTopBottom) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        //消息循环，添加到主线程
        //extern NSString* const NSDefaultRunLoopMode;  //默认没有优先级
        //extern NSString* const NSRunLoopCommonModes;  //提高优先级
    }
}

#pragma mark - 顶部和底部控制按钮的 销毁定时器
-(void)destroyHiddeControlTimer{
    [self.timer invalidate];
    self.timer = nil;
}

-(void)hiddenTopBottom{
    [UIView animateWithDuration:0.5 animations:^{
        if (!self.bottomView.hidden) {
            self.topView.hidden = YES;
            self.bottomView.hidden = YES;
        }
        if (!self.isLockBtnEnable) {
            self.lockButton.hidden = YES;
        }
        
        switch (self.showState) {
            case HGVideoPlayerSmall:{
                self.lockButton.hidden = YES;
                self.topView.hidden = YES;
                self.topView.hidden = YES;
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            }
                break;
            case HGVideoPlayerCell:{
                self.lockButton.hidden = YES;
            }
                break;
            case HGVideoPlayerFull:{
                [[UIApplication sharedApplication] setStatusBarHidden:self.bottomView.hidden withAnimation:UIStatusBarAnimationNone];
            }
                break;
            default:
                break;
        }
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - 分享
- (IBAction)shareButtonTapped:(UIButton *)sender{
    //隐藏
    [self hiddenTopBottom];
    //代理
    [self.delegate shareButtonTapped];
}

#pragma mark - 右下角的全屏按钮
- (IBAction)fullScreenButtonTapped:(UIButton *)sender{
    //    [self.delegate fullScreenButtonTapped];
}

- (IBAction)lockButtonClick:(UIButton *)sender{
    self.isLockBtnEnable = !self.isLockBtnEnable;
    
    if (!self.isLockBtnEnable) {
        //开
        [self.lockButton setImage:[UIImage hg_imageNamed:@"TFPlayer_unlock-nor"] forState:UIControlStateNormal];
        self.topView.hidden = NO;
        self.bottomView.hidden = NO;
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }else{ //点击锁定屏幕
        //锁
        [self.lockButton setImage:[UIImage hg_imageNamed:@"TFPlayer_lock-nor"] forState:UIControlStateNormal];
        self.topView.hidden = YES;
        self.bottomView.hidden = YES;
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
    //    self.lockButton.hidden = YES;
}

- (void)setPlayButtonsEnabled:(BOOL)enabled {
    self.playButton.enabled = enabled;
}


#pragma mark - 手势控制，声音，亮度，进度

- (void)panDirection:(UIPanGestureRecognizer *)pan{
    if (self.isLockBtnEnable) {
        return;
    }
    
    //根据在view上Pan的位置，确定是跳音量、亮度
    CGPoint locationPoint = [pan locationInView:self];
    
    BOOL top = CGRectContainsPoint(self.topView.frame, locationPoint);
    BOOL bottom = CGRectContainsPoint(self.bottomView.frame, locationPoint);
    if (!self.topView.hidden && (top || bottom)) return;
    
    //NSLog(@"========%@",NSStringFromCGPoint(locationPoint));
    // 我们要响应水平移动和垂直移动
    // 根据上次和本次移动的位置，算出一个速率的point
    CGPoint veloctyPoint = [pan velocityInView:self];
//    CGPoint transPoint = [pan translationInView:self];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            //            NSLog(@"x:%f  y:%f   aaa:%f,bbb:%f",veloctyPoint.x, veloctyPoint.y,transPoint.x,transPoint.y);
            // 使用绝对值来判断移动的方向
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) { // 水平移动
                self.panDirection = PanDirectionHorizontalMoved;
                // 取消隐藏
                self.forwardView.hidden = NO;
                self.isEndFast = NO;
                // 给sumTime初值
                self.sumTime = [self.delegate getCurrentDuration];
            }else if (x < y){ // 垂直移动
                self.panDirection = PanDirectionVerticalMoved;
                // 显示音量控件
                if (locationPoint.x > self.bounds.size.width / 2) {
                    self.isVolume = YES;
                }else { // 显示亮度调节
                    self.isVolume = NO;
                }
                // 开始滑动的时候，状态改为正在控制音量
            }
            
        }
            break;
        case UIGestureRecognizerStateChanged:{
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{
                    if (!self.isEndFast) {
                        self.isEndFast = YES;
                    }
                    [self horizontalMoved:veloctyPoint.x]; // 水平移动的方法只要x方向的值
                    break;
                }
                case PanDirectionVerticalMoved:{
                    [self verticalMoved:veloctyPoint.y]; // 垂直移动方法只要y方向的值
                    break;
                }
                default:
                    break;
            }
            
        }
            break;
        case UIGestureRecognizerStateEnded:{
            // 移动结束也需要判断垂直或者平移
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                // 隐藏视图
                self.forwardView.hidden = YES;
            });
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch (self.panDirection) {
                case PanDirectionHorizontalMoved:{//快进结束
                    // 把sumTime滞空，不然会越加越多
                    [self.delegate endFastWithTime:self.sumTime];
                    self.sumTime = 0;
                    self.isEndFast = NO;
                }
                    break;
                    
                case PanDirectionVerticalMoved:{ // 垂直移动结束后，隐藏音量控件 且，把状态改为不再控制音量
                    
                    self.isVolume = NO;
                }
                    break;
                    
                default:
                    break;
            }
        }
            break;
            
        default:
            break;
    }
    
}
#pragma makr 调节音量
- (void)verticalMoved:(CGFloat)value{
    
    if (self.isVolume) {
        // 更改系统的音量
        self.volumeViewSlider.value -= value / 10000; // 越小幅度越小
    }else {
        //亮度
        [UIScreen mainScreen].brightness -= value / 10000;
    }
}


#pragma makr 快进后退
- (void)horizontalMoved:(CGFloat)value{
//    NSLog(@"快进快推-:%f",value);
    // 快进快退的方法
    NSString *style = @"";
    if (value < 0) {
        style = @"<<";
        self.forwardView.direction = ForwardBack;
    }
    else if (value > 0){
        style = @">>";
        self.forwardView.direction = ForwardUp;
    }
    
    // 每次滑动需要叠加时间
    self.sumTime += value / 100.0;    // 需要限定sumTime的范围 除以 300 代表调节倍率
 
    long totalMovieDuration = [self.delegate getTotalDuration];
    if (self.sumTime > totalMovieDuration) {
        self.sumTime = totalMovieDuration;
    }else if (self.sumTime < 0){
        self.sumTime = 0;
    }
    
    NSString * currentTime = [TFPlayerTools timeToHumanString:self.sumTime];
    NSString * total = [TFPlayerTools timeToHumanString:totalMovieDuration];
    self.forwardView.time = [NSString stringWithFormat:@"%@ %@ / %@",style,currentTime,total];
}

#pragma mark - 快进
- (void)configureSpeedView{
    if (self.forwardView == nil) {
        ForwardBackView *forwardView = [[ForwardBackView alloc]initWithFrame:CGRectMake(0, 0, 100, 64)];
        forwardView.hidden = YES;
        [self addSubview:forwardView];
        self.forwardView = forwardView;
        forwardView.layer.cornerRadius = 5;
        forwardView.clipsToBounds = YES;
        [forwardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);//84
            make.width.mas_equalTo(160);//170
            make.center.equalTo(self);
        }];
    }
}

#pragma mark 获取系统音量
- (void)configureVolume{
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeViewSlider = nil;
    for (UIView *view in [volumeView subviews]){
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeViewSlider = (UISlider *)view;
            break;
        }
    }
    
    // 使用这个category的应用不会随着手机静音键打开而静音，可在手机静音下播放声音
    NSError *setCategoryError = nil;
    BOOL success = [[AVAudioSession sharedInstance]
                    setCategory: AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    
    if (!success) { /* handle the error in setCategoryError */ }
}



-(void)layouttopViews {
    CGFloat rightMargin = CGRectGetMaxX(self.topView.frame);
    for (UIView* button in self.topView.subviews) {
        if ([button isKindOfClass:[UIButton class]] && button != self.backButton && !button.hidden) {
            rightMargin = MIN(CGRectGetMinX(button.frame), rightMargin);
        }
    }
}

- (void)setupLayer {
    self.topView.backgroundColor = [UIColor clearColor];
    self.bottomView.backgroundColor = [UIColor clearColor];
    
    if (self.bottomGLayer == nil) {
        //bottom 渐变
        self.bottomGLayer = [[CAGradientLayer alloc] init];
        
        self.bottomGLayer.startPoint = CGPointMake(0, 0);
        self.bottomGLayer.endPoint = CGPointMake(0, 1);
        self.bottomGLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                     (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor,
                                     (__bridge id)[[UIColor blueColor] colorWithAlphaComponent:0.9].CGColor
                                     ];
        self.bottomGLayer.locations =  @[@(0.2f) ,@(0.6f),@(1.0)];
        [self.bottomView.layer insertSublayer:self.bottomGLayer below:self.playButton.layer];
    }
    
    if (self.topGLayer == nil) {
        //top 渐变
        self.topGLayer = [[CAGradientLayer alloc] init];
        self.topGLayer.startPoint = CGPointMake(0, 0);
        self.topGLayer.endPoint = CGPointMake(0, 1);
        self.topGLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.9].CGColor,
                                  (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor,
                                  (__bridge id)[UIColor clearColor].CGColor
                                  ];
        self.topGLayer.locations = @[@(0.2f) ,@(0.6f),@(1.0)];
        [self.topView.layer insertSublayer:self.topGLayer below:self.titleLabel.layer];
    }
}

-(void)dealloc {
    [self unInstallPlayerView];
}

-(void)unInstallPlayerView {
    [self delPlayerPanGesture];
    [self destroyHiddeControlTimer];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    NSLog(@"---HGVideoPlayerView--销毁了");
}

@end
