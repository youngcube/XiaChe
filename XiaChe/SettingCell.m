//
//  SettingCell.m
//  XiaChe
//
//  Created by cube on 4/4/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SettingCell.h"
#import <Masonry.h>

@interface SettingCell()

@end

@implementation SettingCell

+ (instancetype)createCellAtTableView:(UITableView *)tableView
{
    static NSString *cellId = @"settingId";
    SettingCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        
        self.progressView.delegate = self;
        
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.contentImage = imageView;
        
        UIButton *titleButton = [[UIButton alloc] init];
        [titleButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [titleButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
//        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleButton];
        self.titleButton = titleButton;
        
        ASProgressPopUpView *progressView = [[ASProgressPopUpView alloc] init];
        [self.contentView addSubview:progressView];
        self.progressView = progressView;
        
        self.progressView.font = [UIFont systemFontOfSize:14];
        self.progressView.popUpViewAnimatedColors = @[[UIColor redColor], [UIColor orangeColor], [UIColor greenColor]];
        self.progressView.popUpViewCornerRadius = 14.0;
        
        [self.contentImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(25);
            make.centerY.equalTo(self);
//            make.width.height.equalTo(@30);
        }];
        
        [self.titleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentImage.mas_right).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(20);
            make.right.equalTo(self.mas_right).offset(-20);
            make.height.equalTo(@5);
            make.centerY.equalTo(self).offset(13);
        }];
        
        
        
        
    }
    return self;
}

- (void)progressViewWillDisplayPopUpView:(ASProgressPopUpView *)progressView;
{
    [self.superview bringSubviewToFront:self];
}

@end
