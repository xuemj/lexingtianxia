//
//  BBUperFileDownloadManager.m
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

// 缓存主目录
#define BBUperFileCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BBUperFileCache"]

// 保存文件名
#define BBUperFileFileName(url) [BBUperFileDownloadManager md5String:url]

// 文件的存放路径（caches）
#define BBUperFileFullpath(url) [BBUperFileCachesDirectory stringByAppendingPathComponent:BBUperFileFileName(url)]

// 文件的已下载长度
#define BBUperFileDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:BBUperFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件总长度的文件路径（caches）
#define BBUperFileTotalLengthFullpath [BBUperFileCachesDirectory stringByAppendingPathComponent:@"totalLength.plist"]


#import "BBUperFileDownloadManager.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import <AVFoundation/AVAsset.h>
#import "ZipArchive.h"

@interface BBUperFileDownloadManager()<NSCopying, NSURLSessionDelegate>

/** 保存所有任务(注：用下载地址md5后作为key) */
@property (nonatomic, strong) NSMutableDictionary *tasks;
/** 保存所有下载相关信息 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
@end

@implementation BBUperFileDownloadManager

+ (NSString *)md5String:(NSString *)url {
    if (!url) {
        return @"";
    }
    NSString *formatStr = @".m4a";
    NSString *urlStr = @"";
    NSArray *arr1 = [url componentsSeparatedByString:@"?"];
    if (arr1.count > 0) {
        formatStr = arr1.firstObject;
        //下载地址参数会随时改变所以截取前缀当做标识
        urlStr = arr1.firstObject;
        NSArray *arr2 = [formatStr componentsSeparatedByString:@"/"];
        if (arr2.count > 0) {
            formatStr = arr2.lastObject;
        }
    }
    const char *string = urlStr.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH format:formatStr];
}

+ (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length format:(NSString *)formatStr
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++)
        [mutableString appendFormat:@"%02x", bytes[i]];
    NSString *str = [NSString stringWithString:mutableString];
    
    return [NSString stringWithFormat:@"%@%@",str,formatStr];
}

- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = [NSMutableDictionary dictionary];
    }
    return _sessionModels;
}


static BBUperFileDownloadManager *_downloadManager;

+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _downloadManager = [super allocWithZone:zone];
    });
    
    return _downloadManager;
}

- (nonnull id)copyWithZone:(nullable NSZone *)zone
{
    return _downloadManager;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloadManager = [[self alloc] init];
    });
    
    return _downloadManager;
}

/**
 *  创建缓存目录文件
 */
+ (void)createCacheDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:BBUperFileCachesDirectory]) {
        [fileManager createDirectoryAtPath:BBUperFileCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
}

+ (NSString *)fileCacheDirectory {
    return BBUperFileCachesDirectory;
}

+ (BOOL)fileExists:(NSString *)url {
    if (url.length == 0) {
        return NO;
    }
    
    NSString *fullPath = [self fileCacheFullPath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:nil];
}

+ (BOOL)directoryExists:(NSString *)url {
    if (url.length == 0) {
        return NO;
    }
    
    NSString *fullPath = [self directoryCacheFullPath:url];
    return [[NSFileManager defaultManager] fileExistsAtPath:fullPath isDirectory:nil];
}

+ (NSString *)fileCacheFullPath:(NSString *)url {
    NSString *hashString = [self md5String:url];
    NSString *fullPath = [[self fileCacheDirectory] stringByAppendingPathComponent:hashString];
    return fullPath;
}

+ (NSString *)directoryCacheFullPath:(NSString *)url {
    return [self fileCacheFullPath:[url stringByAppendingPathComponent:@"directory"]];
}

/**
 *  开启任务下载资源
 */
- (void)download:(NSString *)url progress:(void (^)(NSInteger, NSInteger, CGFloat))progressBlock state:(void (^)(DownloadState,NSString *))stateBlock
{
    if (!url) return;
    if (!stateBlock) return;  // 防止外界误传nil
    if ([self isCompletion:url]) {
        stateBlock(DownloadStateCompleted,BBUperFileFullpath(url));
        return;
    }
    
    // 暂停
    if ([self.tasks valueForKey:BBUperFileFileName(url)]) {
        [self handle:url];
        
        return;
    }
    
    // 创建缓存目录文件
    [BBUperFileDownloadManager createCacheDirectory];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc] init]];
    
    // 创建流
    NSOutputStream *stream = [NSOutputStream outputStreamToFileAtPath:BBUperFileFullpath(url) append:YES];
    
    // 创建请求
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    
    // 设置请求头
    NSString *range = [NSString stringWithFormat:@"bytes=%@-", @(BBUperFileDownloadLength(url))];
    [request setValue:range forHTTPHeaderField:@"Range"];
    
    // 创建一个Data任务
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    // 保存任务
    [self.tasks setValue:task forKey:BBUperFileFileName(url)];
    
    BBUperSessionModel *sessionModel = [[BBUperSessionModel alloc] init];
    sessionModel.url = url;
    sessionModel.progressBlock = progressBlock;
    sessionModel.stateBlock = stateBlock;
    sessionModel.stream = stream;
    [self.sessionModels setValue:sessionModel forKey:@(task.taskIdentifier).stringValue];
    
    [self start:url];
}


