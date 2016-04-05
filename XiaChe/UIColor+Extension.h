//
//  UIColor+Extension.h
//  XiaChe
//
//  Created by eusoft on 3/28/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import <UIKit/UIKit.h>
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define HexRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
@interface UIColor (Extension)
+ (UIColor *)customNavColor;
+ (UIColor *)cellSeparateLine;
+ (UIColor *)cellHeaderColor;
+ (UIColor *)cellHeaderTextColor;
+ (UIColor *)customBlack;
@end
