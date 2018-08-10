//
//  BBUperBgmListModel.m
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmListModel.h"

@implementation BBUperBgmTimelineModel
- (NSDictionary *)json{
    return @{@"point" : @(self.point),@"comment" : self.comment?:@""};
}
- (instancetype)initWithDict:(NSDictionary *)json{
    if(self = [super init]){
        _point = [json[@"point"]longLongValue];
        _comment = json[@"comment"];
    }
    return self;
}
@end

@implementation BBUperBgmMediaModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"bgmId":@"sid",
             @"typeId":@"tid",
             @"name":@"name",
             @"author":@"musicians",
             @"coverUrl":@"cover",
             @"playUrl":@"playurl",
             @"time":@"duration",
             @"filesize":@"filesize",
             @"state":@"state",
             @"recommendPoint":@"recommend_point"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"timeline" : [BBUperBgmTimelineModel class]};
}

- (NSDictionary *)json{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    [json setObject:@(self.bgmId) forKey:@"bgmId"];
    [json setObject:self.name?:@"" forKey:@"name"];
    if(self.timeline.count){
        NSMutableArray *tps = [NSMutableArray array];
        for(int i = 0; i < self.timeline.count;++i){
            BBUperBgmTimelineModel *timelineModel = self.timeline[i];
            [tps addObject:timelineModel.json];
        }
        [json setObject:tps.copy forKey:@"timeline"];
    }
    return json;
}

- (instancetype)initWithDict:(NSDictionary *)json{
    if(!json){
        return nil;
    }
    if(self = [super init]){
        _bgmId = [json[@"bgmId"]longLongValue];
        _name = json[@"name"];
        NSArray *timelineDict = json[@"timeline"];
        if([timelineDict isKindOfClass:[NSArray class]] && timelineDict.count){
            NSMutableArray *tms = [NSMutableArray array];
            for(NSDictionary *dict in timelineDict){
                BBUperBgmTimelineModel *tm = [[BBUperBgmTimelineModel alloc]initWithDict:dict];
                [tms addObject:tm];
            }
            _timeline = tms.copy;
        }
    }
    return self;
}

@end

@implementation BBUperBgmTypeModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"typeId":@"id",
             @"typeName":@"name",
             @"index":@"index",
             @"bgmList":@"children"
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"bgmList" : [BBUperBgmMediaModel class]};
}

@end

@implementation BBUperBgmListModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"typeList":@"typelist"};
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"typeList" : [BBUperBgmTypeModel class]};
}

@end
