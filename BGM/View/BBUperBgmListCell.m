//
//  BBUperBgmListCell.m
//  BBUper
//
//  Created by xmj on 2018/4/19.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmListCell.h"
#import "BBUperBgmListModel.h"
#import "BBUperBgmManager.h"
#import "BBUperBgmSliderView.h"

@interface BBUperBgmListCell ()
@property (nonatomic, strong) UIImageView *coverImg;
@property (nonatomic, strong) UIImageView *statueImg;
@property (nonatomic, strong) UILabel *title;
@property (nonatomic, strong) UILabel *author;
@property (nonatomic, strong) UILabel *time;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, strong) UIButton *clickBtn;
@property (nonatomic, strong) UILabel *lb1;
@property (nonatomic, strong) UILabel *lb2;
@property (nonatomic, strong) UILabel *lb3;
@property (nonatomic, strong) UILabel *lb4;
@property (nonatomic) BOOL isSelected;
@property (nonatomic, strong)BBUperBgmSliderView *bgmTrackView;

@end

@implementation BBUperBgmListCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isSelected = NO;
        self.lb1.hidden = YES;
        self.lb2.hidden = YES;
        self.lb3.hidden = YES;
        self.lb4.hidden = YES;
        self.bgmTrackView.hidden = YES;
        self.contentView.backgroundColor = HEXCOLOR(0xF4F5F7);
        [self.contentView addSubview:self.coverImg];
        [self.contentView addSubview:self.statueImg];
        [self.contentView addSubview:self.title];
        [self.contentView addSubview:self.author];
        [self.contentView addSubview:self.lb1];
        [self.contentView addSubview:self.lb2];
        [self.contentView addSubview:self.lb3];
        [self.contentView addSubview:self.lb4];
        [self.contentView addSubview:self.time];
        [self.contentView addSubview:self.line];
        [self.contentView addSubview:self.clickBtn];
        [self.contentView addSubview:self.bgmTrackView];
        [self.coverImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.top.equalTo(@12);
            make.width.height.equalTo(@60);
        }];
        [self.statueImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.centerY.equalTo(self.coverImg);
            make.width.height.equalTo(@18);
        }];
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.coverImg.mas_right).offset(12);
            make.top.equalTo(@24);
            make.right.equalTo(self.contentView.mas_right).offset(-84);
            make.height.equalTo(@14);
        }];
        [self.author mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.title.mas_bottom).offset(5);
            make.left.equalTo(self.title);
            make.right.equalTo(self.contentView.mas_right).offset(-84);
            make.height.equalTo(@14);
        }];
        [self.lb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.author.mas_bottom).offset(5);
            make.left.equalTo(self.title);
            make.height.equalTo(@15);
            
        }];
        [self.lb2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lb1.mas_top);
            make.left.equalTo(self.lb1.mas_right).offset(8);
            make.height.equalTo(@15);
            
        }];
        [self.lb3 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lb2.mas_top);
            make.left.equalTo(self.lb2.mas_right).offset(8);
            make.height.equalTo(@15);
           
        }];
        
        [self.lb4 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.lb3.mas_top);
            make.left.equalTo(self.lb3.mas_right).offset(8);
            make.height.equalTo(@15);
            
        }];
        
        [self.time mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.coverImg);
            make.right.equalTo(self.contentView).offset(-12);
            make.height.equalTo(@14);
        }];
        
        [self.clickBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.contentView).offset(-12);
            make.centerY.equalTo(self.coverImg);
            make.width.equalTo(@72);
            make.height.equalTo(@30);
        }];
    
        [self.line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@12);
            make.right.bottom.equalTo(self.contentView);
            make.height.equalTo(@0.5);
        }];

    }
    return self;
}

- (BBUperBgmSliderView *)bgmTrackView {
    if (!_bgmTrackView) {
        _bgmTrackView = [[BBUperBgmSliderView alloc]initWithFrame:CGRectMake(0, 78, BiliScreenWidth-12, 70) defaultPoint:0 totalTime:300 sliderImage:BBUperImageMake(@"videoediting_slider")];
        @weakify(self);
        _bgmTrackView.block=^(double index){
            @strongify(self);
            if (self.seekTimeBlock) {
                self.seekTimeBlock(index);
            }
            [BBUperBgmManager shareInstance].playSeekTime = index;
        };
    }
    return _bgmTrackView;
}

- (UIImageView *)coverImg {
    if (!_coverImg) {
        _coverImg = [[UIImageView alloc]init];
        _coverImg.layer.masksToBounds = YES;
        _coverImg.layer.cornerRadius = 4;
        _coverImg.alpha = 0.5;
    }
    return _coverImg;
}

- (UIImageView *)statueImg {
    if (!_statueImg) {
        _statueImg = [[UIImageView alloc]init];
    }
    return _statueImg;
}

