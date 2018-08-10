//
//  BBUperBgmDynamicUrlApi.h
//  BBUper
//
//  Created by xmj on 2018/4/26.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseApi.h"

@interface BBUperBgmDynamicUrlApi : BBUperVideoEditorBaseApi

@property (nonatomic, assign) int64_t sid;
@property (nonatomic, assign) NSInteger type;    // 访问类型：1-下载；2-收听
//@property (nonatomic, assign) int quality; //3-sq；2-hq；1-std；0-smooth

@end
