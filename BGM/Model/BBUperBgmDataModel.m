//
//  BBUperBgmDataModel.m
//  BBUper
//
//  Created by xmj on 2018/4/26.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmDataModel.h"

@implementation BBUperBgmDataModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"bgmId":@"sid",
             @"typeId":@"type",
             @"info":@"info",
             @"timeout":@"timeout",
             @"filesize":@"filesize",
             @"cdns":@"cdns",
             };
}

@end