- (void)handle:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    } else {
        [self start:url];
    }
}

/**
 *  开始下载
 */
- (void)start:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateStart,BBUperFileFullpath(url));
}

/**
 *  暂停下载
 */
- (void)pause:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    
    [self getSessionModel:task.taskIdentifier].stateBlock(DownloadStateSuspended,BBUperFileFullpath(url));
}

/**
 *  根据url获得对应的下载任务
 */
- (NSURLSessionDataTask *)getTask:(NSString *)url
{
    return (NSURLSessionDataTask *)[self.tasks valueForKey:BBUperFileFileName(url)];
}

/**
 *  根据url获取对应的下载信息模型
 */
- (BBUperSessionModel *)getSessionModel:(NSUInteger)taskIdentifier
{
    return (BBUperSessionModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

/**
 *  判断该文件是否下载完成
 */
- (BOOL)isCompletion:(NSString *)url
{
    if ([self fileTotalLength:url] && BBUperFileDownloadLength(url) >= [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

/**
 *  查询该资源的下载进度值
 */
- (CGFloat)progress:(NSString *)url
{
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * BBUperFileDownloadLength(url) /  [self fileTotalLength:url];
}

/**
 *  获取该资源总大小
 */
- (NSInteger)fileTotalLength:(NSString *)url
{
    return [[NSDictionary dictionaryWithContentsOfFile:BBUperFileTotalLengthFullpath][BBUperFileFileName(url)] integerValue];
}

#pragma mark - 删除
/**
 *  删除该资源
 */
- (void)deleteFile:(NSString *)url
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:BBUperFileFullpath(url)]) {
        
        // 删除沙盒中的资源
        [fileManager removeItemAtPath:BBUperFileFullpath(url) error:nil];
        // 删除任务
        [self.tasks removeObjectForKey:BBUperFileFileName(url)];
        [self.sessionModels removeObjectForKey:@([self getTask:url].taskIdentifier).stringValue];
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:BBUperFileTotalLengthFullpath]) {
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:BBUperFileTotalLengthFullpath];
            [dict removeObjectForKey:BBUperFileFileName(url)];
            [dict writeToFile:BBUperFileTotalLengthFullpath atomically:YES];
            
        }
    }
}

/**
 *  清空所有下载资源
 */
- (void)deleteAllFile
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:BBUperFileCachesDirectory]) {
        // 删除沙盒中所有资源
        [fileManager removeItemAtPath:BBUperFileCachesDirectory error:nil];
        // 删除任务
        [[self.tasks allValues] makeObjectsPerformSelector:@selector(cancel)];
        [self.tasks removeAllObjects];
        
        for (BBUperSessionModel *sessionModel in [self.sessionModels allValues]) {
            [sessionModel.stream close];
        }
        [self.sessionModels removeAllObjects];
        
        // 删除资源总长度
        if ([fileManager fileExistsAtPath:BBUperFileTotalLengthFullpath]) {
            [fileManager removeItemAtPath:BBUperFileTotalLengthFullpath error:nil];
        }
    }
}

