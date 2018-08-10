//
//  BBUperBgmListCell.h
//  BBUper
//
//  Created by xmj on 2018/4/19.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorTableViewCell.h"

@class BBUperBgmMediaModel;
typedef void(^clickBgmCell)(void);
typedef void(^bgmSeekTime)(double time);
typedef void(^bgmSliderOpen)(BOOL isOpen);
@interface BBUperBgmListCell : BBUperVideoEditorTableViewCell

@property (nonatomic, copy) bgmSliderOpen openBlock;
@property (nonatomic, copy) clickBgmCell clickBlock;
@property (nonatomic, copy) bgmSeekTime seekTimeBlock;
- (void)insTallWithMediaInfo:(BBUperBgmMediaModel *)mediaSource isCurrentMedia:(BOOL)isCurrent;

@end

