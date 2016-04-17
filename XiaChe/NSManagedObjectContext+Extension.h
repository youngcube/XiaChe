//
//  NSManagedObjectContext+Extension.h
//  XiaChe
//
//  Created by cube on 4/14/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext (Extension)
+ (NSManagedObjectContext *)generatePrivateContextWithParent:(NSManagedObjectContext *)parentContext;
+ (NSManagedObjectContext *)generateStraightPrivateContextWithParent:(NSManagedObjectContext *)mainContext;
@end
