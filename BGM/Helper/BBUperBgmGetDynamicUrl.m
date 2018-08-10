//
//  BBUperBgmGetDynamicUrl.m
//  BBUperVideoEditor
//
//  Created by xmj on 2018/7/23.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmGetDynamicUrl.h"
#import "BBUperBgmDynamicUrlApi.h"
#import "BBUperBgmDataModel.h"
#import "BBUperBgmManager.h"
#import "BBUperBgmPointApi.h"
#import "BBUperBgmListModel.h"
@implementation BBUperBgmGetDynamicUrl

+ (void)getDynamicUrl:(int64_t)bgmId BgmType:(GetDynamicUrlType)type isRequestPoint:(BOOL)isRequest state:(void(^)(GetDynamicUrlState state,NSString *url,NSString *error,double point))stateBlock {
    BBUperBgmDynamicUrlApi *api = [[BBUperBgmDynamicUrlApi alloc]init];
    api.sid = bgmId;
    api.type = type;
    api.completionHandler = ^(NSDictionary * dict) {
        BBUperBgmDataModel *dataModel = dict[@"/data"];
        if (dataModel.cdns.count > 0) {
            NSString *url = dataModel.cdns[0];
            if (isRequest) {
                BBUperBgmPointApi *pointApi = [[BBUperBgmPointApi alloc]init];
                pointApi.sid = bgmId;
                pointApi.completionHandler = ^(NSDictionary * dict1) {
                    BBUperBgmMediaModel *model = dict1[@"/data"];
                    stateBlock(GetDynamicUrlStateSuccess,url,nil,model.recommendPoint);
                };
                pointApi.errorHandler = ^(NSError * error1, NSDictionary * dict1) {
                    stateBlock(GetDynamicUrlStateSuccess,url,nil,0);
                };
                [pointApi addToQueueAsync];
            } else {
                stateBlock(GetDynamicUrlStateSuccess,url,nil,0);
            }
        } else {
            stateBlock(GetDynamicUrlStateDataError,nil,@"音频未找到",0);
        }
        
    };
    api.errorHandler = ^(NSError * error, NSDictionary * dict) {
        if ([BFCReachability currentStatus] == NetworkStatusNotReachable) {
            stateBlock(GetDynamicUrlStateFail,nil,@"网络异常，请稍后再试",0);
        } else {
           stateBlock(GetDynamicUrlStateFail,nil,[[BBUperBgmManager shareInstance] codeForString:error.code],0);
        }
    };
    [api addToQueueAsync];
}
@end
