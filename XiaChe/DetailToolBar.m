//
//  DetailToolBar.m
//  XiaChe
//
//  Created by cube on 4/10/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "DetailToolBar.h"
#import <Masonry.h>
#import "UIColor+Extension.h"

@implementation DetailToolBar

+ (instancetype)createToolBar
{
    DetailToolBar *tool = [[self alloc] init];
    return tool;
}
//@property (nonatomic, weak) UIButton *nextBtn;
//@property (nonatomic, weak) UIButton *beforeBtn;
//@property (nonatomic, weak) UILabel *dateLabel;
//@property (nonatomic, weak) UIButton *backBtn;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        self.backgroundColor = [UIColor clearColor];
        UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *backImg = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [backBtn setImage:backImg forState:UIControlStateNormal];
        [backBtn setTintColor:[UIColor customNavColor]];
        [self addSubview:backBtn];
        self.backBtn = backBtn;
        
        DeformationButton *beforeBtn = [[DeformationButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withColor:[UIColor clearColor]];
        UIImage *beforeImg = [[UIImage imageNamed:@"downArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [beforeBtn.forDisplayButton setImage:beforeImg forState:UIControlStateNormal];
        [beforeBtn setTintColor:[UIColor customNavColor]];
        beforeBtn.progressColor = [UIColor customNavColor];
        [beforeBtn setTintColor:[UIColor customNavColor]];
        [self addSubview:beforeBtn];
        self.beforeBtn = beforeBtn;
        
        DeformationButton *nextBtn = [[DeformationButton alloc] initWithFrame:CGRectMake(0, 0, 30, 30) withColor:[UIColor clearColor]];
        UIImage *nextImg = [[UIImage imageNamed:@"upArrow"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [nextBtn.forDisplayButton setImage:nextImg forState:UIControlStateNormal];
        [nextBtn setTintColor:[UIColor customNavColor]];
        nextBtn.progressColor = [UIColor customNavColor];
        [nextBtn setTintColor:[UIColor customNavColor]];
        [self addSubview:nextBtn];
        self.nextBtn = nextBtn;
        
        UILabel *dateLabel = [[UILabel alloc] init];
        dateLabel.textColor = [UIColor customNavColor];
        [self addSubview:dateLabel];
        self.dateLabel = dateLabel;
        
        [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(20);
            make.width.height.equalTo(@40);
            make.centerY.equalTo(self);
        }];
        
        [beforeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(backBtn);
            make.left.equalTo(backBtn.mas_right).offset(30);
        }];
        
        [nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.centerY.equalTo(backBtn);
            make.left.equalTo(beforeBtn.mas_right).offset(30);
        }];
        
        [dateLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.centerY.equalTo(backBtn);
            make.right.equalTo(self).offset(-30);
//            make.width.equalTo(@100);
        }];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    //cell的分割线
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, [UIColor customNavColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(10, 0, rect.size.width-20, 1/[UIScreen mainScreen].scale));
}

@end
