//
//  BBUperFileDownloadManager.h
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BBUperSessionModel.h"
@interface BBUperFileDownloadManager : NSObject

+ (instancetype)sharedInstance;

+ (NSString *)md5String:(NSString *)url;

//下载缓存文件夹路径
+ (NSString *)fileCacheDirectory;
//缓存文件的路径
+ (NSString *)fileCacheFullPath:(NSString *)url;
//解压缩包的路径
+ (NSString *)directoryCacheFullPath:(NSString *)url;

/**
 *  开启任务下载资源
 *
 *  @param url           下载地址
 *  @param progressBlock 回调下载进度
 *  @param stateBlock    下载状态
 */
- (void)download:(NSString *)url progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize, CGFloat progress))progressBlock state:(void(^)(DownloadState state,NSString *filePath))stateBlock;

/**
 *  开始下载
 */
- (void)start:(NSString *)url;

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url;

/**
 *  查询该资源的下载进度值
 *
 *  @param url 下载地址
 *
 *  @return 返回下载进度值
 */
- (CGFloat)progress:(NSString *)url;

/**
 *  获取该资源总大小
 *
 *  @param url 下载地址
 *
 *  @return 资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url;

/**
 *  判断该资源是否下载完成
 *
 *  @param url 下载地址
 *
 *  @return YES: 完成
 */
- (BOOL)isCompletion:(NSString *)url;

/**
 *  删除该资源
 *
 *  @param url 下载地址
 */
- (void)deleteFile:(NSString *)url;

- (BOOL)unzipFile:(NSString *)filePath toFilePath:(NSString *)targetFilePath;

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile;

+ (BOOL)fileExists:(NSString *)url;
+ (BOOL)directoryExists:(NSString *)url;

// 根据下载包的url，从磁盘加载缓存的zip包解压后的文件夹内容
NSArray *LoadFolderContentsWithCachedUrl(NSString *downloadUrl);

@end
