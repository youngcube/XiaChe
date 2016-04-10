//
//  SettingView.m
//  XiaChe
//
//  Created by eusoft on 4/5/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SettingView.h"
#import "UIImage+ImageEffect.h"
#import <Masonry.h>
#import "UIColor+Extension.h"
#import "FunStory.h"
#import "ASProgressPopUpView.h"
#import "SearchForNewFun.h"
#import "StorageManager.h"

@interface SettingViewCell : UITableViewCell<ASProgressPopUpViewDelegate>
@property (nonatomic, weak) ASProgressPopUpView *progressView;
@property (nonatomic, weak) UILabel *settingLabel;
@property (nonatomic, weak) UIImageView *contentImage;
@end

@implementation SettingViewCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *settingLabel = [[UILabel alloc] init];
        [self.contentView addSubview:settingLabel];
        self.settingLabel = settingLabel;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:imageView];
        self.contentImage = imageView;
        
        ASProgressPopUpView *progressView = [[ASProgressPopUpView alloc] init];
        progressView.delegate = self;
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
        self.progressView.font = [UIFont systemFontOfSize:14];
        self.progressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
        self.progressView.popUpViewCornerRadius = 14.0;
        
        [self.contentImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(25);
            make.centerY.equalTo(self);
            make.width.height.equalTo(@30);
        }];
        
        [self.settingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentImage.mas_right).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.height.equalTo(@5);
            make.centerY.equalTo(self).offset(13);
        }];
        
        
        
    }
    return self;
}

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

@end

@interface SettingView()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) MASConstraint *topConstraint;
@property (nonatomic, weak) ASProgressPopUpView *listProgress;
@property (nonatomic) BOOL ifIsLoopNewData;
@property (nonatomic) NSUInteger fetchCount;
@end

static CGFloat kTableViewWidth = 240.0;
static CGFloat kHeaderHeight = 46.0;
static CGFloat kRowHeight = 60.0;
static CGFloat kSectionHeader = 10.0;
@implementation SettingView

- (instancetype)initWithFrame:(CGRect)frame{
    if ((self = [super initWithFrame:frame])) {
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
        
        NSUInteger rowCount;
        if ([[SearchForNewFun sharedInstance] calculateStartTimeToOldTime] == 0){
            rowCount = 1;
        }else{
            rowCount = 2;
        }
        
        _containerView = [[UIView alloc] init];
        _containerView.layer.cornerRadius = 4;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.topConstraint = make.top.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kTableViewWidth);
            make.height.mas_equalTo(kHeaderHeight + kSectionHeader  * 2 + kRowHeight * rowCount);
        }];
        
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        _tableView.rowHeight = kRowHeight;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.contentInset = UIEdgeInsetsMake(kSectionHeader, 0, kSectionHeader, 0);
        
        [_containerView addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.centerX.width.equalTo(_containerView);
            make.height.mas_equalTo(kSectionHeader * 2 + kRowHeight * rowCount);
        }];
        
        _header = [[UIView alloc] init];
        _header.backgroundColor = [UIColor customNavColor];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        [_header addSubview:label];
        label.text = NSLocalizedString(@"缓冲", nil);
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_header);
        }];
        
        [_containerView addSubview:_header];
        [_header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.equalTo(_containerView);
            make.height.mas_equalTo(kHeaderHeight);
        }];
    }
    return self;
}

- (void)show
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    self.frame = [self bounds];
    self.containerView.alpha = 0;
    [UIView animateWithDuration:0.01 animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.containerView.alpha = 1;
        [self.topConstraint uninstall];
        [_containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            self.topConstraint = make.centerY.equalTo(self);
        }];
        
        [UIView animateWithDuration:0.4 animations:^{
            [self layoutIfNeeded];
        } completion:nil];
    }];
    
    [[SearchForNewFun sharedInstance] addObserver:self forKeyPath:@"loopTime" options:NSKeyValueObservingOptionNew context:NULL];
    
    [window addSubview:self];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    if (![touch.view isEqual:self.containerView]) {
        [self dismissAnimation];
    }
}

- (void)dismissAnimation{
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        self.alpha = 1.0;
    }];
}

