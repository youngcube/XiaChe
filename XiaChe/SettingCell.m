//
//  SettingCell.m
//  XiaChe
//
//  Created by cube on 4/4/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SettingCell.h"
#import <Masonry.h>
#import "UIColor+Extension.h"

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
    tableView.allowsSelection = NO;
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
        
        UILabel *titleLabel = [[UILabel alloc] init];
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;

        UIButton *downloadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        downloadBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [downloadBtn setTitleColor:[UIColor customBlack] forState:UIControlStateNormal];
        [downloadBtn setBackgroundColor:[UIColor customNavColor]];
        [downloadBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        downloadBtn.layer.cornerRadius = 5.0f;
        downloadBtn.layer.masksToBounds = YES;
        downloadBtn.layer.borderWidth = 0.5f;
        [self.contentView addSubview:downloadBtn];
        self.downloadBtn = downloadBtn;
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
        [cancelBtn setTitleColor:[UIColor customBlack] forState:UIControlStateNormal];
        [cancelBtn setBackgroundColor:[UIColor customNavColor]];
        [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        cancelBtn.layer.cornerRadius = 5.0f;
        cancelBtn.layer.masksToBounds = YES;
        cancelBtn.layer.borderWidth = 0.5f;
        [self.contentView addSubview:cancelBtn];
        self.cancelBtn = cancelBtn;
        
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
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentImage.mas_right).offset(15);
            make.centerY.equalTo(self);
        }];
        
        [self.downloadBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.cancelBtn.mas_left).offset(-10);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
        }];
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-20);
            make.centerY.equalTo(self);
            make.width.equalTo(@40);
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
