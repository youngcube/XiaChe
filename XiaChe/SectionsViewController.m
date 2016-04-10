//
//  SectionsViewController.m
//  XiaChe
//
//  Created by cube on 3/15/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SectionsViewController.h"
#import "SectionModel.h"
#import "Consts.h"
#import <AFNetworking/AFNetworking.h>
#import <MJRefresh/MJRefresh.h>
#import "FunStory.h"
#import "SearchForNewFun.h"
#import "UIColor+Extension.h"
#import "SectionCell.h"
#import "AFDropdownNotification.h"
#import "MonthSelectView.h"
#import "SettingView.h"
#import <Masonry.h>

#define HEIGHT_OF_SECTION_HEADER 50.5f

@interface SectionsViewController ()<MonthSelectDelegate>
{
    NSUInteger _currentSection;

    CGFloat _selectOffset;
    NSUInteger _selectIndex;
}
@property (nonatomic, strong) SectionModel *model;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) BOOL ifIsLoopNewData; // 86400是否要* -1
@property (nonatomic, strong) MJRefreshNormalHeader *autoHeader;
@property (nonatomic, strong) MJRefreshAutoNormalFooter *autoFooter;
@property (nonatomic, strong) UILabel *navTitle;
@property (nonatomic, strong) AFDropdownNotification *notification;
@property (nonatomic, strong) NSPredicate *predicate;
@property (nonatomic, copy) NSString *predicateCache;
@property (nonatomic, strong) FunStory *getFun;
@end

@implementation SectionsViewController

- (instancetype)initWithPredicate:(NSString *)predicate
{
    self = [self initWithStyle:UITableViewStylePlain];
    self.predicate = [NSPredicate predicateWithFormat:@"title BEGINSWITH %@",predicate];
    self.predicateCache = predicate;
    return self;
}

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"datePick"] style:UIBarButtonItemStylePlain target:self action:@selector(selectType)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"settings"] style:UIBarButtonItemStylePlain target:self action:@selector(settingBundle)];
    }
    return self;
}

- (void)settingBundle
{
    SettingView *set = [[SettingView alloc] initWithFrame:self.view.frame];
    [set show];
}

- (void)selectType
{
    MonthSelectView *mouth = [[MonthSelectView alloc] initWithFrame:self.view.frame];
    mouth.monthArray = [[self fetchedResultsController] sections];
    mouth.delegate = self;
    mouth.selectOffset = _selectOffset;
    mouth.selectIndex = _selectIndex;
    [mouth show];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidSave) name:NSManagedObjectContextDidSaveNotification object:nil];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyyMMdd"];
    [self setupFooter];
    
    UILabel *titleNew = [[UILabel alloc] init];
    titleNew.frame = CGRectMake(0, 0, 100, 150);
    titleNew.textAlignment = NSTextAlignmentCenter;
    [titleNew setFont:[UIFont boldSystemFontOfSize:16]];
    if ([self.predicateCache isEqualToString:@"瞎扯"]){
        titleNew.text = @"瞎扯吐槽";
    }else if ([self.predicateCache isEqualToString:@"深夜"]){
        titleNew.text = @"深夜惊奇";
    }
    self.navigationItem.titleView = titleNew;
    
    self.navTitle = titleNew;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - 月份选择delegate
- (void)monthSelectAtIndex:(NSUInteger)index offset:(CGFloat)offset
{
    NSIndexPath *newIndex = [NSIndexPath indexPathForRow:NSNotFound inSection:index];
    _selectOffset = offset;
    _selectIndex = index;
    [self.tableView scrollToRowAtIndexPath:newIndex atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

#pragma mark - tableview delegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, HEIGHT_OF_SECTION_HEADER);
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    sectionHeaderView.backgroundColor = [UIColor cellHeaderColor];
    NSString *headerString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    UILabel *headerBtn = [[UILabel alloc] initWithFrame:headerFrame];
    headerBtn.text = headerString;
    headerBtn.textColor = [UIColor cellHeaderTextColor];
    headerBtn.font = [UIFont systemFontOfSize:14];
    [sectionHeaderView addSubview:headerBtn];
    headerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [headerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(sectionHeaderView);
        make.left.equalTo(sectionHeaderView.mas_left).offset(20);
    }];
    return sectionHeaderView;
}