typedef NS_ENUM(NSInteger, Sections){
    kSectionOne = 0,
    NUM_SECTIONS
};

typedef NS_ENUM(NSInteger, SectionOne){
    kDownList = 0,
    kProgressList,
    NUM_SectionOne_ROWS
};

#pragma mark - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([SearchForNewFun sharedInstance].loopTime == 0){
        return NUM_SectionOne_ROWS - 1;
    }else{
        return NUM_SectionOne_ROWS;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingViewCell *cell = [[SettingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    [self configureCell:cell atIndexPath:indexPath];
    tableView.scrollEnabled = NO;
    return cell;
}

- (void)configureCell:(SettingViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger listP = [[SearchForNewFun sharedInstance] calculateStartTimeToOldTime];
    NSUInteger all = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    double pro = (double)listP/all;
    if (indexPath.section == kSectionOne){
        switch (indexPath.row) { // 下载列表
            case kDownList:
                cell.settingLabel.hidden = NO;
                cell.contentImage.hidden = NO;
                cell.progressView.hidden = YES;
                
                if ([SearchForNewFun sharedInstance].loopTime == 0){
                    
                    if ([[SearchForNewFun sharedInstance] calculateStartTimeToOldTime] == 0){
                        cell.contentImage.image = [UIImage imageNamed:@"finish"];
                        cell.settingLabel.text = @"已缓冲全部列表";
                        cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    }else{
                        cell.contentImage.image = [UIImage imageNamed:@"download"];
                        cell.settingLabel.text = @"缓存之前的列表";
                    }
                }else{
                    cell.contentImage.image = [UIImage imageNamed:@"download"];
                    cell.settingLabel.text = @"暂停";
                }
                break;
            case kProgressList:
                cell.settingLabel.hidden = YES;
                cell.contentImage.hidden = YES;
                cell.progressView.hidden = NO;
                if ([SearchForNewFun sharedInstance].loopTime > 0){
                    [cell.progressView setProgress:(1 - pro) animated:YES];
                    self.listProgress = cell.progressView;
                }
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                break;
            default:
                break;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionOne){
        NSIndexPath *downIndex = [NSIndexPath indexPathForRow:kProgressList inSection:kSectionOne];
        switch (indexPath.row) { // 下载列表
            case kDownList:
                if ([SearchForNewFun sharedInstance].loopTime > 0){
                    [self stopDownload];
                    [self.tableView reloadData];
                }else{
                    [self download];
                    if (self.fetchCount != 0){
                        [self.tableView reloadData];
                    }
                }
                [self.tableView deselectRowAtIndexPath:downIndex animated:YES];
                [self.tableView reloadData];
                break;
            case kProgressList:
                break;
            default:
                break;
        }
    }
}

- (void)dealloc
{
    @try {
        [[SearchForNewFun sharedInstance] removeObserver:self forKeyPath:@"loopTime" context:NULL];
    } @catch (NSException *exception) {
        
    }
}

- (void)stopDownload
{
    [SearchForNewFun sharedInstance].loopTime = 0;
    // 正在下载老数据，防止上下篇切换失效
    [SearchForNewFun sharedInstance].isDownloadOld = NO;
    self.listProgress.hidden = YES;
}

- (void)download
{
    self.listProgress.hidden = NO;
    self.fetchCount = [[SearchForNewFun sharedInstance] calculateStartTimeToOldTime];
    [SearchForNewFun sharedInstance].loopTime = self.fetchCount;
    // 正在下载老数据，防止上下篇切换失效
    [SearchForNewFun sharedInstance].isDownloadOld = YES;
    self.ifIsLoopNewData = NO;
    [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSNumber *listP = (NSNumber *)[change objectForKey:NSKeyValueChangeNewKey];
    double this = [listP doubleValue];
    NSUInteger all = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    double pro = this/all;
    self.listProgress.progress = 1 - pro;
    [self.listProgress showPopUpViewAnimated:YES];
    
    if ([[SearchForNewFun sharedInstance] calculateStartTimeToOldTime] == 0 || [SearchForNewFun sharedInstance].loopTime == 0){
        [self.tableView reloadData];
    }
}

@end
