//
//  BBUperBgmListApi.m
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmListApi.h"
#import "BBUperBgmListModel.h"
@implementation BBUperBgmListApi

- (BFCApiRequestMethod)requestMethod {
    return BFCApiRequestMethodGET;
}

- (NSString *)requestUrl {
    return @"x/app/bgm/pre";
}

- (NSArray<BFCApiModelDescription *> *)modelDescriptions {
    return @[
             [BFCApiModelDescription modelWith:@"/data" mappingClass:[BBUperBgmListModel class] isArray:NO],
             ];
}

@end
