//
//  BBUperBgmManagerVC.h
//  BBUper
//
//  Created by xmj on 2018/4/19.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperVideoEditorBaseVC.h"

@class BBUperBgmListModel;
@class BBUperBgmMediaModel;
typedef void(^DownloadBlock)(NSString *url,BBUperBgmMediaModel *model,double point);
typedef void(^BackBlock)(BOOL isBack);
@interface BBUperBgmManagerVC : BBUperVideoEditorBaseVC
@property (nonatomic, copy) DownloadBlock urlBlock;
@property (nonatomic, copy) BackBlock backBlock;

- (instancetype)initWithActivitySid:(int64_t)sid;
@end



