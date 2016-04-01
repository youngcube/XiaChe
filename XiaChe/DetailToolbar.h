//
//  DetailToolbar.h
//  XiaChe
//
//  Created by cube on 3/23/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailToolbar : UIToolbar

@property (nonatomic, weak) UIButton *nextArticle;
@property (nonatomic, weak) UIButton *beforeArticle;
@property (nonatomic, weak) UIButton *popToLastVc;
+ (instancetype)tool;

@end
