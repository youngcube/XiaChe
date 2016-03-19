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
#import "StorageManager.h"
#import "FunStory.h"
#import "SectionFooterView.h"
#import "SearchForNewFun.h"

@interface SectionsViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) SectionModel *model;
@property (nonatomic, strong) NSArray *funStoryArray;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *formatter;
@end

@implementation SectionsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
//        self.eachTimeGet = 50;
//        self.getCount = 1;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"YYYYMMdd"];
    [self getNowDate];
    [self setupFooter];
//    [self showJson];
    
    
    
    [self accordingDateToLoopOldData];
    
}

- (void)pushToLastestStory
{
    FunStory *fun = [self.funStoryArray firstObject];
    StoryDetailViewController *detail = [[StoryDetailViewController alloc] init];
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,fun.storyId];
    detail.url = url;
    [self.navigationController pushViewController:detail animated:NO];
}

- (void)setupFooter
{
    SectionFooterView *foot = [SectionFooterView footer];
    foot.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    self.tableView.tableFooterView = foot;
    foot.hidden = YES;
}

- (NSArray *)funStoryArray
{
    if (!_funStoryArray){
        _funStoryArray = [NSArray array];
    }
    return _funStoryArray;
}

- (NSFetchedResultsController *)fetchedResultsController
{
    if (!_fetchedResultsController){
        StorageManager *manager = [StorageManager sharedInstance];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:NO];
        [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
        
        NSFetchedResultsController *fetchCtrl = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                                    managedObjectContext:manager.managedObjectContext
                                                                                      sectionNameKeyPath:nil cacheName:nil];
        fetchCtrl.delegate = self;
        self.fetchedResultsController = fetchCtrl;
        
        [self.fetchedResultsController performFetch:nil];
    }
    return _fetchedResultsController;
}



#pragma mark - ScrollView Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    if (self.tableView.tableFooterView.isHidden == YES) return;
//    CGFloat originY = scrollView.contentOffset.y;
//    CGFloat lastCell = scrollView.contentSize.height + scrollView.contentInset.bottom - scrollView.frame.size.height - self.tableView.tableFooterView.frame.size.height;
//    if (originY>=lastCell){
//        self.tableView.tableFooterView.hidden = NO;
//        getCount++;
//        NSUInteger newint = EACH_TIME_FETCH_NUM * getCount;
//        for (int i = 0 ; i < 50 ; i ++){
//            NSUInteger newbig = i + newint;
//            double newSign = 86400 * (double)newbig;
//            NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-newSign];
//            NSString *bigstr = [self.formatter stringFromDate:date];
//            [self getJsonWithString:bigstr];
//            NSLog(@"new data%@",bigstr);
//        }
//    }
}

- (void)getOldJsonWithString:(NSString *)oldTimes
{
    NSString *str = [NSString stringWithFormat:@"%@%@",BeforeNewsString,oldTimes];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        StorageManager *manager = [StorageManager sharedInstance];
        self.model = [SectionModel yy_modelWithJSON:responseObject];
        
        for (Story *story in self.model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                NSLog(@"%@ -- %@ -- %@",self.model.date,story.title,story.storyId);
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;
            }
        }
        [manager.managedObjectContext save:nil];
        [self showJson];
        [self.fetchedResultsController performFetch:nil];
        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 获取今天的时间
- (void)getNowDate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"YYYYMMdd"];
    NSDate *date = [NSDate date];
    NSString *str = [format stringFromDate:date];
    [self decideIfWillGetNewFromDate:str];
}

#pragma mark - 获取CoreData内存储的 最新NO / 最老YES 日期
- (NSString *)fetchLastestDayFromStorage:(BOOL)lastest
{
    StorageManager *manager = [StorageManager sharedInstance];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:lastest]; // YES返回最老的
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    NSArray *late = [manager.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    FunStory *fun = [late firstObject];
    return fun.storyDate;
}

#pragma mark - 判断是否使用需要get新日期
- (void)decideIfWillGetNewFromDate:(NSString *)dateString
{
    NSString *str = [NSString stringWithFormat:@"%@",LatestNewsString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SectionModel *model = [SectionModel yy_modelWithJSON:responseObject];
        if (model.date == [self fetchLastestDayFromStorage:NO]){
            NSLog(@"不要刷新");
            [self showJson];
            [self pushToLastestStory];
        }else{
            NSLog(@"刷新");
            [self accordingDateToLoopNewData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

- (void)accordingDateToLoopNewData
{
    [self getLastestJson];
    // 如果一下子取超过50，可能会把第一个值返回多次。
    for (int i = 0 ; i < EACH_TIME_FETCH_NUM - 1 ; i ++){
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
        NSString *str = [self.formatter stringFromDate:date];

        [self getJsonWithString:str];
    }
    [self showJson];
    [self.fetchedResultsController performFetch:nil];
    [self pushToLastestStory];
}

- (void)accordingDateToLoopOldData
{
    NSString *oldString = [self fetchLastestDayFromStorage:YES];
    for (int i = 0 ; i < EACH_TIME_FETCH_NUM ; i ++){
        NSDate *oldDate = [self.formatter dateFromString:oldString];
        NSDate *oldDateRange = [NSDate dateWithTimeInterval:-86400*i sinceDate:oldDate];
        
        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
        [self getJsonWithString:oldDateRangeString];
    }
    [self showJson];
}

- (void)getLastestJson
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        StorageManager *manager = [StorageManager sharedInstance];
        self.model = [SectionModel yy_modelWithJSON:responseObject];
        
        for (Story *story in self.model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;
            }
        }
        [manager.managedObjectContext save:nil];
        [self showJson];
//        [self.tableView reloadData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];

}

- (void)getJsonWithString:(NSString *)dateString
{
    NSString *str = [NSString stringWithFormat:@"%@%@",BeforeNewsString,dateString];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        StorageManager *manager = [StorageManager sharedInstance];
        self.model = [SectionModel yy_modelWithJSON:responseObject];

        for (Story *story in self.model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                
                NSLog(@"%@ -- %@ -- %@",self.model.date,story.title,story.storyId);
                
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;

            }
        }
        [manager.managedObjectContext save:nil];
//        [self showJson];
        [self.tableView reloadData];
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

- (void)showJson
{
    StorageManager *manager = [StorageManager sharedInstance];
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"FunStory"];
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"storyDate" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    self.funStoryArray = [manager.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    
//    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellId = @"cellId";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
    }
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [object valueForKey:@"title"];
    cell.detailTextLabel.text = [object valueForKey:@"storyDate"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoryDetailViewController *detail = [[StoryDetailViewController alloc]init];
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *storyId = [object valueForKey:@"storyId"];
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,storyId];
    detail.url = url;
    [self.navigationController pushViewController:detail animated:YES];
}

@end
