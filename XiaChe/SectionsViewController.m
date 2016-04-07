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
#import "StoryDetailViewController.h"
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
//    CGFloat _startPos;
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
@end

@implementation SectionsViewController

typedef NS_ENUM(NSInteger, isToday){
    kNext = 0,
    kBefore = 1
};

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
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(selectType)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(settingBundle)];
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
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyyMMdd"];
    [self setupFooter];
    
//    UIButton *titleNew = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
//    
//    
//    
//    [titleNew setTitle:@"·" forState:UIControlStateNormal];
//    [titleNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    UILabel *titleNew = [[UILabel alloc] init];
    if ([self.predicateCache isEqualToString:@"瞎扯"]){
        titleNew.text = @"瞎扯吐槽";
    }else if ([self.predicateCache isEqualToString:@"深夜"]){
        titleNew.text = @"深夜惊奇";
    }
    self.navigationItem.titleView = titleNew;
    self.navTitle = titleNew;
    
    
    
    StorageManager *manager = [StorageManager sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    [fetchRequest setFetchBatchSize:20];
    NSPredicate *pre = [NSPredicate predicateWithFormat:@"title BEGINSWITH %@",@"瞎扯"];
    [fetchRequest setPredicate:pre];
    NSArray *thisA = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
    NSLog(@" fetch count = %d,fetchCtrol = %@",thisA.count,self.fetchedResultsController.fetchRequest.predicate);
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setToolbarHidden:YES animated:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
            NSLog(@"不要刷新");
            self.tableView.mj_footer.hidden = NO;
            [self.tableView.mj_header endRefreshing];
        }else{
            NSLog(@"刷新");
            NSDate *newDate = [self.formatter dateFromString:[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]];
            NSDate *today = [self.formatter dateFromString:model.date];
            NSTimeInterval interval = [today timeIntervalSinceDate:newDate];
            NSLog(@" %@ %@ %f",newDate,today,interval);
            
            //从后往前需要加的天数
            NSUInteger days = (interval / 86400) - 1;
            
            NSLog(@"%lu",(unsigned long)days);
            
            if(newDate == NULL){ // 首次刷新，列表为空的情况
                NSLog(@"这是第一次刷新");
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
        NSLog(@"failed! %@",error);
        [self.tableView.mj_header endRefreshing];
    }];
}

- (void)dataDidSave
{
    if ([SearchForNewFun sharedInstance].loopTime == 0) {
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
//        NSString *loadString = [NSString stringWithFormat:@"正在努力加载 %lu / %d",(unsigned long)(EACH_TIME_FETCH_NUM - [SearchForNewFun sharedInstance].loopTime),EACH_TIME_FETCH_NUM];
//        [self.autoFooter setTitle:loadString forState:MJRefreshStateRefreshing];
        
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
    FunStory *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    detail.passFun = object;
    detail.predicateCache = self.predicateCache;
    [self.navigationController pushViewController:detail animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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

#pragma mark - 废弃的方法
//- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
//{
//    _startPos = scrollView.contentOffset.y;
//}
//
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    CGFloat offset = scrollView.contentOffset.y;
//
//    CGFloat dis = _startPos - offset;
//    if (dis > 0){
////        [self.navigationController setToolbarHidden:NO animated:YES];
//    }else{
////        [self.navigationController setToolbarHidden:YES animated:YES];
//    }
//}

//- (void)switchSectionHideWithTag:(UIButton *)btn
//{
//    NSString *tagStr = [NSString stringWithFormat:@"%ld",btn.tag];
//    if ([self.sectionDict[tagStr] integerValue]==0){
//        [self.sectionDict setObject:@1 forKey:tagStr];
//    }else{
//        [self.sectionDict setObject:@0 forKey:tagStr];
//    }
//    NSIndexSet *set = [NSIndexSet indexSetWithIndex:btn.tag];
//    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
//}
//- (void)expandAll
//{
//    if (_expand){
//        for (int i = 0 ; i < [[self.fetchedResultsController sections] count] ; i ++){
//            NSNumber *sections = [NSNumber numberWithInteger:i];
//            NSString *tagStr = [NSString stringWithFormat:@"%@",sections];
//            [self.sectionDict setObject:@1 forKey:tagStr];
//            NSIndexSet *set = [NSIndexSet indexSetWithIndex:i];
//            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//        _expand = NO;
//    }else{
//        for (int i = 0 ; i < [[self.fetchedResultsController sections] count] ; i ++){
//            NSNumber *sections = [NSNumber numberWithInteger:i];
//            NSString *tagStr = [NSString stringWithFormat:@"%@",sections];
//            [self.sectionDict setObject:@0 forKey:tagStr];
//            NSIndexSet *set = [NSIndexSet indexSetWithIndex:i];
//            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
//        }
//        _expand = YES;
//    }
//}
//- (void)showNotification
//{
//    _notification.titleText = @"获取更多信息";
//    _notification.subtitleText = @"您想获取更多之前的「瞎扯」信息吗？";
//    _notification.image = [UIImage imageNamed:@"update"];
//    _notification.topButtonText = @"好的";
//    _notification.bottomButtonText = @"不要";
//    _notification.dismissOnTap = YES;
//    [_notification presentInView:self.view withGravityAnimation:YES];
//
//    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
//
//        switch (event) {
//            case AFDropdownNotificationEventTopButton:
//                // Top button
//                break;
//
//            case AFDropdownNotificationEventBottomButton:
//                // Bottom button
//                break;
//
//            case AFDropdownNotificationEventTap:
//                // Tap
//                break;
//
//            default:
//                break;
//        }
//    }];
//
//    NSLog(@"show notification");
////    [self showDropDownViewFromDirection:LMDropdownViewDirectionTop];
//}

//- (void)dropdownNotificationTopButtonTapped {
//
//    NSLog(@"Top button tapped");
//
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Top button tapped" message:@"Hooray! You tapped the top button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
//
//    [_notification dismissWithGravityAnimation:YES];
//}

//- (void)dropdownNotificationBottomButtonTapped {
//
//    NSLog(@"Bottom button tapped");
//
////    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bottom button tapped" message:@"Hooray! You tapped the bottom button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
////    [alert show];
////    [self downloadAll];
//    [_notification dismissWithGravityAnimation:YES];
//}
//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSArray *sections = [[self fetchedResultsController] sections];
//    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
//    sectionInfo = [sections objectAtIndex:section];
//    return [sectionInfo name];
//}
@end
