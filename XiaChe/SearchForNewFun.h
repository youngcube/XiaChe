//
//  SearchForNewFun.h
//  XiaChe
//
//  Created by cube on 3/19/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SearchForNewFun : NSObject
+ (instancetype)sharedInstance;
- (NSString *)fetchLastestDayFromStorage:(BOOL)lastest;
- (void)accordingDateToLoopNewData;
- (void)accordingDateToLoopOldData;
- (void)getJsonWithString:(NSString *)dateString;
@end
