//
//  BBUperBgmDataModel.h
//  BBUper
//
//  Created by xmj on 2018/4/26.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseModel.h"

@interface BBUperBgmDataModel : BBUperVideoEditorBaseModel
@property (nonatomic, assign) int64_t  bgmId;
@property (nonatomic, assign) NSInteger typeId;
@property (nonatomic, strong) NSString *info;
@property (nonatomic, assign) int  timeout;
@property (nonatomic, assign) int64_t  filesize;
@property (nonatomic, strong) NSArray *cdns;
@end
