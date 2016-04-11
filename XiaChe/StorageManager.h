//
//  StorageManager.h
//  XiaChe
//
//  Created by cube on 3/16/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface StorageManager : NSObject
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSMutableArray *dateArray;
+ (instancetype)sharedInstance;
- (void)removeAllData;
@end
