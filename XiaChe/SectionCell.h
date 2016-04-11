//
//  SectionCell.h
//  XiaChe
//
//  Created by eusoft on 3/28/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FunStory.h"

@interface SectionCell : UITableViewCell

@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;
@property (nonatomic, copy) NSNumber *unread;
@property (nonatomic, weak) FunStory *funStory;

+ (instancetype)createCellAtTableView:(UITableView *)tableView;
@end
