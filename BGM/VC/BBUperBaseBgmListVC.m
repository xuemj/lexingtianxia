//
//  BBUperBaseBgmListVC.m
//  BBUper
//
//  Created by xmj on 2018/4/17.
//  Copyright © 2018年 bilibili. All rights reserved.
//

#import "BBUperBaseBgmListVC.h"
#import "BBUperBgmListCell.h"
#import "BBUperBgmManager.h"
#import "BBUperBgmListModel.h"
#import "BBUperBgmListVM.h"
#define BBUperBgmListCellID @"BBUperBgmListCell"

@interface BBUperBaseBgmListVC ()

@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic) NSInteger page;
@property (nonatomic) BOOL isChangeBgm;
@end

@implementation BBUperBaseBgmListVC

- (instancetype)initWithMediaList:(NSArray*)medialist page:(NSInteger)page {
    self = [super init];
    if (self) {
        self.viewModel = [BBUperBgmListVM new]; //仅用来防止断言
        self.dataArr = medialist;
        self.page = page;
        self.command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
                [subscriber sendNext:input];
                [subscriber sendCompleted];
                return nil;
            }];
        }];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _initUI];
    [self _installLayout];
    [self _initData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isPageSelected) {
        int i = 0;
        for (BBUperBgmMediaModel *model in self.dataArr) {
            if (model.bgmId == [[BBUperBgmManager shareInstance] currentIndex]) {
                NSIndexPath *scrollIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [self.tableView scrollToRowAtIndexPath:scrollIndexPath
                                      atScrollPosition:UITableViewScrollPositionTop animated:YES];
                return;
            }
            i++;
        }
    }
}

- (void)_initUI {
    [self.tableView registerClass:[BBUperBgmListCell class] forCellReuseIdentifier:BBUperBgmListCellID];
    self.tableView.backgroundColor = HEXCOLOR(0x1B1B1B);
    
}

- (void)_installLayout {
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)_initData {
    [self.tableView reloadData];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBUperBgmMediaModel *model = self.dataArr[indexPath.row];
    if (model.bgmId == [[BBUperBgmManager shareInstance] currentIndex] && self.isPageSelected) {
        return 148;
    }
    return 88;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BBUperBgmListCell *cell = [tableView dequeueReusableCellWithIdentifier:BBUperBgmListCellID];
    BBUperBgmMediaModel *model = self.dataArr[indexPath.row];
    BOOL current = (model.bgmId == [[BBUperBgmManager shareInstance] currentIndex] && self.isPageSelected);
   
    [cell insTallWithMediaInfo:model isCurrentMedia:current];
    @weakify(self);
    cell.clickBlock = ^{
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(bbuperBgmDownload:)]) {
            [self.delegate bbuperBgmDownload:model];
        }
    };
    cell.seekTimeBlock = ^(double time) {
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(bbuperBgmSeekTimePlay:)]) {
            [self.delegate bbuperBgmSeekTimePlay:time];
        }
    };
    cell.openBlock = ^(BOOL isOpen) {
        @strongify(self);
        if (self.delegate && [self.delegate respondsToSelector:@selector(bbuperScrollEnable:)]) {
            [self.delegate bbuperScrollEnable:isOpen];
        }
    };
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    BBUperBgmMediaModel *model = self.dataArr[indexPath.row];
    if (self.page == [[BBUperBgmManager shareInstance] currentPage] && model.bgmId == [[BBUperBgmManager shareInstance] currentIndex]) {
        self.isChangeBgm = NO;
    } else {
        self.isChangeBgm = YES;
        [BBUperBgmManager shareInstance].playSeekTime = 0;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(bbuperBgmPlay:isChangeBgm:)]) {
        [self.delegate bbuperBgmPlay:model isChangeBgm:self.isChangeBgm];
    }
    [self.command execute:RACTuplePack(@(self.page), @(model.bgmId))];
}

- (void)resetListState:(BOOL)isSelected {
    self.isPageSelected = isSelected;
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
