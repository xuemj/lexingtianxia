//
//  BBUperCaptionListModel.m
//  BBUper
//
//  Created by Feng Stone on 2018/5/22.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperCaptionListModel.h"
#import "BBUperFileDownloadManager.h"

@implementation BBUperCaptionListModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.fontItemList = [aDecoder decodeObjectForKey:@"fontItemList"];
        self.filterItemList = [aDecoder decodeObjectForKey:@"filterItemList"];
        self.captionItemList = [aDecoder decodeObjectForKey:@"captionItemList"];
        self.filterCategoryItemList = [aDecoder decodeObjectForKey:@"filterCategoryItemList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_fontItemList forKey:@"fontItemList"];
    [aCoder encodeObject:_filterItemList forKey:@"filterItemList"];
    [aCoder encodeObject:_captionItemList forKey:@"captionItemList"];
    [aCoder encodeObject:_filterCategoryItemList forKey:@"filterCategoryItemList"];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"captionItemList":@"subtitle",
             @"fontItemList":@"font",
             @"filterItemList":@"filter",
             @"filterCategoryItemList":@"filter_with_category",
             };
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"captionItemList" : [BBUperCaptionItemModel class],
             @"fontItemList" : [BBUperFontItemModel class],
             @"filterItemList" : [BBUperFilterItemModel class],
             @"filterCategoryItemList" : [BBUperFilterCategoryItemModel class],
             };
}

@end

@implementation BBUperCaptionItemModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.cover = [aDecoder decodeObjectForKey:@"cover"];
        self.rank = [aDecoder decodeIntForKey:@"rank"];
        self.download_url = [aDecoder decodeObjectForKey:@"download_url"];
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.max = [aDecoder decodeIntForKey:@"max"];
        self.isInBundle = [aDecoder decodeBoolForKey:@"isInBundle"];
        self.pkgItem = [aDecoder decodeObjectForKey:@"pkgItem"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_cover forKey:@"cover"];
    [aCoder encodeInt:_rank forKey:@"rank"];
    [aCoder encodeObject:_download_url forKey:@"download_url"];
    [aCoder encodeObject:_modelId forKey:@"modelId"];
    [aCoder encodeInt:_max forKey:@"max"];
    [aCoder encodeBool:_isInBundle forKey:@"isInBundle"];
    [aCoder encodeObject:_pkgItem forKey:@"pkgItem"];
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"name":@"name",
             @"cover":@"cover",
             @"rank":@"rank",
             @"download_url":@"download_url",
             @"max":@"max",
             @"modelId":@"id"
             };
}

- (void)setModelId:(NSString *)modelId {
    if (modelId && ![modelId isKindOfClass:[NSString class]]) {
        _modelId = [NSString stringWithFormat:@"%@", modelId];
    }
    else {
        _modelId = modelId;
    }
}

- (BOOL)loadPackage {
    if (_isInBundle) {
        return YES;
    }
    
    if (self.pkgItem) {
        return YES;
    }
    
    NSArray *folderContents = LoadFolderContentsWithCachedUrl(self.download_url);
    if (folderContents == nil || [folderContents count] == 0) {
        return NO;
    }
    
    NSString *cacheFullPath = [BBUperFileDownloadManager directoryCacheFullPath:self.download_url];
    BBUperCaptionItem *item = [[BBUperCaptionItem alloc] init];
    item.itemId = self.modelId;
    item.max = self.max;
    for (NSString *fileName in folderContents) {
        if ([[[fileName pathExtension] lowercaseString] isEqualToString:@"captionstyle"]) {
            item.captionStyle = [cacheFullPath stringByAppendingPathComponent:fileName];
            continue;
        }
        if ([[[fileName pathExtension] lowercaseString] isEqualToString:@"lic"]) {
            item.captionLic = [cacheFullPath stringByAppendingPathComponent:fileName];
            continue;
        }
    }
    self.pkgItem = item;
    NSLog(@"load caption pkg: %@", self.name);
    
    return YES;
}

@end

@implementation BBUperFontItemModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.cover = [aDecoder decodeObjectForKey:@"cover"];
        self.rank = [aDecoder decodeIntForKey:@"rank"];
        self.download_url = [aDecoder decodeObjectForKey:@"download_url"];
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.pkgItem = [aDecoder decodeObjectForKey:@"pkgItem"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_cover forKey:@"cover"];
    [aCoder encodeInt:_rank forKey:@"rank"];
    [aCoder encodeObject:_download_url forKey:@"download_url"];
    [aCoder encodeObject:_modelId forKey:@"modelId"];
    [aCoder encodeObject:_pkgItem forKey:@"pkgItem"];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name":@"name",
             @"cover":@"cover",
             @"rank":@"rank",
             @"download_url":@"download_url",
             @"modelId":@"id"
             };
}

- (void)setModelId:(NSString *)modelId {
    if (modelId && ![modelId isKindOfClass:[NSString class]]) {
        _modelId = [NSString stringWithFormat:@"%@", modelId];
    }
    else {
        _modelId = modelId;
    }
}