#pragma mark - UI
- (void)setupFooter
{
    self.autoHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        [self decideIfShouldGetNewJson];
    }];
    self.autoHeader.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.mj_header = self.autoHeader;
    [self.tableView.mj_header beginRefreshing];
    
    self.autoFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        if ([[SearchForNewFun sharedInstance] calculateStartTimeToOldTime] == 0){
            [self.autoFooter endRefreshingWithNoMoreData];
        }else{
            [SearchForNewFun sharedInstance].loopTime = EACH_TIME_FETCH_NUM;
            self.ifIsLoopNewData = NO;
            [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
        }
    }];
    
    self.tableView.mj_footer = self.autoFooter;
    if ([[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:YES] isEqualToString:FirstDayString]){
        self.tableView.mj_footer.hidden = YES;
        self.autoFooter.hidden = YES;
    }else{
        self.tableView.mj_footer.hidden = NO;
        self.autoFooter.hidden = NO;
    }
}

#pragma mark - Logic to Fetch Data
- (void)decideIfShouldGetNewJson
{
    self.tableView.mj_footer.hidden = YES;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SectionModel *model = [SectionModel yy_modelWithJSON:responseObject];
        
        if ([model.date isEqualToString:[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]]){
            FUNLog(@"不要刷新");
            self.tableView.mj_footer.hidden = NO;
            [self.tableView.mj_header endRefreshing];
        }else{
            FUNLog(@"刷新");
            NSDate *newDate = [self.formatter dateFromString:[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]];
            NSDate *today = [self.formatter dateFromString:model.date];
            NSTimeInterval interval = [today timeIntervalSinceDate:newDate];
            FUNLog(@" %@ %@ %f",newDate,today,interval);
            
            //从后往前需要加的天数
            NSUInteger days = (interval / 86400) - 1;
            
            FUNLog(@"%lu",(unsigned long)days);
            
            if(newDate == NULL){ // 首次刷新，列表为空的情况
                FUNLog(@"这是第一次刷新");
                [[SearchForNewFun sharedInstance] accordingDateToLoopNewDataWithData:NO];
                self.ifIsLoopNewData = NO;
                [SearchForNewFun sharedInstance].loopTime = EACH_TIME_FETCH_NUM;
            }else{
                [[SearchForNewFun sharedInstance] accordingDateToLoopNewDataWithData:YES];
                self.ifIsLoopNewData = YES;
                [SearchForNewFun sharedInstance].loopTime = days;
            }
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        FUNLog(@"failed! %@",error);
        [self.tableView.mj_header endRefreshing];
    }];
}
// 数据保存了
- (void)dataDidSave
{
    FUNLog(@"loop time = %lu,",(unsigned long)[SearchForNewFun sharedInstance].loopTime);
    if ([SearchForNewFun sharedInstance].loopTime == 0) { //最后一次保存
        if (self.getFun){ //如果getfun存在，说明需要loadwebview
            if (![SearchForNewFun sharedInstance].isLoopDetail){
                NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:self.getFun];
                NSUInteger thisRow = indexPath.row;
                NSUInteger thisSection = indexPath.section;
                NSIndexPath *beforeIndex = [NSIndexPath indexPathForRow:thisRow + 1 inSection:thisSection];
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:beforeIndex]];
            }
            
        }
        self.tableView.mj_footer.hidden = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        return;
    }else{
        NSString *oldString;
        self.tableView.mj_footer.hidden = YES;
        if (self.ifIsLoopNewData == YES){
            oldString = [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO];
            NSDate *newDate = [self.formatter dateFromString:oldString];
            NSDate *oldDateRange = [NSDate dateWithTimeInterval:+86400*2 sinceDate:newDate];
            oldString = [self.formatter stringFromDate:oldDateRange];
        }else{
            oldString = [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:YES];
        }
        NSDate *oldDate = [self.formatter dateFromString:oldString];
        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDate];
        [[SearchForNewFun sharedInstance] getJsonWithString:oldDateRangeString];
        if (![SearchForNewFun sharedInstance].isLoopDetail){
            [SearchForNewFun sharedInstance].loopTime--;
        }
    }
}