- (UILabel *)title {
    if (!_title) {
        _title = [[UILabel alloc]init];
        _title.font = [UIFont systemFontOfSize:14];
        _title.textColor = HEXCOLOR(0x8E8E8E);
    }
    return _title;
}

- (UILabel *)author {
    if (!_author) {
        _author = [[UILabel alloc]init];
        _author.font = [UIFont systemFontOfSize:12];
        _author.textColor = HEXCOLOR(0x686868);
    }
    return _author;
}

- (UILabel *)lb1 {
    if (!_lb1) {
        _lb1 = [[UILabel alloc]init];
        _lb1.backgroundColor = HEXCOLOR(0xFB9E60);
        _lb1.textColor = [UIColor whiteColor];
        _lb1.font = [UIFont systemFontOfSize:10];
        _lb1.layer.masksToBounds = YES;
        _lb1.layer.cornerRadius = 2;
        _lb1.textAlignment = NSTextAlignmentCenter;
    }
    return _lb1;
}

- (UILabel *)lb2 {
    if (!_lb2) {
        _lb2 = [[UILabel alloc]init];
        _lb2.backgroundColor = HEXCOLOR(0xFB9E60);
        _lb2.textColor = [UIColor whiteColor];
        _lb2.font = [UIFont systemFontOfSize:10];
        _lb2.layer.masksToBounds = YES;
        _lb2.layer.cornerRadius = 2;
        _lb2.textAlignment = NSTextAlignmentCenter;
    }
    return _lb2;
}

- (UILabel *)lb3 {
    if (!_lb3) {
        _lb3 = [[UILabel alloc]init];
        _lb3.backgroundColor = HEXCOLOR(0xFB9E60);
        _lb3.textColor = [UIColor whiteColor];
        _lb3.font = [UIFont systemFontOfSize:10];
        _lb3.layer.masksToBounds = YES;
        _lb3.layer.cornerRadius = 2;
        _lb3.textAlignment = NSTextAlignmentCenter;
    }
    return _lb3;
}

- (UILabel *)lb4 {
    if (!_lb4) {
        _lb4 = [[UILabel alloc]init];
        _lb4.backgroundColor = HEXCOLOR(0xFB9E60);
        _lb4.textColor = [UIColor whiteColor];
        _lb4.font = [UIFont systemFontOfSize:10];
        _lb4.layer.masksToBounds = YES;
        _lb4.layer.cornerRadius = 2;
        _lb4.textAlignment = NSTextAlignmentCenter;
    }
    return _lb4;
}

- (UILabel *)time {
    if (!_time) {
        _time = [[UILabel alloc]init];
        _time.font = [UIFont systemFontOfSize:14];
        _time.hidden = NO;
        _time.textColor = HEXCOLOR(0x686868);
    }
    return _time;
}

- (UIView *)line {
    if (!_line) {
        _line = [[UIView alloc]init];
        _line.backgroundColor = HEXCOLOR(0x333333);
    }
    return _line;
}

- (UIButton *)clickBtn {
    if (!_clickBtn) {
        _clickBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_clickBtn setTitle:@"确认使用" forState:UIControlStateNormal];
        [_clickBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _clickBtn.backgroundColor = HEXCOLOR(0xFB7299);
        _clickBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        _clickBtn.layer.masksToBounds = YES;
        _clickBtn.layer.cornerRadius = 4;
        _clickBtn.hidden = YES;
        [_clickBtn addTarget:self action:@selector(click) forControlEvents:UIControlEventTouchUpInside];
    }
    return _clickBtn;
}

- (void)click {
    if (self.clickBlock) {
        self.clickBlock();
    }
}

- (void)insTallWithMediaInfo:(BBUperBgmMediaModel *)mediaSource isCurrentMedia:(BOOL)isCurrent {
    if (mediaSource) {
        NSMutableArray *arr = [NSMutableArray array];
        if (mediaSource.bgmId == [BBUperBgmManager shareInstance].activitySid) {
            [arr addObject:@"活动推荐"];
        }
        [arr addObjectsFromArray:mediaSource.tags];
        [self layoutTagsView:arr];

        self.isSelected = isCurrent;
        @weakify(self);
        [self.coverImg bfc_setImageWithURL:[NSURL URLWithString:mediaSource.coverUrl]
                                      ptSize:CGSizeMake(60, 60)
                            placeholderImage:[BBUperVideoEditorImageManager defaultTVImageWithSize:CGSizeMake(60, 60)]
                                     options:0
                                   completed:^(UIImage *image, NSError *error, BFCWebImageCacheType cacheType, NSURL *imageURL) {
                                       @strongify(self);
                                       if (!error) {
                                           if (cacheType == BFCWebImageCacheNone) {
                                               self.coverImg.alpha = 0.0;
                                               [UIView animateWithDuration:0.3
                                                                animations:^{
                                                                    self.coverImg.alpha = 0.5;
                                                                } completion:^(BOOL finish) {
                                                                }];
                                           }        }
                                   }];
        self.title.text = mediaSource.name;
        self.author.text = mediaSource.author;
        self.time.text = [self timeforString:mediaSource.time];
        self.bgmTrackView.currentTime = [BBUperBgmManager shareInstance].playSeekTime > 0 ? [BBUperBgmManager shareInstance].playSeekTime : (mediaSource.recommendPoint/1000); //服务器返回数据转化为秒来设定初始位置
        self.bgmTrackView.totalTime = mediaSource.time;
        if (isCurrent) {
            [self selectedState];
            [self.bgmTrackView reseatStartPoint:NO];
        } else {
            [self normalState];
            [self.bgmTrackView reseatStartPoint:YES];
        }
    }
}

