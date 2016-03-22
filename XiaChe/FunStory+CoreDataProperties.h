//
//  FunStory+CoreDataProperties.h
//  XiaChe
//
//  Created by eusoft on 3/22/16.
//  Copyright © 2016 cube. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FunStory.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunStory (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *storyDate;
@property (nullable, nonatomic, retain) NSString *storyId;
@property (nullable, nonatomic, retain) NSString *title;
@property (nullable, nonatomic, retain) FunDetail *detailId;

@end

NS_ASSUME_NONNULL_END
