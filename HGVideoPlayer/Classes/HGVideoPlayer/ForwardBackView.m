//
//  ForwardBackView.m
//  VideoPlayer
//
//  Created by Tengfei on 16/6/4.
//  Copyright © 2016年 tengfei. All rights reserved.
//

#import "ForwardBackView.h"
#import "Masonry.h"
@interface ForwardBackView ()

@property (nonatomic,weak)UILabel * timeLabel;

@end

@implementation ForwardBackView
{
    UIImageView * forwardImage;
    UILabel * seconds;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self.layer.cornerRadius = 2;
        self.backgroundColor = [UIColor colorWithHue:20/255.0 saturation:20/255.0 brightness:20/255.0 alpha:0.6];
        
        UILabel *timeLabel = [[UILabel alloc]init];
        timeLabel.font = [UIFont boldSystemFontOfSize:15];
        timeLabel.textColor = [UIColor whiteColor];
        timeLabel.textAlignment = NSTextAlignmentCenter;
        timeLabel.adjustsFontSizeToFitWidth = YES;
        [self addSubview:timeLabel];
        self.timeLabel = timeLabel;
        
        [timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.right.equalTo(self);
        }];
    }
    return self;
}

//-(void)layoutSubviews
//{
//    [super layoutSubviews];
//    forwardImage.frame = CGRectMake((self.frame.size.width - 40)/2, 6, 30, 20);
//    
//    seconds.frame = CGRectMake(3, CGRectGetMaxY(forwardImage.frame) + 3, self.frame.size.width - 6, 16);
//}
//
//- (void)setDirection:(ForwardDirection)direction
//{
//    if (direction) {
//        forwardImage.image = [UIImage imageNamed:@"left"];
//    }else{
//        forwardImage.image = [UIImage imageNamed:@"right"];
//    }
//}

- (void)setTime:(NSString *)time
{
    if (time) {
        self.timeLabel.text = time;
    }
}

@end


