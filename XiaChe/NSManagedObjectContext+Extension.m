//
//  NSManagedObjectContext+Extension.m
//  XiaChe
//
//  Created by cube on 4/14/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "NSManagedObjectContext+Extension.h"

@implementation NSManagedObjectContext (Extension)
+ (NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext
{
    NSManagedObjectContext *private = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    private.parentContext = parentContext;
    return private;
}

+ (NSManagedObjectContext *)generateStraightPrivateContextWithParent:(NSManagedObjectContext *)mainContext
{
    NSManagedObjectContext *private = [[NSManagedObjectContext alloc] init];
    private.persistentStoreCoordinator = mainContext.persistentStoreCoordinator;
    return private;
}
@end
