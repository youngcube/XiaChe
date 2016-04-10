//
//  DetailToolBar.h
//  XiaChe
//
//  Created by cube on 4/10/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeformationButton.h"

@interface DetailToolBar : UIView
@property (nonatomic, weak) DeformationButton *nextBtn;
@property (nonatomic, weak) DeformationButton *beforeBtn;
@property (nonatomic, weak) UILabel *dateLabel;
@property (nonatomic, weak) UIButton *backBtn;
+ (instancetype)createToolBar;
@end
