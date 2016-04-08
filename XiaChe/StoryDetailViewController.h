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
- (FunStory *)nextStoryDetailFetchWithPassFun:(FunStory *)passFun buttonEnabled:(UIBarButtonItem *)buttonItem;
- (FunStory *)beforeStoryDetailFetchWithPassFun:(FunStory *)passFun;
@end

@interface StoryDetailViewController : UIViewController
@property (nonatomic, strong) FunStory *passFun;
@property (nonatomic, copy) NSString *predicateCache;
@property (nonatomic, weak) id <StoryDetailViewControllerDelegate> delegate;
@end
