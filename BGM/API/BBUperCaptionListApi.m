//
//  BBUperCaptionListApi.m
//  BBUper
//
//  Created by Feng Stone on 2018/5/22.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperCaptionListApi.h"
#import "BBUperCaptionListModel.h"

@implementation BBUperCaptionListApi

- (BFCApiRequestMethod)requestMethod {
    return BFCApiRequestMethodGET;
}

- (NSString *)requestUrl {
    return @"x/app/material/pre";
}

- (NSArray<BFCApiModelDescription *> *)modelDescriptions {
    return @[
             [BFCApiModelDescription modelWith:@"/data" mappingClass:[BBUperCaptionListModel class] isArray:NO],
             ];
}

@end
