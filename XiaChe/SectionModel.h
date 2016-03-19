//
//  SectionModel.h
//  XIaCheDaily
//
//  Created by cube on 3/15/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <YYModel/YYModel.h>

@interface StoryDetail : NSObject
@property (nonatomic, copy) NSString *body;
@property (nonatomic, copy) NSArray *css;
@property (nonatomic, copy) NSString *detailId;
@end

@interface Story : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *storyId;
@property (nonatomic, copy) NSString *storyDate;
@end

@interface SectionModel : NSObject
@property (nonatomic, copy) NSString *date;
@property (nonatomic, strong) NSArray *stories;
@end
