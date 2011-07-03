//
//  GradientView.m
//  TechRequest
//
//  Created by Alex Clarke on 10/04/08.
//  Copyright 2008 CocoaLab Software Australia. All rights reserved.
//

#import "XMGradientView.h"
#import "NSGradient+XMGradients.h"


@interface XMGradientView (PrivateMethods)

-(void)drawOutline:(NSRect)aRect;
-(void)drawBottomBorder:(NSRect)aRect;
-(void)drawTopBorder:(NSRect)aRect;

@end


@implementation XMGradientView

@synthesize outlineColor;
@synthesize bottomBorderColor;
@synthesize topBorderColor;
@synthesize gradient;
@synthesize doesDrawBottomBorder;
@synthesize doesDrawTopBorder;
@synthesize doesDrawOutline;

- (id)initWithFrame:(NSRect)frameRect {
	
	if ((self = [super initWithFrame:frameRect])) 
	{
		[self setDoesDrawOutline:YES];
		[self setDoesDrawTopBorder:NO];
		[self setDoesDrawBottomBorder:NO];

		self.outlineColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
		self.gradient = [NSGradient inverseGlossyGradient];
		
		return self;
	}
    
	return nil;
}

- (void)dealloc {
    
	[outlineColor release], outlineColor = nil;
	[bottomBorderColor release], bottomBorderColor = nil;
	[topBorderColor release], topBorderColor = nil;
	[super dealloc];
}

- (void)drawRect:(NSRect)aRect {
	
	[super drawRect:[self bounds]];
	
	[self.gradient drawInRect:[self bounds] angle:90];
	
	if ([self doesDrawOutline])
		[self drawOutline:[self bounds]];
	if (self.doesDrawTopBorder)
		[self drawTopBorder:[self bounds]];
	if (self.doesDrawBottomBorder)
		[self drawBottomBorder:[self bounds]];		
}

-(void)drawOutline:(NSRect)aRect {
    
	float maxX = aRect.size.width;
	float maxY = aRect.size.height;
	NSBezierPath *outline = [NSBezierPath bezierPath];
	
	[outline moveToPoint:NSMakePoint(0, 0)];
	[outline lineToPoint:NSMakePoint(0, maxY)];
	[outline lineToPoint:NSMakePoint(maxX, maxY)];
	[outline lineToPoint:NSMakePoint(maxX, 0)];
	[outline closePath];
	
	[outline setLineCapStyle:NSButtLineCapStyle];
	[outline setLineJoinStyle:NSRoundLineJoinStyle];
	[self.outlineColor set];
	[outline setLineWidth:0.3];
	[outline stroke];
}

-(void)drawBottomBorder:(NSRect)aRect {
    
	float maxX = aRect.size.width;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(0.5, 0.5)];
	[line lineToPoint:NSMakePoint(maxX - 0.5, 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.bottomBorderColor set];
	[line setLineWidth:1];
	[line stroke];
}

-(void)drawTopBorder:(NSRect)aRect  {
    
	float maxX = aRect.size.width;
	float maxY = aRect.size.height;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(0.5, maxY - 0.5)];
	[line lineToPoint:NSMakePoint(maxX - 0.5, maxY - 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.topBorderColor set];
	[line setLineWidth:1];
	[line stroke];
}

@end
