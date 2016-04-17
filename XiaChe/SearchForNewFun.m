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
#import "FunDetail.h"
#import "Consts.h"
#import <AFNetworking/AFNetworking.h>
#import "SectionModel.h"
#import "SDWebImageDownloader.h"
#import "ImportData.h"
@interface SearchForNewFun ()

@property (nonatomic, strong) SectionModel *model;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) BOOL ifHasXiaChe;
@property (nonatomic) BOOL isHasShenYe;

@property (nonatomic, strong) NSURLSessionConfiguration *config;
@property (nonatomic, strong) NSURLSession *session;

//@property (nonatomic, strong) NSURLSession *session;
//@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
//@property (nonatomic, strong) NSMutableData *buffer;

@end

@implementation SearchForNewFun
//TODO 检测是否有网络
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
        
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:_config];
        
    }
    return self;
}
#pragma mark - 计算从知乎日报开始至今的日子
#pragma mark 因为有瞎扯和深夜两个项目，所以要乘以2
- (NSUInteger)calculateStartTimeToNow
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSDate *mostBeforeDate = [dateFormatter dateFromString:FirstDayString];
    NSDate *nowDate = [NSDate date];
    NSTimeInterval time=[nowDate timeIntervalSinceDate:mostBeforeDate] * 2;
    NSUInteger days=((int)time)/(3600*24);
    return days;
}

- (NSUInteger)calculateStartTimeToOldTime
{
    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYYMMdd"];
    NSDate *mostBeforeDate = [dateFormatter dateFromString:FirstDayString];
    NSDate *oldDate = [dateFormatter dateFromString:[self.delegate fetchLastestDayFromStorage:YES]];
    NSTimeInterval time = [oldDate timeIntervalSinceDate:mostBeforeDate] * 2;
    NSUInteger days=((int)time)/(3600*24);
    return days;
}

#pragma mark - 批量返回更新的数据
- (void)accordingDateToLoopNewDataWithData:(BOOL)data
{
    if (data){
        NSString *oldString = [self.delegate fetchLastestDayFromStorage:NO];
        NSDate *oldDate = [self.formatter dateFromString:oldString];
        NSDate *oldDateRange = [NSDate dateWithTimeInterval:+86400*2 sinceDate:oldDate];
        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
        [self getJsonWithString:oldDateRangeString];
    }else{
        [self getLastestJson];
//        [self accordingDateToLoopOldData];
    }
}

#pragma mark - 批量返回更老的数据
- (void)accordingDateToLoopOldData
{
    NSString *oldString = [self.delegate fetchLastestDayFromStorage:YES];
    [self getJsonWithString:oldString];
}

#pragma mark - 获取最新 1 天的数据
- (void)getLastestJson
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    __weak typeof(self)weakSelf = self;
    [manager GET:LatestNewsString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _model = [SectionModel yy_modelWithJSON:responseObject];
        NSString *todayString = _model.date;
        NSString *fetchNewestDay = [[NSUserDefaults standardUserDefaults] objectForKey:@"todayString"];
        if (![todayString isEqualToString:fetchNewestDay]){
            [[NSUserDefaults standardUserDefaults] setObject:todayString forKey:@"todayString"];
        }
        for (Story *story in _model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;
                st.image = [story.images firstObject];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    // 下载进度block
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    // 下载完成block
                    st.imageData = data;
                }];
                [st setUnread:[NSNumber numberWithBool:YES]];
                [self getDetailJsonWithId:story.storyId];
            }else if ([story.title hasPrefix:@"深夜"]){
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                st.storyDate = _model.date;
                st.title = story.title;
                st.storyId = story.storyId;
                st.image = [story.images firstObject];
                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                    // 下载进度block
                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    // 下载完成block
                    st.imageData = data;
                }];
                [st setUnread:[NSNumber numberWithBool:YES]];
                [weakSelf getDetailJsonWithId:story.storyId];
            }
        }
        [[StorageManager sharedInstance].managedObjectContext save:nil];
        [weakSelf accordingDateToLoopOldData];
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
}

- (void)getJsonWithString:(NSString *)dateString
{
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount = 1;
    NSString *oldString = [self.delegate fetchLastestDayFromStorage:YES];
//    [SearchForNewFun sharedInstance].loopTime = EACH_TIME_FETCH_NUM;
    ImportData *data;
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:EACH_TIME_FETCH_NUM];
    
    for (int i = 0 ; i < [SearchForNewFun sharedInstance].loopTime ; i ++){
        NSDate *oldDate = [self.formatter dateFromString:oldString];
        NSDate *oldDateRange = [NSDate dateWithTimeInterval:-86400*i sinceDate:oldDate];
        NSString *oldDateRangeString = [self.formatter stringFromDate:oldDateRange];
        if ([oldDateRangeString isEqualToString:FirstDayString]) return;
        
        
        
        data = [[ImportData alloc] initWithDateString:oldDateRangeString];
        [queue addOperations:@[data] waitUntilFinished:YES];
//        [dataArray addObject:data];
        
        if (i == [SearchForNewFun sharedInstance].loopTime - 1){
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_END_REFRESH object:nil];
        }
        
    }
//    [queue addOperations:dataArray waitUntilFinished:YES];
}

#pragma mark - 获取新数据

- (void)getDetailJsonWithId:(NSString *)storyId
{
    NSString *url = [NSString stringWithFormat:@"%@%@",DetailNewsString,storyId];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
//        FUNLog(@"current Thread = %@",[NSThread currentThread]);
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        StoryDetail *detail = [StoryDetail yy_modelWithDictionary:dic];
        FunDetail *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunDetail" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        st.body = detail.body;
        st.css = [detail.css lastObject];
        st.detailId = detail.detailId;
        st.image = detail.image;
        st.image_source = detail.image_source;
        [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:detail.image] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
            // 下载进度block
        } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
            // 下载完成block
            st.imageData = data;
        }];
        _isLoopDetail = YES;
        if (![[StorageManager sharedInstance].managedObjectContext save:nil]) {
            FUNLog(@"SAVE ERROR  = %@",error);
            abort();
        }
    }];
    [task resume];
}

@end
