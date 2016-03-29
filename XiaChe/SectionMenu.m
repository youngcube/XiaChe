//
//  SectionMenu.m
//  XiaChe
//
//  Created by eusoft on 3/29/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "SectionMenu.h"

@interface SectionMenu()
@property (nonatomic, weak) UIImageView *backgroundView;
@end

@implementation SectionMenu

+ (instancetype)menu
{
    return [[self alloc] init];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self){
        
    }
    return self;
}

- (UIImageView *)backgroundView
{
    if (!_backgroundView){
        UIImageView *bg = [[UIImageView alloc] init];
        bg.image = [UIImage imageNamed:@"popover_background_right"];
        bg.userInteractionEnabled = YES;
        [self addSubview:bg];
        self.backgroundView = bg;
    }
    return _backgroundView;
}

- (void)setContentView:(UIView *)contentView
{
    _contentView = contentView;
    contentView.frame = CGRectMake(0, 0, 200, 200);
    contentView.backgroundColor = [UIColor grayColor];
    [self.backgroundView addSubview:contentView];
}

- (void)showFrom:(UIView *)from
{
    UIWindow *mainWindow = [[UIApplication sharedApplication].windows lastObject];
    [mainWindow addSubview:self];
    self.frame = mainWindow.bounds;
    
    
    
}

- (void)dismiss
{
    [self removeFromSuperview];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismiss];
}

@end