- (BOOL)loadPackage {
    if (self.pkgItem) {
        return YES;
    }
    
    NSArray *folderContents = LoadFolderContentsWithCachedUrl(self.download_url);
    if (folderContents == nil || [folderContents count] == 0) {
        return NO;
    }
    
    NSString *cacheFullPath = [BBUperFileDownloadManager directoryCacheFullPath:self.download_url];
    BBUperFontItem *item = [[BBUperFontItem alloc] init];
    item.itemId = self.modelId;
    for (NSString *fileName in folderContents) {
        NSString *extension = [[fileName pathExtension] lowercaseString];
        if ([extension isEqualToString:@"ttf"] || [extension isEqualToString:@"otf"]) {
            item.captionPath = [cacheFullPath stringByAppendingPathComponent:fileName];
            continue;
        }
    }
    self.pkgItem = item;
    NSLog(@"load font pkg: %@", self.name);
    
    return YES;
}

@end


@implementation BBUperFilterItemModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        self.name = dictionary[@"name"];
        self.cover = dictionary[@"cover"];
        self.rank = [dictionary[@"rank"] intValue];
        self.download_url = dictionary[@"download_url"];
        self.modelId = dictionary[@"id"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.cover = [aDecoder decodeObjectForKey:@"cover"];
        self.rank = [aDecoder decodeIntForKey:@"rank"];
        self.download_url = [aDecoder decodeObjectForKey:@"download_url"];
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.pkgItem = [aDecoder decodeObjectForKey:@"pkgItem"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_cover forKey:@"cover"];
    [aCoder encodeInt:_rank forKey:@"rank"];
    [aCoder encodeObject:_download_url forKey:@"download_url"];
    [aCoder encodeObject:_modelId forKey:@"modelId"];
    [aCoder encodeObject:_pkgItem forKey:@"pkgItem"];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name":@"name",
             @"cover":@"cover",
             @"rank":@"rank",
             @"download_url":@"download_url",
             @"modelId":@"id"
             };
}

- (void)setModelId:(NSString *)modelId {
    if (modelId && ![modelId isKindOfClass:[NSString class]]) {
        _modelId = [NSString stringWithFormat:@"%@", modelId];
    }
    else {
        _modelId = modelId;
    }
}

- (BOOL)loadPackage {
    if (self.pkgItem) {
        return YES;
    }
    
    NSArray *folderContents = LoadFolderContentsWithCachedUrl(self.download_url);
    if (folderContents == nil || [folderContents count] == 0) {
        return NO;
    }
    
    NSString *xmlFile = nil;
    NSString *cacheFullPath = [BBUperFileDownloadManager directoryCacheFullPath:self.download_url];
    for (NSString *fileName in folderContents) {
        if ([[[fileName pathExtension] lowercaseString] isEqualToString:@"xml"]) {
            xmlFile = fileName;
            break;
        }
    }
    
    if (xmlFile == nil) {
        return NO;
    }
    
    BBUperFilterItem *item = [[BBUperFilterItem alloc] initWithXMLFile:xmlFile resourceFolder:cacheFullPath];
    item.itemId = _modelId;
    item.itemName = _name;//滤镜名称可能被修改，使用在线下发的名称。
    self.pkgItem = item;
    NSLog(@"load filter pkg: %@", self.name);
    
    return YES;
}


@end


@implementation BBUperFilterCategoryItemModel

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.name = [aDecoder decodeObjectForKey:@"name"];
        self.modelId = [aDecoder decodeObjectForKey:@"modelId"];
        self.children = [aDecoder decodeObjectForKey:@"children"];
        self.filterList = [aDecoder decodeObjectForKey:@"filterList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_modelId forKey:@"modelId"];
    [aCoder encodeObject:_children forKey:@"children"];
    [aCoder encodeObject:_filterList forKey:@"filterList"];
}

+ (NSDictionary<NSString *,id> *)modelCustomPropertyMapper {
    return @{@"name":@"name",
             @"modelId":@"id",
             @"children":@"children",
             };
}

- (void)setModelId:(NSString *)modelId {
    if (modelId && ![modelId isKindOfClass:[NSString class]]) {
        _modelId = [NSString stringWithFormat:@"%@", modelId];
    }
    else {
        _modelId = modelId;
    }
}

- (void)setChildren:(NSArray<NSDictionary *> *)children {
    _children = children;
    
    NSMutableArray *filterList = [NSMutableArray arrayWithCapacity:children.count];
    for (NSDictionary *dictionary in children) {
        BBUperFilterItemModel *filter = [[BBUperFilterItemModel alloc] initWithDictionary:dictionary];
        [filterList addObject:filter];
    }
    self.filterList = [NSArray arrayWithArray:filterList];
}

- (void)loadPackage {
    [self.filterList makeObjectsPerformSelector:@selector(loadPackage)];
}

@end



