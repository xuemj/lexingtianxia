//
//  BBUperBgmSlider.m
//  BBUperVideoEditor
//
//  Created by xmj on 2018/7/17.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmSliderView.h"
#define SliderWith 8
#define SliderHeight 26
#define ExtraWidth  12
@interface BBUperBgmSliderView () {
    int _pointX;
    UILabel *_selectLab;
    UILabel *_rightLab;
    CGFloat _ViewWidth;
    CGFloat _ViewHeight;
    //    int _startTime;
    //    int _startTotal;
}
@property (nonatomic,strong)UIImage *sliderImage;
@property (strong,nonatomic)UIView *defaultView;
@property (strong,nonatomic)UIImageView *centerImage;
@property (nonatomic, strong)UIImageView *soundTrackImageView;
@end

@implementation BBUperBgmSliderView

-(instancetype)initWithFrame:(CGRect)frame defaultPoint:(int)defaultPoint totalTime:(int)totalTime sliderImage:(UIImage *)sliderImage {
    if (self  = [super initWithFrame:frame]) {
        _ViewWidth = frame.size.width;
        _ViewHeight = frame.size.height;
        self.backgroundColor=[UIColor clearColor];
        
        UIImage *image = [BBUperImageMake(@"videoediting_audioRecord_track") resizableImageWithCapInsets:UIEdgeInsetsMake(0, 1, 0, 1) resizingMode:UIImageResizingModeTile];
        self.soundTrackImageView = [[UIImageView alloc] initWithImage:image];
        self.soundTrackImageView.frame = CGRectMake(ExtraWidth, _ViewHeight/2-SliderHeight/2, _ViewWidth-ExtraWidth, SliderHeight);
        [self addSubview:self.soundTrackImageView];
        
        _defaultView=[[UIView alloc] initWithFrame:CGRectZero];
        _defaultView.backgroundColor= HEXACOLOR(0x39B4E5, 0.5);
        //        _defaultView.alpha = 0.4;
        _defaultView.layer.borderColor = HEXCOLOR(0xFFFFFF).CGColor;
        _defaultView.layer.borderWidth = 1;
        _defaultView.layer.cornerRadius=0;
        _defaultView.userInteractionEnabled=NO;
        [self addSubview:_defaultView];
        
        _centerImage=[[UIImageView alloc] initWithFrame:CGRectZero];
        _centerImage.userInteractionEnabled=NO;
        _centerImage.image = sliderImage;
        [self addSubview:_centerImage];
        
        _selectLab = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectLab.textColor=[UIColor whiteColor];
        _selectLab.font=[UIFont systemFontOfSize:12];
        _selectLab.textAlignment= NSTextAlignmentRight;
        [self addSubview:_selectLab];
        
        _rightLab= [[UILabel alloc] initWithFrame:CGRectMake(frame.size.width-40, 0, 40, 20)];
        _rightLab.textAlignment = NSTextAlignmentRight;
        _rightLab.font=[UIFont systemFontOfSize:12];
        _rightLab.textColor=[UIColor whiteColor];
        [self addSubview:_rightLab];
        
    }
    return self;
}

- (void)reseatStartPoint:(BOOL)isReseat {
    if (self.totalTime == 0) {
        self.currentTime = 1;
        self.totalTime = 1;
    }
    CGFloat a = (CGFloat)self.currentTime/self.totalTime;
    _pointX = (_ViewWidth-ExtraWidth) * a;
    _rightLab.text = [self timeforString:self.totalTime];
    _centerImage.frame = CGRectMake(_pointX+ExtraWidth, _ViewHeight/2, SliderWith, SliderHeight);
    _selectLab.frame = CGRectMake(_pointX+ExtraWidth, 0, 40, 20);
    [self refreshSlider];
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self changePointX:touch];
    [self refreshSlider];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self changePointX:touch];
    [self refreshSlider];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self changePointX:touch];
    if (self.block) {
        self.block(self.currentTime);
    }
    [self refreshSlider];
    
}

-(void)changePointX:(UITouch *)touch {
    CGPoint point = [touch locationInView:self];
    _pointX = point.x;
    self.currentTime = _totalTime * point.x / (_ViewWidth-ExtraWidth);
    if (point.x <= 0) {
        _pointX = SliderWith/2;
        self.currentTime = 0;
    } else if (point.x >= _ViewWidth-ExtraWidth-1){
        _pointX = _ViewWidth-ExtraWidth-1;
        self.currentTime = _totalTime-1;
    }
}

-(void)refreshSlider {
    if ((_ViewWidth - _pointX) < ExtraWidth+70) {
        _selectLab.hidden = YES;
    } else {
        _selectLab.hidden = NO;
    }
    _centerImage.center=CGPointMake(_pointX+ExtraWidth, _ViewHeight/2);
    _defaultView.frame= CGRectMake(_pointX+ExtraWidth, _ViewHeight/2-SliderHeight/2, _ViewWidth - _pointX-ExtraWidth, SliderHeight);
    _selectLab.text = [self timeforString:self.currentTime];
    _selectLab.center=CGPointMake(_pointX+ExtraWidth+10, 10);
    
}

- (NSString *)timeforString:(int)time {
    
    int seconds = time % 60;
    int minutes = (time/ 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

@end
