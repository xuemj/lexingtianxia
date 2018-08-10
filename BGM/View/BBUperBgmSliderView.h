//
//  BBUperBgmSlider.h
//  BBUperVideoEditor
//
//  Created by xmj on 2018/7/17.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^valueChangeBlock)(double index);

@interface BBUperBgmSliderView : UIControl
@property (nonatomic,copy)valueChangeBlock block;
@property (nonatomic) double currentTime;
@property (nonatomic) int totalTime;
- (instancetype)initWithFrame:(CGRect)frame
                 defaultPoint:(int)defaultPoint
                    totalTime:(int)totalTime
                  sliderImage:(UIImage *)sliderImage;

- (void)reseatStartPoint:(BOOL)isReseat;
@end
