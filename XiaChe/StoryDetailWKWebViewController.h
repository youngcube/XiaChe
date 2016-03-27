//
//  StoryDetailWKWebViewController.h
//  XiaChe
//
//  Created by cube on 3/27/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SectionModel.h"
#import "FunStory.h"
@interface StoryDetailWKWebViewController : UIViewController
@property (nonatomic, strong) FunStory *passFun;
@property (nonatomic, copy) NSString *url;
@property (nonatomic ,copy) NSString *thisStoryTime;
@property (nonatomic ,copy) NSString *detailCleanId;
@end
