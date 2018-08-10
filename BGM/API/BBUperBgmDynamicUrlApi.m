//
//  BBUperBgmDynamicUrlApi.m
//  BBUper
//
//  Created by xmj on 2018/4/26.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmDynamicUrlApi.h"
#import "BBUperBgmDataModel.h"
@implementation BBUperBgmDynamicUrlApi

- (BFCApiRequestMethod)requestMethod {
    return BFCApiRequestMethodGET;
}

- (NSDictionary *)params {
    return @{@"mid":[BFCAccount userSID],
             @"songid":[@(self.sid) description],
             @"privilege":[@(self.type) description],
             @"quality":@"2",
             @"platform":@"ios"};
}

- (NSString *)requestUrl {
    return @"https://www.bilibili.com/audio/music-service-c/url";
}

- (NSArray<BFCApiModelDescription *> *)modelDescriptions {
    return @[
             [BFCApiModelDescription modelWith:@"/data" mappingClass:[BBUperBgmDataModel class] isArray:NO],
             ];
}

@end
