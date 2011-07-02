//
//  NSGradient+XMGradients.m
//  DateLine
//
//  Created by Alex Clarke on 10/02/10.
//  Copyright 2010 CocoaLab Software Australia. All rights reserved.
//

#import "NSGradient+XMGradients.h"


@implementation NSGradient (XMGradients)

+ (id) gradientFromColor:(NSColor *)color1 toColor:(NSColor *)color2 {
	
	CGFloat position1 = 0;
	CGFloat position2 = 1;
	
	id newInstance = [[[self class] alloc] initWithColorsAndLocations: 
					  
					  color1, position1,
					  color2, position2,
					  
					  nil];
	
	return [newInstance autorelease];	
}

+ (id) glossyGradientWithMidpoint:(CGFloat)midpoint color1:(NSColor *)color1 color2:(NSColor *)color2 color3:(NSColor *)color3 color4:(NSColor *)color4 {
    
	CGFloat position1 = 0;
	CGFloat position2 = midpoint;
	CGFloat position3 = midpoint;
	CGFloat position4 = 1;
    
	id newInstance = [[NSGradient alloc] initWithColorsAndLocations: 
					  
					  color1, position1,
					  color2, position2,
					  color3, position3,
					  color4, position4,
					  
					  nil];
	
	return [newInstance autorelease];   
}

+ (NSGradient *) simpleGradient {
    
    return [self gradientFromColor:[NSColor blackColor] toColor:[NSColor whiteColor]];
}

+ (NSGradient *) clearGradient {
    
    return [self gradientFromColor:[NSColor clearColor] toColor:[NSColor clearColor]];
}

+ (id) glossyGradient {
	
	float alpha = 1.0;
	
	float val1 = 1.0;
	NSColor * color1 = [NSColor colorWithCalibratedRed:val1 green:val1 blue:val1 alpha:alpha];
	float val2 = 0.90;
	NSColor * color2 = [NSColor colorWithCalibratedRed:val2 green:val2 blue:val2 alpha:alpha];
	float val3 = 0.85;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	float val4 = 0.85;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
    
	return [self glossyGradientWithMidpoint:0.5 color1:color4 color2:color3 color3:color2 color4:color1];
}

+ (id) inverseGlossyGradient {
	
	float alpha = 1.0;
	
	float val1 = 1.0;
	NSColor * color1 = [NSColor colorWithCalibratedRed:val1 green:val1 blue:val1 alpha:alpha];
	float val2 = 0.90;
	NSColor * color2 = [NSColor colorWithCalibratedRed:val2 green:val2 blue:val2 alpha:alpha];
	float val3 = 0.85;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	float val4 = 0.85;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
    
	return [self glossyGradientWithMidpoint:0.5 color1:color1 color2:color2 color3:color3 color4:color4];
}

+ (id) darkGlossyGradient {
	
	float alpha = 1.0;
	
	float val1 = 0.25;
	NSColor * color1 = [NSColor colorWithCalibratedRed:val1 green:val1 blue:val1 alpha:alpha];
	float val2 = 0.15;
	NSColor * color2 = [NSColor colorWithCalibratedRed:val2 green:val2 blue:val2 alpha:alpha];
	float val3 = 0.12;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	float val4 = 0.03;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
    
	return [self glossyGradientWithMidpoint:0.5 color1:color4 color2:color3 color3:color2 color4:color1];
}

+ (id) midGlossyGradient {
	
	float alpha = 1.0;
	
	float val1 = 0.78;
	NSColor * color1 = [NSColor colorWithCalibratedRed:val1 green:val1 blue:val1 alpha:alpha];
	float val2 = 0.68;
	NSColor * color2 = [NSColor colorWithCalibratedRed:val2 green:val2 blue:val2 alpha:alpha];
	float val3 = 0.65;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	float val4 = 0.60;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
    
	return [self glossyGradientWithMidpoint:0.5 color1:color4 color2:color3 color3:color2 color4:color1];
}

+ (id) redGlossyGradient {
	
	float alpha = 1.0;
	float val1 = 0.30;
	NSColor * color1 = [NSColor colorWithCalibratedRed:1.0 green:val1 blue:val1 alpha:alpha];
    NSColor * color2 = [NSColor colorWithCalibratedRed:0.65 green:0.0 blue:0.0 alpha:0.85];
	float val3 = 0.85;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	float val4 = 0.85;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
    
	return [self glossyGradientWithMidpoint:0.5 color1:color4 color2:color3 color3:color2 color4:color1];
}

+ (id) darkSubtleGradient {
	
	float alpha = 0.9;
	
	CGFloat position1 = 0;
	float val1 = 0.25;
	NSColor * color1 = [NSColor colorWithCalibratedRed:val1 green:val1 blue:val1 alpha:alpha];
	
	CGFloat position2 = 3.5/23;
	float val2 = 0.15;
	NSColor * color2 = [NSColor colorWithCalibratedRed:val2 green:val2 blue:val2 alpha:alpha];
	
	CGFloat position3 = 16.5/23;
	float val3 = 0.10;
	NSColor * color3 = [NSColor colorWithCalibratedRed:val3 green:val3 blue:val3 alpha:alpha];
	
	CGFloat position4 = 1;
	float val4 = 0.03;
	NSColor * color4 = [NSColor colorWithCalibratedRed:val4 green:val4 blue:val4 alpha:alpha];
	
	id newInstance = [[NSGradient alloc] initWithColorsAndLocations: 
					  
					  color1, position1,
					  color2, position2,
					  color3, position3,
					  color4, position4,
					  
					  nil];
	
	return [newInstance autorelease];
}

@end
