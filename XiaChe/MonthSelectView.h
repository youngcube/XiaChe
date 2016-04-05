//
//  MonthSelectView.h
//  XiaChe
//
//  Created by eusoft on 4/5/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MonthSelectDelegate<NSObject>;
@required
- (void)monthSelectAtIndex:(NSUInteger)index offset:(CGFloat)offset;

@end

@interface MonthSelectView : UIView
@property (nonatomic) CGFloat selectOffset;
@property (nonatomic, strong) NSArray *monthArray;
@property (nonatomic, weak) id <MonthSelectDelegate> delegate;
- (void)show;
@end
