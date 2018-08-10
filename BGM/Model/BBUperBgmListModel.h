//
//  BBUperBgmListModel.h
//  BBUper
//
//  Created by xmj on 2018/4/24.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseModel.h"

@interface BBUperBgmTimelineModel :BBUperVideoEditorBaseModel
@property (nonatomic, assign) int64_t point;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic, assign) int64_t recommend;
@end

@interface BBUperBgmMediaModel :BBUperVideoEditorBaseModel
@property (nonatomic, assign) int64_t  bgmId;
@property (nonatomic, assign) NSInteger typeId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *playUrl;
@property (nonatomic, assign) int  time;
@property (nonatomic, assign) int64_t  filesize;
@property (nonatomic, assign) NSInteger state;
@property (nonatomic, strong) NSArray *tags;
@property (nonatomic, strong) NSArray<BBUperBgmTimelineModel *> *timeline;
@property (nonatomic, assign) double recommendPoint;
- (NSDictionary *)json;
- (instancetype)initWithDict:(NSDictionary *)json;
@end

@interface BBUperBgmTypeModel :BBUperVideoEditorBaseModel
@property (nonatomic, assign) NSInteger typeId;
@property (nonatomic, strong) NSString  *typeName;
@property (nonatomic, assign) NSInteger index;
@property (nonatomic, strong) NSArray  *bgmList;
@end

@interface BBUperBgmListModel : BBUperVideoEditorBaseModel
@property (nonatomic, strong) NSArray *typeList;
@end
