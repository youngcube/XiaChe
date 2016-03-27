//
//  CustomNavigationController.m
//  XiaChe
//
//  Created by eusoft on 3/22/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "CustomNavigationController.h"

@implementation CustomNavigationController

+ (void)initialize
{
    UIBarButtonItem *item = [UIBarButtonItem appearance];
    NSDictionary *textAttr = @{NSForegroundColorAttributeName : [UIColor orangeColor]};
    [item setTitleTextAttributes:textAttr forState:UIControlStateNormal];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0){
        
    }
    [super pushViewController:viewController animated:YES];
}

- (void)setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated
{
    [super setNavigationBarHidden:hidden animated:animated];
    self.interactivePopGestureRecognizer.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.viewControllers.count > 1){
        return YES;
    }
    return NO;
}


@end
