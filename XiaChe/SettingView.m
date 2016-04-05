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

@interface SettingViewCell : UITableViewCell<ASProgressPopUpViewDelegate>
//@property (nonatomic, copy) NSString *settingTitle;
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

//- (void)setTitle:(NSString *)title
//{
//    self.settingLabel.text = title;
//}

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

@end

@interface SettingView()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    BOOL _ifClickDownloadBtn; //避免二次remove KVO
}
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
        
        _containerView = [[UIView alloc] init];
        _containerView.layer.cornerRadius = 4;
        _containerView.clipsToBounds = YES;
        [self addSubview:_containerView];
        [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            self.topConstraint = make.top.equalTo(self.mas_bottom);
            make.centerX.equalTo(self);
            make.width.mas_equalTo(kTableViewWidth);
            make.height.mas_equalTo(kHeaderHeight + kSectionHeader  * 2 + kRowHeight * 5);
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
            make.height.mas_equalTo(kSectionHeader * 2 + kRowHeight * 5);
        }];
        
        _header = [[UIView alloc] init];
        _header.backgroundColor = [UIColor customNavColor];
        UILabel *label = [UILabel new];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize:14];
        [_header addSubview:label];
        label.text = NSLocalizedString(@"偏好", nil);
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
    _ifClickDownloadBtn = NO;
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
    kSectionTwo,
    NUM_SECTIONS
};

typedef NS_ENUM(NSInteger, SectionOne){
    kDownList = 0,
    kProgressList,
    NUM_SectionOne_ROWS
};

typedef NS_ENUM(NSInteger, SectionTwo){
    kDownDetail = 0,
    kProgressDetail,
    NUM_SectionTwo_ROWS
};

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return NUM_SECTIONS+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *selectCell = @"selectCell";
    SettingViewCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCell];
    if (!cell){
        cell = [[SettingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectCell];
    }
    [self configureCell:cell atIndexPath:indexPath];
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
                cell.contentImage.image = [UIImage imageNamed:@"update"];
                cell.settingLabel.text = @"缓存瞎扯列表";
                
                cell.progressView.hidden = YES;
                break;
            case kProgressList:
                [cell.progressView setProgress:(1 - pro) animated:YES];
                self.listProgress = cell.progressView;
                break;
            case kProgressList + 1:
                cell.settingLabel.text = @"停止";
                break;
            default:
                break;
        }
    }else if (indexPath.section == kSectionTwo){
        switch (indexPath.row) { // 下载详情
            case kDownDetail:
                cell.contentImage.image = [UIImage imageNamed:@"download"];
                //                [cell.titleButton setTitle:@"缓存瞎扯页面" forState:UIControlStateNormal];
                //                self.downloadButton = cell.titleButton;
                cell.progressView.hidden = YES;
                break;
            case kProgressDetail:
                break;
            default:
                break;
        }
    }
}

- (void)dealloc
{
    if (_ifClickDownloadBtn){
        @try {
            [[SearchForNewFun sharedInstance] removeObserver:self forKeyPath:@"loopTime" context:NULL];
        } @catch (NSException *exception) {
            
        }
    }
}

- (void)stopDownload
{
    _ifClickDownloadBtn = NO;
    [[SearchForNewFun sharedInstance] removeObserver:self forKeyPath:@"loopTime"];
    
    [SearchForNewFun sharedInstance].loopTime = 0;
}

- (void)download
{
    [[SearchForNewFun sharedInstance] addObserver:self forKeyPath:@"loopTime" options:NSKeyValueObservingOptionNew context:NULL];
    _ifClickDownloadBtn = YES;
    self.fetchCount = [[SearchForNewFun sharedInstance] calculateStartTimeToOldTime];
    [SearchForNewFun sharedInstance].loopTime = self.fetchCount;
    self.ifIsLoopNewData = NO;
    [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSString *typeId = @"good";
//    if ([typeId isEqualToString:_examType]) {
//        [cell setSelected:YES animated:NO];
//    }else{
//        [cell setSelected:NO animated:NO];
//    }
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionOne){
        switch (indexPath.row) { // 下载列表
            case kDownList:
                [self download];
                break;
            case kProgressList:
                
                break;
            case kProgressList + 1:
                [self stopDownload];
                break;
            default:
                break;
        }
    }
//    [self dismissAnimation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    NSNumber *listP = (NSNumber *)[change objectForKey:NSKeyValueChangeNewKey];
    double this = [listP doubleValue];
    NSUInteger all = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    double pro = this/all;
    self.listProgress.progress = 1 - pro;
    [self.listProgress showPopUpViewAnimated:YES];
    NSLog(@"%@",[NSString stringWithFormat:@"%f%%",1-pro]);
}

@end
