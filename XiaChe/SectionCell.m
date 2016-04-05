//
//  SectionCell.m
//  XiaChe
//
//  Created by eusoft on 3/28/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SectionCell.h"
#import <Masonry.h>
#import "UIImageView+WebCache.h"
#import "UIColor+Extension.h"

@interface SectionCell ()
@property (nonatomic, weak) UIImageView *contentImage;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *dateLabel;

@end


@implementation SectionCell

+ (instancetype)createCellAtTableView:(UITableView *)tableView
{
    static NSString *cellId = @"cellId";
    SectionCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (!cell){
        cell = [[SectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
    }
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    return cell;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        UIImageView *imageView = [[UIImageView alloc] init];
        [self.contentView addSubview:imageView];
        self.contentImage = imageView;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.numberOfLines = 0;
        [self.contentView addSubview:titleLabel];
        self.titleLabel = titleLabel;
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.font = [UIFont systemFontOfSize:11];
        [self.contentView addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        [self.contentImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-20);
            make.width.equalTo(@80);
            make.height.equalTo(@70);
            make.centerY.equalTo(self);
        }];
        
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.top.equalTo(self).offset(15);
            make.right.equalTo(self.contentImage.mas_left).offset(-10);
        }];
        
        [self.dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.titleLabel);
            make.top.equalTo(self.titleLabel.mas_bottom).offset(8);
        }];
    }
    return self;
}

- (void)setImageURL:(NSString *)imageURL
{
    _imageURL = imageURL;
    [self.contentImage sd_setImageWithURL:[NSURL URLWithString:imageURL] placeholderImage:nil];
}

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

- (void)setDate:(NSString *)date
{
    _date = date;
    NSDateFormatter *origin = [[NSDateFormatter alloc] init];
    origin.dateFormat = @"yyyyMMdd";
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    format.dateFormat = @"M 月 d 日";
    NSDate *newDate = [origin dateFromString:date];
    NSString *newDateString = [format stringFromDate:newDate];
    self.dateLabel.text = newDateString;
}

- (void)setUnread:(NSNumber *)unread
{
    _unread = unread;
    if ([unread boolValue]){
        _titleLabel.textColor = [UIColor customBlack];
        _dateLabel.textColor = [UIColor customBlack];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _contentImage.alpha = 1.0f;
    }else{
        _titleLabel.textColor = [UIColor grayColor];
        _dateLabel.textColor = [UIColor grayColor];
        _titleLabel.font = [UIFont systemFontOfSize:15];
        _contentImage.alpha = 0.6f;
    }
}

- (void)drawRect:(CGRect)rect
{
    //cell的分割线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor cellSeparateLine].CGColor);
    CGContextStrokeRect(context, CGRectMake(20, rect.size.height, rect.size.width - 40, 1));
}

@end
