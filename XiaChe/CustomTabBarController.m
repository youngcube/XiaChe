//
//  CustomTabBarController.m
//  XiaChe
//
//  Created by cube on 4/3/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "CustomTabBarController.h"
#import "SectionsViewController.h"
#import "CustomNavigationController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (instancetype)init
{
    self = [super init];
    if (self){
        
        SectionsViewController *sections = [[SectionsViewController alloc] init];
        
        CustomNavigationController *naviSection = [[CustomNavigationController alloc] initWithRootViewController:sections];
        
        
        int offset = 7;
        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
//        naviSection.title = @"浏览";
        naviSection.tabBarItem.imageInsets = imageInset;
        naviSection.tabBarItem.image = [UIImage imageNamed:@"laugh"];
        naviSection.tabBarItem.selectedImage = [UIImage imageNamed:@"laughSelected"];
        
        NSArray *array = @[naviSection];
        [self setViewControllers:array animated:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
