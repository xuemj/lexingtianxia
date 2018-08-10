//
//  BBUperBgmPointApi.m
//  BBUperVideoEditor
//
//  Created by xmj on 2018/7/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmPointApi.h"
#import "BBUperBgmListModel.h"
@implementation BBUperBgmPointApi

- (BFCApiRequestMethod)requestMethod {
    return BFCApiRequestMethodGET;
}

- (NSDictionary *)params {
    return @{@"sid":[@(self.sid) description]
            };
}

- (NSString *)requestUrl {
    return @"/x/app/bgm/view";
}

- (NSArray<BFCApiModelDescription *> *)modelDescriptions {
    return @[
             [BFCApiModelDescription modelWith:@"/data" mappingClass:[BBUperBgmMediaModel class] isArray:NO],
             ];
}
@end
