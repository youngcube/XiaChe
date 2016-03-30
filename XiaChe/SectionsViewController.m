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

#define HEIGHT_OF_SECTION_HEADER 50.5f

@interface SectionsViewController ()
{
    CGFloat _startPos;
}
@property (nonatomic, strong) SectionModel *model;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) NSUInteger loopTime;
@property (nonatomic) BOOL ifIsLoopNewData; // 86400是否要* -1
@property (nonatomic, strong) MJRefreshNormalHeader *autoHeader;
@property (nonatomic, strong) MJRefreshAutoNormalFooter *autoFooter;

//@property (nonatomic, strong) UIView *alphaView;
//@property (nonatomic, strong) UIButton *naviHeaderView;
//@property (nonatomic, strong) UIView *sectionHeaderView;
//@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *navTitle;
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
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showThisMenu)];
        
        
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:[StorageManager sharedInstance] action:@selector(removeAllData)];
    }
    return self;
}

- (void)showThisMenu
{
    SectionMenu *menu = [SectionMenu menu];
    menu.contentView = [UIView new];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataDidSave) name:NSManagedObjectContextDidSaveNotification object:nil];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"yyyyMMdd"];
    [self setupFooter];
    
    
    UIButton *titleNew = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
    [titleNew setTitle:@"瞎扯 · 月报" forState:UIControlStateNormal];
    [titleNew setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.navigationItem.titleView = titleNew;
    self.navTitle = titleNew;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startPos = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    
    //往下滑动 offsetY 会越来越大
    CGFloat dis = _startPos - offset;
    if (dis > 0){
        NSLog(@"start - offset > 0");
    }else{
        NSLog(@"start - offset < 0");
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
    UILabel *headerLabel = [[UILabel alloc] init];
    
    headerLabel.text = headerString;
    [headerLabel sizeToFit];
    [sectionHeaderView addSubview:headerLabel];
    
    headerLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint *centerX = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerX];
    
    NSLayoutConstraint *centerY = [NSLayoutConstraint constraintWithItem:headerLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:sectionHeaderView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0.0f];
    [sectionHeaderView addConstraint:centerY];
    return sectionHeaderView;
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
            self.loopTime = EACH_TIME_FETCH_NUM;
            self.ifIsLoopNewData = YES;
            [[SearchForNewFun sharedInstance] accordingDateToLoopNewData];
            
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

- (void)dataDidSave
{
    if (self.loopTime == 0) {
        self.tableView.mj_footer.hidden = NO;
        [self.tableView.mj_header endRefreshing];
        [self.tableView.mj_footer endRefreshing];
        return;
    }else{
        NSString *oldString = [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:YES];
        NSDate *oldDate = [self.formatter dateFromString:oldString];
        NSDate *oldDateRange;
        if (self.ifIsLoopNewData == YES){
            oldDateRange = [NSDate dateWithTimeInterval:0 sinceDate:oldDate];
        }else{
            oldDateRange = [NSDate dateWithTimeInterval:0 sinceDate:oldDate];
        }
        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
        [[SearchForNewFun sharedInstance] getJsonWithString:oldDateRangeString];
        NSString *loadString = [NSString stringWithFormat:@"正在努力加载 %lu / %d",(unsigned long)(EACH_TIME_FETCH_NUM - self.loopTime),EACH_TIME_FETCH_NUM];
        [self.autoFooter setTitle:loadString forState:MJRefreshStateRefreshing];
        self.loopTime--;
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
        self.loopTime = EACH_TIME_FETCH_NUM;
        self.ifIsLoopNewData = NO;
        [[SearchForNewFun sharedInstance] accordingDateToLoopOldData];
    }];
    self.tableView.mj_footer = self.autoFooter;
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
