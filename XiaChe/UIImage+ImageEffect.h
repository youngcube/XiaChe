//
//  UIImage+ImageEffects.h
//  Inkling
//
//  Created by Aaron Pang on 3/26/14.
//  Copyright (c) 2014 Inkling. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ImageEffect)

- (UIImage *)applySubtleEffect;
- (UIImage *)applyLightEffect;
- (UIImage *)applyExtraLightEffect;
- (UIImage *)applyDarkEffect;
- (UIImage *)applyTintEffectWithColor:(UIColor *)tintColor;
- (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage;
- (UIImage *)thumbnailImage;

- (UIImage *)imageWithTintcolor:(UIColor *)color;
+ (UIImage *)imageWithBackgroundColor:(UIColor *)backgroundColor;
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size corner:(CGFloat)radius;

@end
