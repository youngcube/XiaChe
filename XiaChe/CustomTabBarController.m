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
        
        SectionsViewController *xiaChe = [[SectionsViewController alloc] initWithPredicate:@"瞎扯"];
        CustomNavigationController *naviXiache = [[CustomNavigationController alloc] initWithRootViewController:xiaChe];
        
        SectionsViewController *shenYe = [[SectionsViewController alloc] initWithPredicate:@"深夜"];
        CustomNavigationController *naviShenYe = [[CustomNavigationController alloc] initWithRootViewController:shenYe];
        
        
        int offset = 7;
        UIEdgeInsets imageInset = UIEdgeInsetsMake(offset, 0, -offset, 0);
        naviXiache.tabBarItem.imageInsets = imageInset;
        naviXiache.tabBarItem.image = [UIImage imageNamed:@"laugh"];
        naviXiache.tabBarItem.selectedImage = [UIImage imageNamed:@"laughSelected"];
        
        naviShenYe.tabBarItem.imageInsets = imageInset;
        naviShenYe.tabBarItem.image = [UIImage imageNamed:@"deepnight"];
        naviShenYe.tabBarItem.selectedImage = [UIImage imageNamed:@"deepnightSelected"];
        
        NSArray *array = @[naviXiache,naviShenYe];
        [self setViewControllers:array animated:YES];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

@end
