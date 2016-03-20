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

#import "FunStory.h"
#import "SectionFooterView.h"
#import "SearchForNewFun.h"



@interface SectionsViewController ()
@property (nonatomic, strong) SectionModel *model;
//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSDateFormatter *formatter;

@end

@implementation SectionsViewController

- (instancetype)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self){
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:[SearchForNewFun sharedInstance] action:@selector(accordingDateToLoopOldData)];
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.formatter = [[NSDateFormatter alloc] init];
    [self.formatter setDateFormat:@"YYYYMMdd"];
    [StorageManager sharedInstance];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushToLastestStory) name:NOTIFICATION_FINISHLOADING object:nil];
//    [self gcd];
    
    [self decideIfShouldGetNewJson];
    [self pushToLastestStory];
    NSLog(@"view did load finished!");
}

- (void)gcd
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, queue, ^{
        [self decideIfShouldGetNewJson];
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self pushToLastestStory];
    });
}

- (void)decideIfShouldGetNewJson
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SectionModel *model = [SectionModel yy_modelWithJSON:responseObject];
        
//        FunStory *fun = [[self.fetchedResultsController fetchedObjects] firstObject];
//        if (model.date == fun.storyDate){
        if (model.date == [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]){
            NSLog(@"不要刷新");
            
        }else{
            NSLog(@"刷新");
            if ([[SearchForNewFun sharedInstance] accordingDateToLoopNewData]){
                [[NSNotificationCenter defaultCenter] postNotificationName:NSManagedObjectContextDidSaveNotification object:nil];
            };
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
        
    }];
}

- (void)pushToLastestStory
{
    NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:LatestNewsString] options:NSDataReadingUncached error:nil];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
    self.model = [SectionModel yy_modelWithDictionary:dict];
    for (Story *story in self.model.stories){
        if ([story.title hasPrefix:@"瞎扯"]) {
            
            
            StoryDetailViewController *detail = [[StoryDetailViewController alloc] init];
            NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,story.storyId];
            detail.url = url;
            [self.navigationController pushViewController:detail animated:NO];
        }
    }
}

#pragma mark - UI
- (void)setupFooter
{
    SectionFooterView *foot = [SectionFooterView footer];
    foot.frame = CGRectMake(0, 0, self.view.frame.size.width, 30);
    self.tableView.tableFooterView = foot;
    foot.hidden = YES;
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

#pragma mark - TableView DataSource
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
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - TableView Delegate
- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    FunStory *fun = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = fun.title;
    cell.detailTextLabel.text = fun.storyDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StoryDetailViewController *detail = [[StoryDetailViewController alloc] init];
//    FunStory *fun = [self.fetchedResultsController objectAtIndexPath:indexPath];
//    detail.passFun = fun;
    FunStory *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSString *storyId = object.storyId;
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,storyId];
    detail.url = url;
    detail.detailCleanId = storyId;
    NSLog(@"%@",indexPath);
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
                                                                                      sectionNameKeyPath:nil cacheName:@"funCell"];
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

//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}

@end
