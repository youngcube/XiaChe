//
//  SearchForNewFun.m
//  XiaChe
//
//  Created by cube on 3/19/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SearchForNewFun.h"
#import "StorageManager.h"
#import "FunStory.h"
#import "Consts.h"
#import <AFNetworking/AFNetworking.h>
#import "SectionModel.h"

@interface SearchForNewFun ()

@end

@implementation SearchForNewFun



#pragma mark - 计算从知乎日报开始至今的日子
- (void)calculateStartTimeToNow
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    
    NSDate *mostBeforeDate = [dateFormatter dateFromString:@"20130519"];
    NSDate *nowDate = [NSDate date];
    
    NSTimeInterval time=[nowDate timeIntervalSinceDate:mostBeforeDate];
    int days=((int)time)/(3600*24);
    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i天",days];
    NSLog(@"%@",dateContent);
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
//            [self showJson];
//            [self pushToLastestStory];
        }else{
            NSLog(@"刷新");
//            [self accordingDateToLoopNewData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
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

//- (void)accordingDateToLoopNewData
//{
//    [self getLastestJson];
//    // 如果一下子取超过50，可能会把第一个值返回多次。
//    for (int i = 0 ; i < EACH_TIME_FETCH_NUM - 1 ; i ++){
//        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
//        NSString *str = [self.formatter stringFromDate:date];
//        
//        [self getJsonWithString:str];
//    }
//    [self showJson];
//    [self.fetchedResultsController performFetch:nil];
//    [self pushToLastestStory];
//}
//
//- (void)accordingDateToLoopOldData
//{
//    NSString *oldString = [self fetchLastestDayFromStorage:YES];
//    for (int i = 0 ; i < EACH_TIME_FETCH_NUM ; i ++){
//        NSDate *oldDate = [self.formatter dateFromString:oldString];
//        NSDate *oldDateRange = [NSDate dateWithTimeInterval:-86400*i sinceDate:oldDate];
//        
//        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
//        [self getJsonWithString:oldDateRangeString];
//    }
//    [self showJson];
//}
//
//- (void)getLastestJson
//{
//    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//        
//    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        StorageManager *manager = [StorageManager sharedInstance];
//        self.model = [SectionModel yy_modelWithJSON:responseObject];
//        
//        for (Story *story in self.model.stories){
//            if ([story.title hasPrefix:@"瞎扯"]) {
//                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:manager.managedObjectContext];
//                st.storyDate = self.model.date;
//                st.title = story.title;
//                st.storyId = story.storyId;
//            }
//        }
//        [manager.managedObjectContext save:nil];
//        [self showJson];
//        //        [self.tableView reloadData];
//    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//        NSLog(@"failed! %@",error);
//    }];
//    
//}

@end
