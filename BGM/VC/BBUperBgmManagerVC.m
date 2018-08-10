//
//  BBUperBgmManagerVC.m
//  BBUper
//
//  Created by xmj on 2018/4/19.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBgmManagerVC.h"
#import "BBUperBaseBgmListVC.h"
#import "BBUperBgmManager.h"
#import "BBUperBgmListModel.h"
#import "BBUperBgmListApi.h"
#import "BBUperBgmDynamicUrlApi.h"
#import "BBUperBgmDataModel.h"
#import "BBUperVideoEditorContainerRabbitTopBar.h"
#import <AVFoundation/AVFoundation.h>
#import <BFCTracker/BFCTracker.h>
#import "BBUperVideoEditorEmptyListView.h"
#import "BBUperBgmGetDynamicUrl.h"

@interface BBUperBgmManagerVC ()<BBUperVideoEditorContainerTopBarDelegate,BBUperBgmClickDelegate>

@property (nonatomic, strong) BBUperVideoEditorControllerContainerRabbitView *pagesContainer;
@property (nonatomic, strong) NSMutableArray *bgmListVCArr;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic) NSInteger lastPage;
@property (nonatomic, strong) NSString *playUrl;
@property (nonatomic, strong) AVPlayerItem *playItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) NSString *currentPlayUrl;
@property (nonatomic, assign) double recommentPoint;

@end

@implementation BBUperBgmManagerVC

// 带活动bgmid的初始化
- (instancetype)initWithActivitySid:(int64_t)sid {
    self = [super init];
    if (self) {
        self.bgmListVCArr = [NSMutableArray array];
        self.lastPage = [[BBUperBgmManager shareInstance] currentPage];
        [BBUperBgmManager shareInstance].activitySid = sid; //保存传进来的活动bgmId
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initUI];
    [self _installLayout];
    [self _bind];
    [self _initData];
    self.player = [[AVPlayer alloc]init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    // 添加检测app进入后台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name: UIApplicationDidEnterBackgroundNotification object:nil];
}

- (void)_initData {
    BBUperBaseBgmListVC *bgmListVC = [[BBUperBaseBgmListVC alloc]initWithMediaList:@[] page:0];
    bgmListVC.title = @"音乐列表";
    [self.bgmListVCArr addObject:bgmListVC];
    [bgmListVC.noDataView showCurrentStateViewWithType:BBUperVideoEditorEmptyListLoading];
    [bgmListVC.noDataView setNightContentColor];
    bgmListVC.noDataView.hidden = NO;
    self.pagesContainer.contentControllers = self.bgmListVCArr;
    BBUperBgmListApi *api = [[BBUperBgmListApi alloc]init];
    @weakify(self);
    api.completionHandler = ^(NSDictionary * dict) {
        @strongify(self);
        BBUperBgmListModel *model = dict[@"/data"];
        [self initChildrenControllers:model.typeList];
    };

    api.errorHandler = ^(NSError * error, NSDictionary * dict) {
        @strongify(self);
        [self initChildrenControllers:nil];
    };
    [api addToQueueAsync];
}

- (void)back {
    [BFCTracker trackCustomEvent:@"000225" params:@{@"0":@"contribute_musiclist_back_click", @"1":@"click"}];
    if (self.backBlock) {
        self.backBlock(YES);
    }
    [BBUperBgmManager shareInstance].activitySid = 0;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.player pause];
}
#pragma mark - Init

- (void)_initUI {

    self.backBtn = ({
        UIButton *button = [UIButton new];
        [button setImage:[BBUperImageMake(@"common_back") bfc_imageWithTintColor:[UIColor whiteColor]]  forState:UIControlStateNormal];
        button;
    });
    self.pagesContainer = ({
        BBUperVideoEditorControllerContainerRabbitView *pagesContainer = [[BBUperVideoEditorControllerContainerRabbitView alloc] init];
        pagesContainer.topBar.backgroundColor = HEXCOLOR(0x1B1B1B);
        pagesContainer.topBar.selectionIndicator.backgroundColor = [UIColor whiteColor];
        pagesContainer.topBarHeight = [UIDevice bfc_isIPhoneX] ? 88 : 64;
        pagesContainer.topBar.buttonColor = [UIColor whiteColor];
        pagesContainer.topBar.buttonUnColor = [UIColor lightGrayColor];
        pagesContainer.topBar.itemWidth = 60;
        pagesContainer.topBar.itemPadding = 40;
        pagesContainer.topBar.titleFont = [UIFont systemFontOfSize:14];
        pagesContainer.topBar.leftPadding = 0;
        pagesContainer.topBar.rightPadding = 0;
        pagesContainer.topBar.bottomLine.hidden = YES;
        pagesContainer;
    });

}

