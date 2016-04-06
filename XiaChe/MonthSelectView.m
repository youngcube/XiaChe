//
//  MonthSelectView.m
//  XiaChe
//
//  Created by eusoft on 4/5/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "MonthSelectView.h"
#import "UIImage+ImageEffect.h"
#import <Masonry.h>
#import "UIColor+Extension.h"
#import "FunStory.h"
#import "SearchForNewFun.h"

@interface MonthCell : UITableViewCell
@property (nonatomic, copy) NSString *monthTitle;
@property (nonatomic, weak) UILabel *monthLabel;
@end

@implementation MonthCell
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *monthLabel = [[UILabel alloc] init];
        [self.contentView addSubview:monthLabel];
        self.monthLabel = monthLabel;
        [monthLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.contentView);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title
{
    self.monthLabel.text = title;
}

@end

@interface MonthSelectView()<UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate>
{
    CGFloat _thisOffset;
    NSInteger _thisIndex;
}
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *header;
@property (nonatomic, strong) MASConstraint *topConstraint;

@end

static CGFloat kTableViewWidth = 240.0;
static CGFloat kHeaderHeight = 46.0;
static CGFloat kRowHeight = 60.0;
static CGFloat kSectionHeader = 10.0;
@implementation MonthSelectView

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
//        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        [_tableView registerClass:[ExamTypeCell class] forCellReuseIdentifier:NSStringFromClass([ExamTypeCell class])];
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
        label.text = NSLocalizedString(@"月份跳转", nil);
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_header);
        }];
        
        [_containerView addSubview:_header];
        [_header mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.width.equalTo(_containerView);
            make.height.mas_equalTo(kHeaderHeight);
        }];
//        _examType = [TikuManager sharedInstance].currentType;
    }
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    _thisOffset = scrollView.contentOffset.y;
}

- (void)show{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
//    [window addObserver:self forKeyPath:@"examType" options:NSKeyValueObservingOptionInitial context:nil];
    
    
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
    
    
    [window addSubview:self];
    
    CGPoint lastPoint = CGPointMake(0, _selectOffset);
    [self.tableView setContentOffset:lastPoint animated:NO];
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

#pragma mark - TableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.monthArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *selectCell = @"selectCell";
    MonthCell *cell = [tableView dequeueReusableCellWithIdentifier:selectCell];
    if (!cell){
        cell = [[MonthCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:selectCell];
    }
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [self.monthArray objectAtIndex:indexPath.row];
    [cell setTitle:[sectionInfo name]];
    
    if ([SearchForNewFun sharedInstance].loopTime == 0){
        NSIndexPath *index = [NSIndexPath indexPathForRow:self.selectIndex inSection:0];
        [tableView selectRowAtIndexPath:index animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
    
    return cell;
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
    
    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
    sectionInfo = [self.monthArray objectAtIndex:indexPath.row];
    [self.delegate monthSelectAtIndex:indexPath.row offset:_thisOffset];
    [self dismissAnimation];
    
}



@end
