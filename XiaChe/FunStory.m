//
//  FunStory.m
//  XiaChe
//
//  Created by cube on 3/21/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "FunStory.h"
#import "FunDetail.h"

@implementation FunStory

// Insert code here to add functionality to your managed object subclass

- (NSString *)simpleMonth
{
    NSDateFormatter *normalFormat = [[NSDateFormatter alloc] init];
    [normalFormat setDateFormat:@"yyyyMMdd"];
    
    NSDateFormatter *simpleFormat = [[NSDateFormatter alloc] init];
    [simpleFormat setDateFormat:@"yyyy年 MM月"];
    
    NSDate *thisDate = [normalFormat dateFromString:self.storyDate];
    return [simpleFormat stringFromDate:thisDate];
}


@end
