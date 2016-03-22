//
//  FunStory.h
//  XiaChe
//
//  Created by cube on 3/21/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class FunDetail;

NS_ASSUME_NONNULL_BEGIN

@interface FunStory : NSManagedObject

- (NSString *)simpleMonth;

@end

NS_ASSUME_NONNULL_END

#import "FunStory+CoreDataProperties.h"
