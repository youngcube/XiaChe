//
//  SectionMenu.h
//  XiaChe
//
//  Created by eusoft on 3/29/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionMenu : UIView
@property (nonatomic, strong) UIView *contentView;

+ (instancetype)menu;
- (void)showFrom:(UIView *)from;
@end
