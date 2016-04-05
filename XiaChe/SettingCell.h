//
//  SettingCell.h
//  XiaChe
//
//  Created by cube on 4/4/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASProgressPopUpView.h"
@interface SettingCell : UITableViewCell<ASProgressPopUpViewDelegate>
@property (nonatomic, weak) UIImageView *contentImage;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UIButton *downloadBtn;
@property (nonatomic, weak) UIButton *cancelBtn;
@property (weak, nonatomic) ASProgressPopUpView *progressView;

+ (instancetype)createCellAtTableView:(UITableView *)tableView;
@end
