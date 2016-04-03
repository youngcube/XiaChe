//
//  CustomTabBarController.m
//  XiaChe
//
//  Created by cube on 4/3/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "CustomTabBarController.h"
#import "SectionsViewController.h"
#import "SettingsViewController.h"
#import "CustomNavigationController.h"

@interface CustomTabBarController ()

@end

@implementation CustomTabBarController

- (instancetype)init
{
    self = [super init];
    if (self){
        
        SectionsViewController *sections = [[SectionsViewController alloc] init];
        SettingsViewController *setting = [[SettingsViewController alloc] init];
        CustomNavigationController *naviSection = [[CustomNavigationController alloc] initWithRootViewController:sections];
        CustomNavigationController *naviSetting = [[CustomNavigationController alloc] initWithRootViewController:setting];
        
        int offset = 7;
        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
//        naviSection.title = @"浏览";
        naviSection.tabBarItem.imageInsets = imageInset;
        naviSection.tabBarItem.image = [UIImage imageNamed:@"laugh"];
        naviSection.tabBarItem.selectedImage = [UIImage imageNamed:@"laughSelected"];
        naviSetting.tabBarItem.imageInsets = imageInset;
        naviSetting.tabBarItem.image = [UIImage imageNamed:@"bags"];
        NSArray *array = @[naviSection,naviSetting];
        [self setViewControllers:array animated:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
