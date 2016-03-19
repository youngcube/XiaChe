//
//  SectionModel.m
//  XIaCheDaily
//
//  Created by cube on 3/15/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SectionModel.h"


@implementation StoryDetail
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"detailId" : @[@"id",@"ID"]};
}
@end

@implementation Story
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"storyId" : @[@"id",@"ID"]};
}

+ (NSArray *)modelPropertyBlacklist {
    return @[@"storyDate"];
}
@end

@implementation SectionModel
+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"stories" : [Story class]};
}
@end
