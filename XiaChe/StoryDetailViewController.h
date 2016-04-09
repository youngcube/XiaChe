//
//  StoryDetailViewController.h
//  XIaCheDaily
//
//  Created by cube on 3/16/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionModel.h"
#import "FunStory.h"

@class StoryDetailViewController;
@class FunStory;
@protocol StoryDetailViewControllerDelegate<NSObject>
@required
- (void)nextStoryDetailFetchWithPassFun:(FunStory *)passFun;
- (void)beforeStoryDetailFetchWithPassFun:(FunStory *)passFun;
@end

@interface StoryDetailViewController : UIViewController
@property (nonatomic, strong) FunStory *passFun;
@property (nonatomic, copy) NSString *predicateCache;
@property (nonatomic, weak) id <StoryDetailViewControllerDelegate> delegate;
@end
