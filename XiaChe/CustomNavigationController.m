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


@end
