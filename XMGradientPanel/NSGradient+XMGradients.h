//
//  NSGradient+XMGradients.h
//  DateLine
//
//  Created by Alex Clarke on 10/02/10.
//  Copyright 2010 CocoaLab Software Australia. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSGradient (XMGradients)

+ (NSGradient *) simpleGradient;
+ (NSGradient *) clearGradient;

+ (id) gradientFromColor:(NSColor *)color1 toColor:(NSColor *)color2;

+ (id) glossyGradientWithMidpoint:(CGFloat)midpoint color1:(NSColor *)color1 color2:(NSColor *)color2 color3:(NSColor *)color3 color4:(NSColor *)color4;

+ (id) glossyGradient;
+ (id) inverseGlossyGradient;
+ (id) darkGlossyGradient;
+ (id) midGlossyGradient;
+ (id) redGlossyGradient;
+ (id) darkSubtleGradient;

@end
