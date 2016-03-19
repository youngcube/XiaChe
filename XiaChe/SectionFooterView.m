//
//  SectionFooterView.m
//  XiaChe
//
//  Created by cube on 3/17/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SectionFooterView.h"

@implementation SectionFooterView

+ (instancetype)footer
{
    SectionFooterView *view = [[self alloc] init];
    
    return view;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 30)];
        label.text = @"正在加载更多数据";
        label.backgroundColor = [UIColor redColor];
        [self addSubview:label];
    }
    return self;
}

@end