- (void)layoutTagsView:(NSArray *)tags {
    
    if (!tags || tags.count == 0) {
        self.lb1.hidden = self.lb2.hidden = self.lb3.hidden = self.lb4.hidden = YES;
    }
    if (tags.count == 1) {
        self.lb1.hidden = NO;
        self.lb2.hidden = self.lb3.hidden = self.lb4.hidden = YES;
        self.lb1.text = tags[0];
    } else if (tags.count == 2) {
        self.lb1.hidden = self.lb2.hidden = NO;
        self.lb3.hidden = self.lb4.hidden = YES;
        self.lb1.text = tags[0];
        self.lb2.text = tags[1];
    } else if (tags.count == 3) {
        self.lb1.hidden = self.lb2.hidden = self.lb3.hidden = NO;
        self.lb4.hidden = YES;
        self.lb1.text = tags[0];
        self.lb2.text = tags[1];
        self.lb3.text = tags[2];
    } else if (tags.count == 4) {
        self.lb1.hidden = self.lb2.hidden = self.lb3.hidden = self.lb4.hidden = NO;
        self.lb1.text = tags[0];
        self.lb2.text = tags[1];
        self.lb3.text = tags[2];
        self.lb4.text = tags[3];
    }
    CGSize size1 = [self getFontSize:self.lb1.font withSize:CGSizeMake(MAXFLOAT, 15) withText:self.lb1.text];
    CGSize size2 = [self getFontSize:self.lb2.font withSize:CGSizeMake(MAXFLOAT, 15) withText:self.lb2.text];
    CGSize size3 = [self getFontSize:self.lb3.font withSize:CGSizeMake(MAXFLOAT, 15) withText:self.lb3.text];
    CGSize size4 = [self getFontSize:self.lb4.font withSize:CGSizeMake(MAXFLOAT, 15) withText:self.lb4.text];
    [self.lb1 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size1.width+10));
    }];
    [self.lb2 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size2.width+10));
    }];
    [self.lb3 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size3.width+10));
    }];
    [self.lb4 mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(size4.width+10));
    }];
}

- (void)normalState {
    self.time.hidden = NO;
    self.clickBtn.hidden = YES;
    self.bgmTrackView.hidden = YES;
    self.statueImg.hidden = YES;
    self.contentView.backgroundColor = HEXCOLOR(0x1B1B1B);
    self.statueImg.image = BBUperImageMake(@"bgm_play");
}

- (void)selectedState {
    self.time.hidden = YES;
    self.clickBtn.hidden = NO;
    self.bgmTrackView.hidden = NO;
    self.statueImg.hidden = NO;
    self.contentView.backgroundColor = HEXCOLOR(0x2D2D2D);
    [[RACObserve([BBUperBgmManager shareInstance], playState) takeUntil:[self rac_prepareForReuseSignal]] subscribeNext:^(NSNumber *value) {
        if (self.isSelected) {
            if ([value integerValue] == BBUperBgmStatePlay) {
                self.statueImg.image = BBUperImageMake(@"bgm_pause");
            } else if ([value integerValue] == BBUperBgmStatePause) {
                self.statueImg.image = BBUperImageMake(@"bgm_play");
            }  else if ([value integerValue] == BBUperBgmStateisLoading) {
                self.statueImg.image = BBUperImageMake(@"bgm_loading");
            }
        } else {
            self.statueImg.image = BBUperImageMake(@"bgm_play");
        }
    }];
}

- (NSString *)timeforString:(int)time {
    
    int seconds = time % 60;
    int minutes = (time/ 60) % 60;
    return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

// 获取文字size
- (CGSize)getFontSize:(UIFont *)font withSize:(CGSize)cgSize withText:(NSString *)text {
    if (![text isKindOfClass:[NSNull class]]) {
        CGRect textRect = [text boundingRectWithSize:cgSize
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:font}
                                             context:nil];
        CGSize size = textRect.size;
        return size;
    }
    return CGSizeZero;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (self.isSelected &&[view isKindOfClass:[BBUperBgmSliderView class]]) {
        if (self.openBlock) {
            self.openBlock(NO);
        }
    } else {
        if (self.openBlock) {
            self.openBlock(YES);
        }
    }
    return view;
}

@end
