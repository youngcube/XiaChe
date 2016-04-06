//
//  SearchForNewFun.h
//  XiaChe
//
//  Created by cube on 3/19/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTTPSession.h"
@interface SearchForNewFun : NSObject

@property (nonatomic) NSUInteger loopTime;
@property (nonatomic) BOOL isLoopDetail;
+ (instancetype)sharedInstance;
- (NSString *)fetchLastestDayFromStorage:(BOOL)lastest;
- (void)accordingDateToLoopNewDataWithData:(BOOL)data;
- (void)accordingDateToLoopOldData;
- (void)getJsonWithString:(NSString *)dateString;
- (NSUInteger)calculateStartTimeToNow;
- (NSUInteger)calculateStartTimeToOldTime;
- (void)getDetailJsonWithId:(NSString *)storyId;
@end