- (void)_installLayout {
    [self.pagesContainer.topBar addSubview:self.backBtn];
    [self.view addSubview:self.pagesContainer];
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.pagesContainer.topBar).offset(2);
        make.height.equalTo(@44);
        make.width.equalTo(@44);
        make.top.equalTo(@([UIDevice bfc_isIPhoneX] ? 44 : 20));
    }];
    [self.pagesContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initChildrenControllers:(NSArray *)dataArr {
    [self _initUI];
    [self _installLayout];
    [self _bind];
    [self.bgmListVCArr removeAllObjects];
    if (dataArr.count > 0) {
        self.pagesContainer.topBar.leftPadding = 44;
        for (int i = 0; i < dataArr.count; i++) {
            BBUperBgmTypeModel *typeModel = dataArr[i];
            BBUperBaseBgmListVC *bgmListVC = [[BBUperBaseBgmListVC alloc]initWithMediaList:typeModel.bgmList page:i];
            bgmListVC.delegate = self;
            if (i == [[BBUperBgmManager shareInstance] currentPage]) {
                bgmListVC.isPageSelected = YES;
            }
            bgmListVC.title = typeModel.typeName;
            @weakify(self);
            [[[bgmListVC.command executionSignals] switchToLatest] subscribeNext:^(RACTuple *tuple) {
                @strongify(self);
                NSInteger pageIndex = [tuple.first integerValue];
                NSInteger index = [tuple.second integerValue];
                [[BBUperBgmManager shareInstance] setCurrentIndex:index];
                [[BBUperBgmManager shareInstance] setCurrentPage:pageIndex];

                [bgmListVC resetListState:YES];
                if (self.lastPage != pageIndex &&self.lastPage < dataArr.count) {
                    BBUperBaseBgmListVC *lastBgmListVC = [self.bgmListVCArr objectAtIndex:self.lastPage];
                    [lastBgmListVC resetListState:NO];
                    self.lastPage = pageIndex;
                }
            }];
            [self.bgmListVCArr addObject:bgmListVC];
        }
        self.pagesContainer.contentControllers = self.bgmListVCArr;
        self.pagesContainer.topBar.delegate = self;
        [self.pagesContainer.topBar setSelectedIndex:[[BBUperBgmManager shareInstance] currentPage] ? : 0 animated:YES];
    } else {
        BBUperBaseBgmListVC *bgmListVC = [[BBUperBaseBgmListVC alloc]initWithMediaList:nil page:0];
        bgmListVC.title = @"音乐列表";
        [self.bgmListVCArr addObject:bgmListVC];
        self.pagesContainer.contentControllers = self.bgmListVCArr;
        self.pagesContainer.topBar.delegate = self;
        [self.pagesContainer.topBar setSelectedIndex:0 animated:NO];
    }
}

- (void)_bind {
   [self.backBtn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - bgmClickDelegate
- (void)bbuperBgmPlay:(BBUperBgmMediaModel *)model isChangeBgm:(BOOL)isChange {
    [BFCTracker trackCustomEvent:@"000225" params:@{@"0":@"contribute_musiclist_play_click", @"1":@"click",@"2":[@(model.bgmId) description]}];
    [self.player pause];
    if (isChange) {
        [BBUperBgmManager shareInstance].playState = BBUperBgmStateisLoading;
        [self bbUperBgmDynamicUrl:model isChangeBgm:isChange];
    } else {
        if (self.currentPlayUrl) {
           [self playCurrentUrl:self.currentPlayUrl bgmModel:model isChangeItem:isChange];
        } else {
            [BBUperBgmManager shareInstance].playState = BBUperBgmStateisLoading;
            [self bbUperBgmDynamicUrl:model isChangeBgm:isChange];
        }
    }

}

- (void)bbuperBgmSeekTimePlay:(int)seekTime {
    if ([BBUperBgmManager shareInstance].playState == BBUperBgmStatePause) {
        [self.player play];
        [BBUperBgmManager shareInstance].playState = BBUperBgmStatePlay;
    }
    [self.player seekToTime:CMTimeMake(seekTime, 1)];
    self.recommentPoint = (double)seekTime*1000; //以豪秒为单位传给拍摄界面
}

- (void)bbUperBgmDynamicUrl:(BBUperBgmMediaModel *)model isChangeBgm:(BOOL)isChange {

    @weakify(self);
    [BBUperBgmGetDynamicUrl getDynamicUrl:model.bgmId BgmType:GetDynamicUrlTypeDownload isRequestPoint:NO state:^(GetDynamicUrlState state, NSString *url,NSString *error,double point) {
        @strongify(self);
        if (state == GetDynamicUrlStateSuccess) {
            self.currentPlayUrl = url;
            [self playCurrentUrl:self.currentPlayUrl bgmModel:model isChangeItem:isChange];
        } else if (state == GetDynamicUrlStateDataError) {
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
            [BFCToast showCenterToast:error];
        } else if (state == GetDynamicUrlStateFail) {
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
            [BFCToast showCenterToast:error];
        }
    }];
}

- (void)playCurrentUrl:(NSString *)url bgmModel:(BBUperBgmMediaModel *)model isChangeItem:(BOOL)isChange {

    if (self.playItem) {
        [self.playItem removeObserver:self forKeyPath:@"status"];
    }
    self.playItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    [self.playItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    if (isChange) {
        [self.player replaceCurrentItemWithPlayerItem:self.playItem];
        [self.player play];
        double time = [BBUperBgmManager shareInstance].playSeekTime > 0 ? [BBUperBgmManager shareInstance].playSeekTime : model.recommendPoint/1000;
        [self.player seekToTime:CMTimeMake(time, 1)];
        self.recommentPoint = model.recommendPoint;
    } else {
        if ([BBUperBgmManager shareInstance].playState == BBUperBgmStatePlay) {
            [self.player pause];
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
        } else if ([BBUperBgmManager shareInstance].playState == BBUperBgmStatePause) {
            [self.player play];
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePlay;
        }
    }
}
#pragma mark AVPlayer status
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object ==self.playItem && [keyPath isEqualToString:@"status"]) {
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey]integerValue];
        if (status == AVPlayerStatusReadyToPlay) {
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePlay;
        } else if (status == AVPlayerStatusFailed) {
            [BFCToast showCenterToast:@"音乐播放失败，请稍后再试"];
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
        } else if (status == AVPlayerStatusUnknown) {
            [BFCToast showCenterToast:@"音乐播放失败，请稍后再试"];
            [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
        }
    }
}

- (void)playbackFinished:(AVPlayer *)player {
    [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
    [self.player seekToTime:CMTimeMake(0, 1)];
}

- (void)applicationEnterBackground {
    [self.player pause];
    [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
}

- (void)bbuperBgmDownload:(BBUperBgmMediaModel *)model {
    [BFCTracker trackCustomEvent:@"000225" params:@{@"0":@"contribute_musiclist_confirm_click", @"1":@"click",@"2":[@(model.bgmId) description],@"3":[@(model.typeId) description]}];
    @weakify(self);
    [BBUperBgmGetDynamicUrl getDynamicUrl:model.bgmId BgmType:GetDynamicUrlTypeDownload isRequestPoint:NO state:^(GetDynamicUrlState state, NSString *url,NSString *error,double point) {
        @strongify(self);
        if (state == GetDynamicUrlStateSuccess) {
            if (self.urlBlock) {
                self.urlBlock(url,model,self.recommentPoint);
            }
            if (self.backBlock) {
                self.backBlock(NO);
            }
            if ([BBUperBgmManager shareInstance].playState == BBUperBgmStatePlay) {
                [self.player pause];
                [BBUperBgmManager shareInstance].playState = BBUperBgmStatePause;
            }
            [self.navigationController popViewControllerAnimated:YES];
        } else if (state == GetDynamicUrlStateDataError) {
            [BFCToast showCenterToast:error];
        } else if (state == GetDynamicUrlStateFail) {
            [BFCToast showCenterToast:error];
        }
    }];
}

- (void)bbuperScrollEnable:(BOOL)isEnable {
    self.pagesContainer.scrollView.scrollEnabled = isEnable;
}

- (void)didChangeSelectIndex:(NSUInteger)selectedIndex animated:(BOOL)animated {
    if (animated) {
        self.pagesContainer.userInteractionEnabled = NO;
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            self.pagesContainer.userInteractionEnabled = YES;
        });
    }
    [self.pagesContainer.scrollView setContentOffset:CGPointMake(selectedIndex * CGRectGetWidth(self.pagesContainer.scrollView.bounds), 0) animated:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playItem removeObserver:self forKeyPath:@"status"];
    self.player = nil;
    self.playItem = nil;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
