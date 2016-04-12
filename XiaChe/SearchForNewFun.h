//
//  SearchForNewFun.h
//  XiaChe
//
//  Created by cube on 3/19/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPSession.h"

@protocol SearchNewForFunDelegate <NSObject>

- (NSString *)fetchLastestDayFromStorage:(BOOL)lastest;

@end

@interface SearchForNewFun : NSObject

@property (nonatomic) NSUInteger loopTime;
@property (nonatomic) BOOL isLoopDetail;
@property (nonatomic) BOOL isDownloadOld;
@property (nonatomic, weak) id<SearchNewForFunDelegate> delegate;
+ (instancetype)sharedInstance;
//- (NSString *)fetchLastestDayFromStorage:(BOOL)lastest;
- (void)accordingDateToLoopNewDataWithData:(BOOL)data;
- (void)accordingDateToLoopOldData;
- (void)getJsonWithString:(NSString *)dateString;
- (NSUInteger)calculateStartTimeToNow;
- (NSUInteger)calculateStartTimeToOldTime;
- (void)getDetailJsonWithId:(NSString *)storyId;

@end
