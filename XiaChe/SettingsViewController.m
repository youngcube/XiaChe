//
//  SettingsViewController.m
//  XiaChe
//
//  Created by eusoft on 3/29/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SettingsViewController.h"

typedef NS_ENUM(NSInteger, Sections){
    kSectionOne = 0,
    kSectionTwo,
    NUM_SECTIONS
};

typedef NS_ENUM(NSInteger, SectionOne){
    kDownList = 0,
    kWrongTest,
    kMyFav,
    NUM_SectionOne_ROWS
};

typedef NS_ENUM(NSInteger, SectionTwo){
    kDownDetail = 0,
    kHelp,
    kAboutUs,
    kSignOut,
    NUM_SectionTwo_ROWS
};

@interface SettingsViewController()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, weak) UITableView *tableView;
@end

@implementation SettingsViewController

- (instancetype)init
{
    self = [super init];
    if (self){
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(downList)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupTableView];
}

- (void)downList
{
    
}

- (void)setupTableView
{
    UITableView *table = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    [self.view addSubview:table];
    table.dataSource = self;
    table.delegate = self;
    self.tableView = table;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == kSectionOne){
        return NUM_SectionOne_ROWS;
    }else{
        return NUM_SectionTwo_ROWS;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kSectionOne){
        switch (indexPath.row) {
            case kDownList:
                cell.textLabel.text = @"good";
                break;
            default:
                break;
        }
    }else{
        
    }
}

@end
