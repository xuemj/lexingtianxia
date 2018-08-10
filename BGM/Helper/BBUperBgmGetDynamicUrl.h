//
//  BBUperBgmGetDynamicUrl.h
//  BBUperVideoEditor
//
//  Created by xmj on 2018/7/23.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSInteger {
    GetDynamicUrlStateSuccess = 1,        ///获取动态url成功
    GetDynamicUrlStateFail  = 0,   ///错误
    GetDynamicUrlStateDataError = 2
}GetDynamicUrlState;

typedef enum : NSInteger {
    GetDynamicUrlTypePlay = 2,        ///播放类型
    GetDynamicUrlTypeDownload  = 1,   ///下载类型
}GetDynamicUrlType;

@interface BBUperBgmGetDynamicUrl : NSObject

+ (void)getDynamicUrl:(int64_t)bgmId BgmType:(GetDynamicUrlType)type isRequestPoint:(BOOL)isRequest state:(void(^)(GetDynamicUrlState state,NSString *url,NSString *error, double point))stateBlock;
@end
