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

- (void) update:(id)sender;

- (void) drawOutline:(NSRect)aRect;
- (void) drawBottomBorder:(NSRect)aRect;
- (void) drawTopBorder:(NSRect)aRect;
- (void) drawLeftBorder:(NSRect)aRect;
- (void) drawRightBorder:(NSRect)aRect;

@end


#pragma mark -

@implementation XMGradientView

@synthesize gradient = _gradient;
@synthesize gradientAngle = _gradientAngle;

@synthesize doesDrawOutline = _doesDrawOutline;
@synthesize doesDrawBottomBorder = _doesDrawBottomBorder;
@synthesize doesDrawTopBorder = _doesDrawTopBorder;
@synthesize doesDrawLeftBorder = _doesDrawLeftBorder;
@synthesize doesDrawRightBorder = _doesDrawRightBorder;

@synthesize outlineColor = _outlineColor;


#pragma mark -
#pragma mark Setup

- (id)initWithFrame:(NSRect)frameRect {
	
	if ((self = [super initWithFrame:frameRect])) {
        
		self.outlineColor = [NSColor colorWithCalibratedWhite:0.25 alpha:1.0];
		self.gradient = [NSGradient inverseGlossyGradient];
        
        _gradientAngle = 90.0f;
		_doesDrawOutline = YES;
		_doesDrawTopBorder = NO;
		_doesDrawBottomBorder = NO;
        _doesDrawRightBorder = NO;
        _doesDrawLeftBorder = NO;
		
		return self;
	}
    
	return nil;
}

- (void)dealloc {
    
    [_gradient release]; _gradient = nil;
	[_outlineColor release], _outlineColor = nil;
	[super dealloc];
}

- (void)drawRect:(NSRect)aRect {
	
	[super drawRect:[self bounds]];
	
	[self.gradient drawInRect:[self bounds] angle:self.gradientAngle];
	
    [self drawOutline:[self bounds]];
    
    [self drawLeftBorder:[self bounds]];
	[self drawTopBorder:[self bounds]];
    [self drawRightBorder:[self bounds]];
	[self drawBottomBorder:[self bounds]];		
}

- (void) drawOutline:(NSRect)aRect {
    
	if (!self.doesDrawOutline) return;

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

- (void) drawBottomBorder:(NSRect)aRect {
    
	if (!self.doesDrawBottomBorder) return;

	float maxX = aRect.size.width;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(0.5, 0.5)];
	[line lineToPoint:NSMakePoint(maxX - 0.5, 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.outlineColor set];
	[line setLineWidth:1];
	[line stroke];
}

- (void) drawTopBorder:(NSRect)aRect  {
    
	if (!self.doesDrawTopBorder) return;
 
    float maxX = aRect.size.width;
	float maxY = aRect.size.height;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(0.5, maxY - 0.5)];
	[line lineToPoint:NSMakePoint(maxX - 0.5, maxY - 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.outlineColor set];
	[line setLineWidth:1];
	[line stroke];
}

- (void) drawLeftBorder:(NSRect)aRect  {
    
	if (!self.doesDrawLeftBorder) return;

	float maxY = aRect.size.height;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(0.5, 0.5)];
	[line lineToPoint:NSMakePoint(0.5, maxY - 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.outlineColor set];
	[line setLineWidth:1];
	[line stroke];
}

- (void) drawRightBorder:(NSRect)aRect  {
    
	if (!self.doesDrawRightBorder) return;

	float maxX = aRect.size.width;
	float maxY = aRect.size.height;
	NSBezierPath *line = [NSBezierPath bezierPath];
	
	[line moveToPoint:NSMakePoint(maxX - 0.5, 0.5)];
	[line lineToPoint:NSMakePoint(maxX - 0.5, maxY - 0.5)];
	[line closePath];
	
	[line setLineCapStyle:NSButtLineCapStyle];
	[line setLineJoinStyle:NSRoundLineJoinStyle];
	[self.outlineColor set];
	[line setLineWidth:1];
	[line stroke];
}

- (void) update:(id)sender {
    
    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Accessors

- (void) setGradient:(NSGradient *)theGradient {
    
	if(_gradient != theGradient) {
        
		[_gradient release];
        
		if(theGradient == nil)
			_gradient = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
        
		else _gradient = [theGradient retain];
        
		[self update:self];
	}
}

- (CGFloat) gradientAngle {
    
    return _gradientAngle;
}

- (void) setGradientAngle:(CGFloat)aGradientAngle {
    
    _gradientAngle = aGradientAngle;
    [self update:self];
}

@end
