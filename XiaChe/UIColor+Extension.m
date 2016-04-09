//
//  UIColor+Extension.m
//  XiaChe
//
//  Created by eusoft on 3/28/16.
//  Copyright © 2016 cube. All rights reserved.
//

#import "UIColor+Extension.h"

@implementation UIColor (Extension)
//+ (UIColor *)customNavColor{
//    return RGBCOLOR(52, 136, 254);
//}

+ (UIColor *)customNavColor{
    return RGBCOLOR(173, 24, 24);
}

+ (UIColor *)cellSeparateLine
{
    return HexRGB(0xe2e2e2);
}

+ (UIColor *)cellHeaderColor
{
    return RGBCOLOR(241, 241, 241);
}

+ (UIColor *)cellHeaderTextColor
{
    return RGBCOLOR(106, 106, 106);
}

+ (UIColor *)customBlack
{
    return RGBCOLOR(52, 52, 52);
}

+ (UIColor *)customToolDate
{
    return RGBCOLOR(0, 89, 187);
}

@end
