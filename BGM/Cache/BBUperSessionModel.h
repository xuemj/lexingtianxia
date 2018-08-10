//
//  BBUperSessionModel.h
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DownloadStateStart = 0,     /** 下载中 */
    DownloadStateSuspended,     /** 下载暂停 */
    DownloadStateCompleted,     /** 下载完成 */
    DownloadStateFailed,         /** 下载失败 */
//    DownloadStateInvalidFile    /** 下载音乐有未知问题 */
}DownloadState;

@interface BBUperSessionModel : NSObject

/** 流 */
@property (nonatomic, strong) NSOutputStream *stream;

/** 下载地址 */
@property (nonatomic, copy) NSString *url;

/** 获得服务器这次请求 返回数据的总长度 */
@property (nonatomic, assign) NSInteger totalLength;

/** 下载进度 */
@property (nonatomic, copy) void(^progressBlock)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress);

/** 下载状态 */
@property (nonatomic, copy) void(^stateBlock)(DownloadState state,NSString *filePath);

@end
