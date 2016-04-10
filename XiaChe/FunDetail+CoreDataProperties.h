//
//  FunDetail+CoreDataProperties.h
//  XiaChe
//
//  Created by cube on 4/11/16.
//  Copyright © 2016 cube. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "FunDetail.h"

NS_ASSUME_NONNULL_BEGIN

@interface FunDetail (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *body;
@property (nullable, nonatomic, retain) NSString *css;
@property (nullable, nonatomic, retain) NSString *detailId;
@property (nullable, nonatomic, retain) NSString *image;
@property (nullable, nonatomic, retain) NSString *image_source;
@property (nullable, nonatomic, retain) NSData *imageData;
@property (nullable, nonatomic, retain) FunStory *storyId;

@end

NS_ASSUME_NONNULL_END
