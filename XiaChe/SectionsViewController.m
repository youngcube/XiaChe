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
#import "SectionMenu.h"
#import "AFDropdownNotification.h"
#define HEIGHT_OF_SECTION_HEADER 50.5f

@interface SectionsViewController ()<AFDropdownNotificationDelegate>
{
    CGFloat _startPos;
    NSUInteger _currentSection;
    BOOL _expand;
}
@property (nonatomic, strong) SectionModel *model;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *formatter;
//@property (nonatomic) NSUInteger loopTime;
@property (nonatomic) BOOL ifIsLoopNewData; // 86400是否要* -1
@property (nonatomic, strong) MJRefreshNormalHeader *autoHeader;
@property (nonatomic, strong) MJRefreshAutoNormalFooter *autoFooter;

//@property (nonatomic, strong) UIView *alphaView;
//@property (nonatomic, strong) UIButton *naviHeaderView;
//@property (nonatomic, strong) UIView *sectionHeaderView;
//@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *navTitle;
@property (nonatomic, strong) NSMutableDictionary *sectionDict;
@property (nonatomic, strong) AFDropdownNotification *notification;


@end

@implementation SectionsViewController

typedef NS_ENUM(NSInteger, isToday){
    kNext = 0,
    kBefore = 1
};

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showNotification)];
        
        
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:[StorageManager sharedInstance] action:@selector(removeAllData)];
    }
    return self;
}






- (void)downloadAll
{
    [SearchForNewFun sharedInstance].loopTime = [[SearchForNewFun sharedInstance] calculateStartTimeToNow];
    self.ifIsLoopNewData = NO;
    _expand = NO;
    [self expandAll];
    [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
}

- (void)nextSection
{
    NSLog(@"number of section = " );
    _currentSection++;
    
    for (int i = 0 ; i < self.tableView.numberOfSections; i ++){
        NSLog(@"%@",[[[self.fetchedResultsController sections] objectAtIndex:i] name]);
    }
    NSIndexPath *index = [NSIndexPath indexPathForRow:NSNotFound inSection:_currentSection];
    [self.tableView scrollToRowAtIndexPath:index atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidSave) name:NSManagedObjectContextDidSaveNotification object:nil];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyyMMdd"];
    [self setupFooter];
    
    UIButton *titleNew = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [titleNew setTitle:@"·" forState:UIControlStateNormal];
    [titleNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleNew;
    self.navTitle = titleNew;
    
    
    self.sectionDict = [NSMutableDictionary dictionary];
    _expand = YES;
    
    _notification = [[AFDropdownNotification alloc] init];
    _notification.notificationDelegate = self;

}



- (void)showNotification
{
    
    _notification.titleText = @"获取更多信息";
    _notification.subtitleText = @"您想获取更多之前的「瞎扯」信息吗？";
    _notification.image = [UIImage imageNamed:@"update"];
    _notification.topButtonText = @"好的";
    _notification.bottomButtonText = @"不要";
    _notification.dismissOnTap = YES;
    [_notification presentInView:self.view withGravityAnimation:YES];
    
    [_notification listenEventsWithBlock:^(AFDropdownNotificationEvent event) {
        
        switch (event) {
            case AFDropdownNotificationEventTopButton:
                // Top button
                break;
                
            case AFDropdownNotificationEventBottomButton:
                // Bottom button
                break;
                
            case AFDropdownNotificationEventTap:
                // Tap
                break;
                
            default:
                break;
        }
    }];
    
    NSLog(@"show notification");
//    [self showDropDownViewFromDirection:LMDropdownViewDirectionTop];
}

-(void)dropdownNotificationTopButtonTapped {
    
    NSLog(@"Top button tapped");
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Top button tapped" message:@"Hooray! You tapped the top button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [_notification dismissWithGravityAnimation:YES];
}

-(void)dropdownNotificationBottomButtonTapped {
    
    NSLog(@"Bottom button tapped");
    
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bottom button tapped" message:@"Hooray! You tapped the bottom button" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [alert show];
    [self downloadAll];
    [_notification dismissWithGravityAnimation:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startPos = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    CGFloat dis = _startPos - offset;
    if (dis > 0){
//        [self.navigationController setToolbarHidden:NO animated:YES];
    }else{
//        [self.navigationController setToolbarHidden:YES animated:YES];
    }
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, HEIGHT_OF_SECTION_HEADER);
    UIView *sectionHeaderView = [[UIView alloc] initWithFrame:headerFrame];
    sectionHeaderView.backgroundColor = [UIColor grayColor];
    
    NSString *headerString = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
//    UILabel *headerLabel = [[UILabel alloc] init];
    UIButton *headerBtn = [[UIButton alloc] initWithFrame:headerFrame];
    [headerBtn setTitle:headerString forState:UIControlStateNormal];
    headerBtn.tag = section;
    [headerBtn addTarget:self action:@selector(switchSectionHideWithTag:) forControlEvents:UIControlEventTouchUpInside];
//    headerLabel.text = headerString;
//    [headerLabel sizeToFit];
    [sectionHeaderView addSubview:headerBtn];
    
    headerBtn.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:headerBtn attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerX];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:headerBtn attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerY];
    return sectionHeaderView;
}

