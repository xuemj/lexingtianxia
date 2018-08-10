//
//  BBUperCaptionListModel.h
//  BBUper
//
//  Created by Feng Stone on 2018/5/22.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseModel.h"
#import "BBUperCaptionItem.h"
#import "BBUperFontItem.h"
#import "BBUperFilterItem.h"

@class BBUperCaptionItemModel;
@class BBUperFontItemModel;
@class BBUperFilterItemModel;
@class BBUperFilterCategoryItemModel;
@interface BBUperCaptionListModel : BBUperVideoEditorBaseModel <NSCoding>

@property (nonatomic, strong) NSArray<BBUperCaptionItemModel *> *captionItemList;
@property (nonatomic, strong) NSArray<BBUperFontItemModel *> *fontItemList;
@property (nonatomic, strong) NSArray<BBUperFilterItemModel *> *filterItemList;
@property (nonatomic, strong) NSArray<BBUperFilterCategoryItemModel *> *filterCategoryItemList;

@end

@interface BBUperCaptionItemModel : BBUperVideoEditorBaseModel <NSCoding>

@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *download_url;
@property (nonatomic, assign) int rank;
@property (nonatomic, assign) int max;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isInBundle;
@property (nonatomic, strong) BBUperCaptionItem *pkgItem;

// 从磁盘加载缓存的素材内容
- (BOOL)loadPackage;

@end

@interface BBUperFontItemModel : BBUperVideoEditorBaseModel <NSCoding>

@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *download_url;
@property (nonatomic, assign) int rank;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) BBUperFontItem *pkgItem;

// 从磁盘加载缓存的素材内容
- (BOOL)loadPackage;

@end

@interface BBUperFilterItemModel : BBUperVideoEditorBaseModel <NSCoding>

@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *cover;
@property (nonatomic, strong) NSString *download_url;
@property (nonatomic, assign) int rank;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) BBUperFilterItem *pkgItem;

// 从磁盘加载缓存的素材内容
- (BOOL)loadPackage;

@end

@interface BBUperFilterCategoryItemModel : BBUperVideoEditorBaseModel <NSCoding>

@property (nonatomic, strong) NSString *modelId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<NSDictionary *> *children;
@property (nonatomic, strong) NSArray<BBUperFilterItemModel *> *filterList;
@property (nonatomic, assign) BOOL isSelected;

- (void)loadPackage;

@end

