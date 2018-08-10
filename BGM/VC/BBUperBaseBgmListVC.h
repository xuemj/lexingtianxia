//
//  BBUperBaseBgmListVC.h
//  BBUper
//
//  Created by xmj on 2018/4/17.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseTableVC.h"

@class BBUperBgmMediaModel;

@protocol BBUperBgmClickDelegate <NSObject>

- (void)bbuperBgmPlay:(BBUperBgmMediaModel *)model isChangeBgm:(BOOL)isChange;
- (void)bbuperBgmDownload:(BBUperBgmMediaModel *)model;
- (void)bbuperScrollEnable:(BOOL)isEnable;
- (void)bbuperBgmSeekTimePlay:(int)seekTime;
@end

@interface BBUperBaseBgmListVC : BBUperVideoEditorBaseTableVC
@property (nonatomic, weak) id<BBUperBgmClickDelegate> delegate;
@property (nonatomic) BOOL isPageSelected;
@property (nonatomic, strong) RACCommand *command;
- (instancetype)initWithMediaList:(NSArray*)mediaList page:(NSInteger)page;
- (void)resetListState:(BOOL)isSelected;
@end