#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionCell *cell = [SectionCell createCellAtTableView:tableView];
    [self configureCell:cell atIndexPath:indexPath];
    _currentSection = indexPath.section;
    return cell;
}

- (void)configureCell:(SectionCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FunStory *fun = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.title = fun.title;
    cell.date = fun.storyDate;
    cell.imageURL = fun.image;
    cell.unread = fun.unread;
}

#pragma mark - TableView Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoryDetailViewController *detail = [[StoryDetailViewController alloc] init];
    detail.delegate = self;
    FunStory *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self.fetchedResultsController sections];
    detail.passFun = object;
    detail.predicateCache = self.predicateCache;
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)nextStoryDetailFetchWithPassFun:(FunStory *)passFun
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:passFun];
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    NSUInteger totalRow = [sectionInfo numberOfObjects];
    NSUInteger thisRow = indexPath.row;
    NSUInteger thisSection = indexPath.section;
    if (thisRow == 0){ // 本月最后一天
        if (thisSection == 0){ //最新的月份的最后一天（最新一天）
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_NO_MORE_NEW object:nil];
            NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:0 inSection:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:nextIndex]];
        }else{ //其他下个月跳转
            thisSection = thisSection - 1;
            id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][thisSection];
            totalRow = [sectionInfo numberOfObjects];
            thisRow = totalRow - 1;
            NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:thisRow inSection:thisSection];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:nextIndex]];
        }
    }else{ //正常下一天跳转
        NSIndexPath *nextIndex = [NSIndexPath indexPathForRow:thisRow - 1 inSection:thisSection];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:nextIndex]];
    }
}

- (void)beforeStoryDetailFetchWithPassFun:(FunStory *)passFun
{
    NSIndexPath *indexPath = [self.fetchedResultsController indexPathForObject:passFun];
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][indexPath.section];
    NSUInteger totalSection = [self.fetchedResultsController sections].count;
    NSUInteger totalRow = [sectionInfo numberOfObjects];
    NSUInteger thisRow = indexPath.row;
    NSUInteger thisSection = indexPath.section;
    
    if (thisRow == totalRow - 1){ // 本月1号，需要后退到上个月31号
        
        if (thisSection == totalSection - 1){ //到底了，需要加载新数据或者直接到底5.23
            // new data
            // fetch 3天 防止有没有的情况出现
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_MORE object:nil];
            [SearchForNewFun sharedInstance].loopTime = 3; //抓之后3天的避免没有瞎扯
            self.ifIsLoopNewData = NO;
            [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
            self.getFun = passFun; //传递passfun，通知fetch并loadweb
        }else{ //本月1号，需要后退到上个月31号
            thisSection++;
            thisRow = 0;
            NSIndexPath *beforeIndex = [NSIndexPath indexPathForRow:thisRow inSection:thisSection];
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:beforeIndex]];
        }
    }else{ // 正常情况
        NSIndexPath *beforeIndex = [NSIndexPath indexPathForRow:thisRow + 1 inSection:thisSection];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_LOAD_WEBVIEW object:[self.fetchedResultsController objectAtIndexPath:beforeIndex]];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

#pragma mark - NSFetchedResultsController Delegate
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(nonnull id)anObject atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    switch (type) {
            case NSFetchedResultsChangeInsert:
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            case NSFetchedResultsChangeDelete:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            case NSFetchedResultsChangeMove:
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
                [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            case NSFetchedResultsChangeUpdate:
                [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
            break;
    }
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

#pragma mark - lazy NSFetchedResultsController
- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController){
        StorageManager *manager = [StorageManager sharedInstance];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        [fetchRequest setFetchBatchSize:20];
        [fetchRequest setPredicate:self.predicate];
        NSFetchedResultsController *fetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                    managedObjectContext:manager.managedObjectContext
                                                                                      sectionNameKeyPath:@"simpleMonth" cacheName:[NSString stringWithFormat:@"%@",self.predicateCache]];
        fetchCtrl.delegate = self;
        self.fetchedResultsController = fetchCtrl;
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error]){
            abort();
        }
    }
    return _fetchedResultsController;
}
@end
