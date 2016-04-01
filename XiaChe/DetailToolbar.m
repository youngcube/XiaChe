//
//  DetailToolbar.m
//  XiaChe
//
//  Created by cube on 3/23/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "DetailToolbar.h"
#import <Masonry.h>

@interface DetailToolbar()
//@property (nonatomic, weak) UIButton *nextArticle;
//@property (nonatomic, weak) UIButton *beforeArticle;
//@property (nonatomic, weak) UIButton *popToLastVc;
@end

@implementation DetailToolbar

+ (instancetype)tool
{
    DetailToolbar *tool = [[DetailToolbar alloc] init];
    return tool;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        UIButton *nextArticle = [[UIButton alloc] init];
        nextArticle.backgroundColor = [UIColor redColor];
        [self addSubview:nextArticle];
        self.nextArticle = nextArticle;
        
        UIButton *beforeArticle = [[UIButton alloc] init];
        beforeArticle.backgroundColor = [UIColor blueColor];
        [self addSubview:beforeArticle];
        self.beforeArticle = beforeArticle;
        
        UIButton *popToLastVc = [[UIButton alloc] init];
        popToLastVc.backgroundColor = [UIColor blackColor];
        [self addSubview:popToLastVc];
        self.popToLastVc = popToLastVc;
        
        UIButton *shareBtn = [[UIButton alloc] init];
        shareBtn.backgroundColor = [UIColor orangeColor];
        [self addSubview:shareBtn];
        
        [popToLastVc mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(10);
            make.centerY.equalTo(self);
            make.height.equalTo(@30);
        }];
        
        [beforeArticle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(popToLastVc.mas_right).offset(30);
            make.centerY.equalTo(self);
            make.height.equalTo(popToLastVc);
        }];
        
        [nextArticle mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(beforeArticle.mas_right).offset(20);
            make.centerY.equalTo(self);
            make.height.equalTo(popToLastVc);
        }];
        
        [shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-10);
            make.centerY.equalTo(self);
            make.height.equalTo(popToLastVc);
        }];
        
    }
    return self;
}

@end
