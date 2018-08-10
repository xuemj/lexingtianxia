//
//  BBUperBgmManager.m
//  BBUper
//
//  Created by xmj on 2018/4/20.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmManager.h"
#define BBUperCurrentPage @"BBUperCurrentPage"
#define BBUperCurrentIndex @"BBUperBgmCurrentIndex"
#define BBUperCurrentPlayState @"BBUperCurrentPlayState"
@implementation BBUperBgmManager

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static BBUperBgmManager *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [BBUperBgmManager new];
    });
    return instance;
}

- (NSInteger)currentPage {
    int index = [[[self store] objectForKey:BBUperCurrentPage]intValue];
    if (index < 0) {
        index = 0;
        [self setCurrentPage:0];
    }
    return index;
}

- (void)setCurrentPage:(NSInteger)currentPage {
    NSNumber *number = [NSNumber numberWithInteger:currentPage];
    [[self store]setObject:number forKey:BBUperCurrentPage];
    [self synchronize];
}

- (NSInteger)currentIndex{
    int index = [[[self store] objectForKey:BBUperCurrentIndex]intValue];
    if (index < 0) {
        index = 0;
        [self setCurrentIndex:0];
    }
    return index;
}
- (void)setCurrentIndex:(NSInteger) index {
    NSNumber *number = [NSNumber numberWithInteger:index];
    [[self store]setObject:number forKey:BBUperCurrentIndex];
    [self synchronize];
}

- (void)setCurrentPlayState:(NSInteger)currentState {
    NSNumber *number = [NSNumber numberWithInteger:currentState];
    [[self store]setObject:number forKey:BBUperCurrentPlayState];
    [self synchronize];
}
- (NSInteger)currentPlayState {
    return [[[self store] objectForKey:BBUperCurrentPlayState] integerValue];
}

- (NSUserDefaults *)store {
    return [NSUserDefaults standardUserDefaults];
}

- (void)synchronize {
    [self sync];
}
- (void)sync {
    [[self store] synchronize];
}

- (void)removeBgmLocationCacheInfo {
    [[self store] removeObjectForKey:BBUperCurrentPage];
    [[self store] removeObjectForKey:BBUperCurrentIndex];
    [[self store] removeObjectForKey:BBUperCurrentPlayState];
    self.playSeekTime = 0;
}
- (NSString *)codeForString:(NSInteger)code {
    switch (code) {
        case 7201006:
            return @"音频未找到";
            break;
        case 7201007:
            return @"没有有效的url";
            break;
        case 7201008:
            return @"资源已下架";
            break;
        case 72010081:
            return @"资源地域限制";
            break;
        case 72010020:
            return @"未明确定义受限";
            break;
        case 72010021:
            return @"权益余额不足";
            break;
        case 72010022:
            return @"没有权益";
            break;
        case 72010023:
            return @"不是会员";
            break;
        case 72010024:
            return @"当前地区受限";
            break;
        case 72010026:
            return @"会员受限";
            break;
        case 72010027:
            return @"版权受限";
        default:
            return @"网络开小差了，稍后重试下~";
            break;
    }
}
@end
