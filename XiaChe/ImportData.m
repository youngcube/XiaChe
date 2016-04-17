//
//  ImportData.m
//  XiaChe
//
//  Created by cube on 4/17/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "ImportData.h"
#import <AFNetworking/AFNetworking.h>
#import "Consts.h"
#import <YYModel.h>
#import <CoreData/CoreData.h>
#import "SectionModel.h"
#import "SDWebImageDownloader.h"
#import "StorageManager.h"
#import "FunStory.h"
#import "FunDetail.h"
#import "SearchForNewFun.h"


@interface ImportData()
@property (nonatomic, strong) SectionModel *model;
@property (nonatomic, copy) NSString *dateString;
@property (nonatomic, strong) NSDateFormatter *formatter;
@property (nonatomic) BOOL ifHasXiaChe;
@property (nonatomic) BOOL isHasShenYe;
@property (nonatomic) BOOL isLoopDetail;



@property (nonatomic, strong) NSURLSessionConfiguration *config;
@property (nonatomic, strong) NSURLSession *session;
@end


@implementation ImportData

- (instancetype)initWithDateString:(NSString *)dateString
{
    self = [super init];
    if(self) {
        _dateString = dateString;
        _config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _session = [NSURLSession sessionWithConfiguration:_config];
    }
    return self;
}


- (void)main
{
    if ([self.dateString isEqualToString:FirstDayString]){
        [[NSUserDefaults standardUserDefaults] setObject:self.dateString forKey:@"lastDay"];
        return;
    }
    
    if ([SearchForNewFun sharedInstance].loopTime == 0) return;
    
    
    NSString *str = [NSString stringWithFormat:@"%@%@",BeforeNewsString,self.dateString];
    
    // 知乎日报可能没有瞎扯，需要跳过的逻辑
    // http://news.at.zhihu.com/api/4/news/before/20140120
//    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:str]];
//    
//    NSURLSessionDataTask *task = [_session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        
//        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
//        _model = [SectionModel yy_modelWithDictionary:dic];
////        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
////        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
////        [fetchRequest setEntity:entity];
////        NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.model.date];
////        
////        [fetchRequest setPredicate:pre];
////        NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
////        
////        FunStory *funDate = [array firstObject];
////        
////        if (funDate.storyDate){
////            return;
////        }else{
//            for (Story *story in _model.stories){
//                if ([story.title hasPrefix:@"瞎扯"]) {
//                    FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
//                    st.storyDate = _model.date;
//                    st.title = story.title;
//                    st.storyId = story.storyId;
//                    st.image = [story.images firstObject];
//                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                        // 下载进度block
//                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                        // 下载完成block
//                        st.imageData = data;
//                    }];
//                    [st setUnread:[NSNumber numberWithBool:YES]];
//                    _ifHasXiaChe = YES;
//                    
////                    [self performSelector:@selector(getDetailJsonWithId:) withObject:story.storyId];
//                }else if ([story.title hasPrefix:@"深夜"]){
//                    FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
//                    st.storyDate = self.model.date;
//                    st.title = story.title;
//                    st.storyId = story.storyId;
//                    st.image = [story.images firstObject];
//                    [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                        // 下载进度block
//                    } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                        // 下载完成block
//                        st.imageData = data;
//                    }];
//                    [st setUnread:[NSNumber numberWithBool:YES]];
//                    _isHasShenYe = YES;
////                    [self performSelector:@selector(getDetailJsonWithId:) withObject:story.storyId];
//                }
//            }
//            if (!_ifHasXiaChe){
//                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
//                st.storyDate = _model.date;
//                st.title = @"瞎扯 · 当天没有噢";
//            }else if (!_isHasShenYe){
//                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
//                st.storyDate = _model.date;
//                st.title = @"深夜 · 当天没有噢";
//            }
//            _isLoopDetail = NO;
//            //            dispatch_async(dispatch_get_main_queue(), ^{
//            NSError *core = nil;
//            FUNLog(@"CORE DATA SAVE Thread = %@",[NSThread currentThread]);
//            [[[StorageManager sharedInstance] newPrivate] performBlockAndWait:^{
//                if (![[[StorageManager sharedInstance] newPrivate] save:nil]) {
//                    FUNLog(@"ERROR = %@ CORE = %@",[core userInfo],core);
//                    abort();
//                }
//            }];
//            
//            //            });
//            
////        }
//        _ifHasXiaChe = NO;
//    }];
//    [task resume];
    
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//    __weak typeof(self)weakSelf = self;
    [manager GET:str parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        _model = [SectionModel yy_modelWithDictionary:responseObject];
        //        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        //        NSEntityDescription *entity = [NSEntityDescription entityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
        //        [fetchRequest setEntity:entity];
        //        NSPredicate *pre = [NSPredicate predicateWithFormat:@"storyDate == %@",self.model.date];
        //
        //        [fetchRequest setPredicate:pre];
        //        NSArray *array = [[StorageManager sharedInstance].managedObjectContext executeFetchRequest:fetchRequest error:nil];
        //
        //        FunStory *funDate = [array firstObject];
        //
        //        if (funDate.storyDate){
        //            return;
        //        }else{
        for (Story *story in _model.stories){
            if ([story.title hasPrefix:@"瞎扯"]) {
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                st.storyDate = _model.date;
                st.title = story.title;
                st.storyId = story.storyId;
                st.image = [story.images firstObject];
//                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                    // 下载进度block
//                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                    // 下载完成block
//                    st.imageData = data;
//                }];
                [st setUnread:[NSNumber numberWithBool:YES]];
                _ifHasXiaChe = YES;
                
                //                    [self performSelector:@selector(getDetailJsonWithId:) withObject:story.storyId];
            }else if ([story.title hasPrefix:@"深夜"]){
                FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
                st.storyDate = self.model.date;
                st.title = story.title;
                st.storyId = story.storyId;
                st.image = [story.images firstObject];
//                [[SDWebImageDownloader sharedDownloader] downloadImageWithURL:[NSURL URLWithString:[story.images firstObject]] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//                    // 下载进度block
//                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
//                    // 下载完成block
//                    st.imageData = data;
//                }];
                [st setUnread:[NSNumber numberWithBool:YES]];
                _isHasShenYe = YES;
//                [self performSelector:@selector(getDetailJsonWithId:) withObject:story.storyId];
            }
        }
        if (!_ifHasXiaChe){
            FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
            st.storyDate = _model.date;
            st.title = @"瞎扯 · 当天没有噢";
        }else if (!_isHasShenYe){
            FunStory *st = [NSEntityDescription insertNewObjectForEntityForName:@"FunStory" inManagedObjectContext:[StorageManager sharedInstance].managedObjectContext];
            st.storyDate = _model.date;
            st.title = @"深夜 · 当天没有噢";
        }
        _isLoopDetail = NO;
        //            dispatch_async(dispatch_get_main_queue(), ^{
        NSError *core = nil;
//        FUNLog(@"CORE DATA SAVE Thread = %@",[NSThread currentThread]);
        [[[StorageManager sharedInstance] newPrivate] performBlockAndWait:^{
            [SearchForNewFun sharedInstance].loopTime--;
            if (![[[StorageManager sharedInstance] newPrivate] save:nil]) {
                FUNLog(@"ERROR = %@ CORE = %@",[core userInfo],core);
                abort();
            }
        }];
        
        //            });
        
        //        }
        _ifHasXiaChe = NO;
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        [self main];
    }];

    
    
    
    
    
    
}




@end
