//
//  SectionsViewController.h
//  XIaCheDaily
//
//  Created by cube on 3/15/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StorageManager.h"
@interface SectionsViewController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@end
