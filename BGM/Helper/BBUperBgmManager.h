//
//  BBUperBgmManager.h
//  BBUper
//
//  Created by xmj on 2018/4/20.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,BBUperBgmState){
    BBUperBgmStatePause = 0,
    BBUperBgmStatePlay = 1,
    BBUperBgmStateisLoading = 2,
};

@interface BBUperBgmManager : NSObject
//@property (nonatomic) BOOL morenSelected;
@property (nonatomic) BBUperBgmState playState;
@property (nonatomic) double playSeekTime;
@property (nonatomic) int64_t activitySid;
+ (instancetype)shareInstance;
- (NSInteger)currentIndex;
- (void)setCurrentIndex:(NSInteger)index;
- (NSInteger)currentPage;
- (void)setCurrentPage:(NSInteger)currentPage;
- (void)removeBgmLocationCacheInfo;
- (NSString *)codeForString:(NSInteger)code;
@end