- (BOOL)unzipFile:(NSString *)filePath toFilePath:(NSString *)targetFilePath {
    ZipArchive *archive = [[ZipArchive alloc] init];
    if ([archive UnzipOpenFile:filePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:targetFilePath withIntermediateDirectories:NO attributes:nil error:nil];
        return [archive UnzipFileTo:targetFilePath overWrite:YES];
    }
    
    return NO;
}

#pragma mark - 代理
#pragma mark NSURLSessionDataDelegate
/**
 * 接收到响应
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    
    BBUperSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 打开流
    [sessionModel.stream open];
    
    // 获得服务器这次请求 返回数据的总长度
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + BBUperFileDownloadLength(sessionModel.url);
    sessionModel.totalLength = totalLength;
    
    // 存储总长度
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithContentsOfFile:BBUperFileTotalLengthFullpath];
    if (dict == nil) dict = [NSMutableDictionary dictionary];
    dict[BBUperFileFileName(sessionModel.url)] = @(totalLength);
    [dict writeToFile:BBUperFileTotalLengthFullpath atomically:YES];
    
    // 接收这个请求，允许接收服务器的数据
    completionHandler(NSURLSessionResponseAllow);
}

/**
 * 接收到服务器返回的数据
 */
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    BBUperSessionModel *sessionModel = [self getSessionModel:dataTask.taskIdentifier];
    
    // 写入数据
    [sessionModel.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = BBUperFileDownloadLength(sessionModel.url);
    NSUInteger expectedSize = sessionModel.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    sessionModel.progressBlock(receivedSize, expectedSize, progress);
}

/**
 * 请求完毕（成功|失败）
 */
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    BBUperSessionModel *sessionModel = [self getSessionModel:task.taskIdentifier];
    if (!sessionModel) return;
    
    if ([self isCompletion:sessionModel.url]) {
        // 下载完成
//        AVURLAsset *avasset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:BBUperFileFullpath(sessionModel.url)]];
//        CGFloat duration = CMTimeGetSeconds(avasset.duration);
//        if(isnan(duration) || duration <= 0){
//            sessionModel.stateBlock(DownloadStateInvalidFile,nil);
//            [self deleteFile:sessionModel.url];
//        } else {
            sessionModel.stateBlock(DownloadStateCompleted,BBUperFileFullpath(sessionModel.url));
//        }

    } else if (error){
        // 下载失败
        sessionModel.stateBlock(DownloadStateFailed,BBUperFileFullpath(sessionModel.url));
    }
    
    // 关闭流
    [sessionModel.stream close];
    sessionModel.stream = nil;
    
    // 清除任务
    [self.tasks removeObjectForKey:BBUperFileFileName(sessionModel.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
}

NSArray *LoadFolderContentsWithCachedUrl(NSString *downloadUrl) {
    //从磁盘加载素材包
    BOOL fileExists = [BBUperFileDownloadManager directoryExists:downloadUrl];
    if (fileExists) {
        
        NSString *cacheFullPath = [BBUperFileDownloadManager directoryCacheFullPath:downloadUrl];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSDirectoryEnumerator *dirEnumerator = [fileManager enumeratorAtURL:[NSURL URLWithString:cacheFullPath]
                                                 includingPropertiesForKeys:[NSArray arrayWithObjects:NSURLNameKey, NSURLIsDirectoryKey,nil] options:NSDirectoryEnumerationSkipsSubdirectoryDescendants errorHandler:nil];
        
        NSMutableArray *theArray = [NSMutableArray array];
        for (NSURL *theURL in dirEnumerator) {
            
            // Retrieve the file name. From NSURLNameKey, cached during the enumeration.
            NSString *fileName;
            [theURL getResourceValue:&fileName forKey:NSURLNameKey error:NULL];
            
            // Retrieve whether a directory. From NSURLIsDirectoryKey, also
            // cached during the enumeration.
            NSNumber *isDirectory;
            [theURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:NULL];
            
            if ([isDirectory boolValue] == NO) {
                [theArray addObject: fileName];
            }
        }
        return theArray;
    }
    else {
        return nil;
    }
}

@end