- (void)switchSectionHideWithTag:(UIButton *)btn
{
    NSString *tagStr = [NSString stringWithFormat:@"%ld",btn.tag];
    if ([self.sectionDict[tagStr] integerValue]==0){
        [self.sectionDict setObject:@1 forKey:tagStr];
    }else{
        [self.sectionDict setObject:@0 forKey:tagStr];
    }
    NSIndexSet *set = [NSIndexSet indexSetWithIndex:btn.tag];
    [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark - UI
- (void)setupFooter
{
    self.autoHeader = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        _expand = NO;
        [self expandAll];
        [self decideIfShouldGetNewJson];
    }];
    self.autoHeader.lastUpdatedTimeLabel.hidden = YES;
    
    self.tableView.mj_header = self.autoHeader;
    [self.tableView.mj_header beginRefreshing];
    
    self.autoFooter = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        [SearchForNewFun sharedInstance].loopTime = EACH_TIME_FETCH_NUM;
        self.ifIsLoopNewData = NO;
        _expand = NO;
        [self expandAll];
        [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
    }];
    
    self.tableView.mj_footer = self.autoFooter;
    if ([[[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:YES] isEqualToString:@"20130523"]){
        self.tableView.mj_footer.hidden = YES;
    }else{
        self.tableView.mj_footer.hidden = NO;
    }
}

- (void)expandAll
{
    if (_expand){
        for (int i = 0 ; i < [[self.fetchedResultsController sections] count] ; i ++){
            NSNumber *sections = [NSNumber numberWithInteger:i];
            NSString *tagStr = [NSString stringWithFormat:@"%@",sections];
            [self.sectionDict setObject:@1 forKey:tagStr];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:i];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        _expand = NO;
    }else{
        for (int i = 0 ; i < [[self.fetchedResultsController sections] count] ; i ++){
            NSNumber *sections = [NSNumber numberWithInteger:i];
            NSString *tagStr = [NSString stringWithFormat:@"%@",sections];
            [self.sectionDict setObject:@0 forKey:tagStr];
            NSIndexSet *set = [NSIndexSet indexSetWithIndex:i];
            [self.tableView reloadSections:set withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        _expand = YES;
    }
}

#pragma mark - Logic to Fetch Data
- (void)decideIfShouldGetNewJson
{
//    [self.tableView.mj_header beginRefreshing];
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
        NSString *loadString = [NSString stringWithFormat:@"正在努力加载 %lu / %d",(unsigned long)(EACH_TIME_FETCH_NUM - [SearchForNewFun sharedInstance].loopTime),EACH_TIME_FETCH_NUM];
        [self.autoFooter setTitle:loadString forState:MJRefreshStateRefreshing];
        [SearchForNewFun sharedInstance].loopTime--;
    }
}

//- (void)pushToLastestStory
//{
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:LatestNewsString] options:NSDataReadingUncached error:nil];
//    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
//    self.model = [SectionModel yy_modelWithDictionary:dict];
//    for (Story *story in self.model.stories){
//        if ([story.title hasPrefix:@"瞎扯"]) {
//            StoryDetailViewController *detail = [[StoryDetailViewController alloc] init];
//            NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,story.storyId];
//            detail.url = url;
//            [self.navigationController pushViewController:detail animated:NO];
//        }
//    }
//}



#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSString *tagStr = [NSString stringWithFormat:@"%ld",section];
    if ([self.sectionDict[tagStr] integerValue] == 0){
        return [sectionInfo numberOfObjects];
    }else{
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SectionCell *cell = [SectionCell createCellAtTableView:tableView];
    [self configureCell:cell atIndexPath:indexPath];
    _currentSection = indexPath.section;
    return cell;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSArray *sections = [[self fetchedResultsController] sections];
//    id <NSFetchedResultsSectionInfo> sectionInfo = nil;
//    sectionInfo = [sections objectAtIndex:section];
//    return [sectionInfo name];
//}

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
    [self.navigationController pushViewController:detail animated:YES];
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
        
        NSFetchedResultsController *fetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                    managedObjectContext:manager.managedObjectContext
                                                                                      sectionNameKeyPath:@"simpleMonth" cacheName:@"cellId"];
        fetchCtrl.delegate = self;
        self.fetchedResultsController = fetchCtrl;
        NSError *error;
        if (![self.fetchedResultsController performFetch:&error]){
            NSLog(@"%@",error);
            abort();
        }
    }
    return _fetchedResultsController;
}

@end
