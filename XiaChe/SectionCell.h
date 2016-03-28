//
//  SectionCell.h
//  XiaChe
//
//  Created by eusoft on 3/28/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SectionCell : UITableViewCell

@property (nonatomic, copy) NSString *imageURL;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *date;

+ (instancetype)createCellAtTableView:(UITableView *)tableView;
@end
