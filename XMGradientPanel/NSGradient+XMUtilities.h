//
//  NSGradient+XMUtilities.h
//  XMGradientPanel
//
//  Created by Alex Clarke on 23/07/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSGradient (XMUtilites)

+ (id) gradientFromColor:(NSColor *)color1 toColor:(NSColor *)color2;
+ (id) glossyGradientWithMidpoint:(CGFloat)midpoint color1:(NSColor *)color1 color2:(NSColor *)color2 color3:(NSColor *)color3 color4:(NSColor *)color4;

+ (NSGradient *) reverseGradient:(NSGradient *)inGradient;

    
@end
