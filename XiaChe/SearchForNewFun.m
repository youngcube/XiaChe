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
@property (nonatomic, strong) SectionModel *model;
//@property (nonatomic, strong) NSArray *funStoryArray;
@property (nonatomic, strong) NSDateFormatter *formatter;
//@property (nonatomic) NSUInteger loopTime;
@end

@implementation SearchForNewFun

+ (instancetype)sharedInstance
{
    static SearchForNewFun *search = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        search = [[self alloc] init];
    });
    return search;
}

- (instancetype)init
{
    self = [super init];
    if (self){
        self.formatter = [[NSDateFormatter alloc] init];
        [self.formatter setDateFormat:@"yyyyMMdd"];
    }
    return self;
}

//#pragma mark - 计算从知乎日报开始至今的日子
//- (void)calculateStartTimeToNow
//{
//    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"YYYYMMdd"];
//    
//    NSDate *mostBeforeDate = [dateFormatter dateFromString:@"20130520"];
//    NSDate *nowDate = [NSDate date];
//    
//    NSTimeInterval time=[nowDate timeIntervalSinceDate:mostBeforeDate];
//    int days=((int)time)/(3600*24);
//    NSString *dateContent=[[NSString alloc] initWithFormat:@"%i天",days];
//    NSLog(@"%@",dateContent);
//}

#pragma mark - 批量返回更新的数据
- (void)accordingDateToLoopNewData
{
    [self getLastestJson];
    // 如果一下子取超过50，可能会把第一个值返回多次。
//    for (int i = 0 ; i < EACH_TIME_FETCH_NUM - 1 ; i ++){
//        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:-86400*i];
//        NSString *str = [self.formatter stringFromDate:date];
//        
//        [self getJsonWithString:str];
//    }
}

#pragma mark - 批量返回更老的数据
- (void)accordingDateToLoopOldData
{
    
//    
    NSString *oldString = [self fetchLastestDayFromStorage:YES];
//    NSDate *oldDate = [self.formatter dateFromString:oldString];
//    NSDate *oldDateRange = [NSDate dateWithTimeInterval:-86400 sinceDate:oldDate];
//    NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
    [self getJsonWithString:oldString];

}

#pragma mark - 获取CoreData内存储的 最新:NO / 最老:YES 日期
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
//    NSLog(@"%@",fun.storyDate);
    return fun.storyDate;
}

#pragma mark - 获取最新 1 天的数据
- (void)getLastestJson
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.model = [SectionModel yy_modelWithJSON:responseObject];
        for (Story *story in self.model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;
            }
        }
        [[StorageManager sharedInstance].managedObjectContext save:nil];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
}

#pragma mark - 获取新数据
- (void)getJsonWithString:(NSString *)dateString
{
    NSString *str = [NSString stringWithFormat:@"%@%@",BeforeNewsString,dateString];
    
    
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    [manager GET:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        self.model = [SectionModel yy_modelWithJSON:responseObject];
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        [fetchRequest setEntity:entity];
        NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.model.date];
        NSLog(@"self.model.date = %@",self.model.date);
        [fetchRequest setPredicate:pre];
        NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        NSLog(@"fetch array count = %lu",(unsigned long)array.count);
        FunStory *funDate = [array firstObject];
        
        if (funDate.storyDate){
            return;
        }else{
            for (Story *story in self.model.stories){
                if ([story.title hasPrefix:@"瞎扯"]) {
                    FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                    st.storyDate = self.model.date;
                    st.title = story.title;
                    st.storyId = story.storyId;
                }
            }
            [[StorageManager sharedInstance].managedObjectContext save:nil];
        }

        
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"failed! %@",error);
    }];
    
}

- (BOOL)decideIfLastestIsToday
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __block BOOL isToday;
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SectionModel *model = [SectionModel yy_modelWithJSON:responseObject];
        if (model.date == [[SearchForNewFun sharedInstance] fetchLastestDayFromStorage:NO]){
            isToday = YES;
            
        }else{
            NSLog(@"刷新");
            
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self decideIfLastestIsToday];
    }];
    return isToday;
}

@end
