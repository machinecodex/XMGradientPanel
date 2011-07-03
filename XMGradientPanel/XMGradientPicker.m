//
//  XMGradientPicker.m
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import "XMGradientPicker.h"
#import "XMColorWell.h"
#import "XMGradientWell.h"
#import "QuartzCore/CIFilter.h"


#pragma mark -

@interface XMGradientPicker (Private)

- (NSRect) gradientRect;
- (NSRect) rectForStopAtLocation:(CGFloat)theLocation;

- (void) makeNewStopAtLocation:(CGFloat)theLocation;
- (void) removeStopAtIndex:(NSInteger)theIndex;
- (void) moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation;

- (void) deactivateOtherWells:(id)sender;
- (void) recursiveDeactivateColorWellsInViews:(NSArray*)theViews;

@end


#pragma mark -

@implementation XMGradientPicker

@synthesize doDrawTickMarks = _doDrawTickMarks;
@synthesize numberOfTickMarks = _numberOfTickMarks;


#pragma mark -
#pragma mark Setup

- (id)initWithFrame:(NSRect)theFrame
{
    
	if(![super initWithFrame:theFrame])
		return nil;
    
	_gradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    _doDrawTickMarks = NO;
    _numberOfTickMarks = 5;
	_activeColorStop = NSNotFound;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorWellActivated:) name:XMColorWellDidActivateNotification object:nil];
    
	return self;
}

- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;

	NSGradient * aGradientValue = [theCoder decodeObjectForKey:@"gradientValue"];
    _doDrawTickMarks = [theCoder decodeBoolForKey:@"doDrawTickMarks"];
    _numberOfTickMarks = [theCoder decodeIntegerForKey:@"numberOfTickMarks"];
    
	if(aGradientValue == nil)
		aGradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    
	[self setGradientValue:aGradientValue];
	_activeColorStop = NSNotFound;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorWellActivated:) name:XMColorWellDidActivateNotification object:nil];
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];

	[theCoder encodeObject:[self gradientValue] forKey:@"gradientValue"];
	[theCoder encodeBool:_doDrawTickMarks forKey:@"doDrawTickMarks"];
    [theCoder encodeInteger:_numberOfTickMarks forKey:@"numberOfTickMarks"];
}

- (void)dealloc
{
	[_gradientValue release];
	[super dealloc];
}


#pragma mark -
#pragma mark Utilities

- (void) deactivateOtherWells:(id)sender {
    
    if ([self.target respondsToSelector:@selector(deactivateOtherWells:)]) {
        
        [self.target deactivateOtherWells:self];
    }
}


#pragma mark -
#pragma mark Drawing

- (void) drawTickMarksInRect:(NSRect)aRect {

    // For subclasses to implement
}

- (void) drawInContext:(CGContextRef)theContext {
	
    // For subclasses to implement
    // Don't forget to draw the tick marks
}


#pragma mark -
#pragma mark Events

- (BOOL) acceptsFirstResponder {
    
	return _isEnabled;
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}

- (BOOL) becomeFirstResponder {
    
	_activeColorStop = 0;
	[self display];
	return _isEnabled;
}

- (BOOL) resignFirstResponder {
    
	_activeColorStop = NSNotFound;
	[self display];
	return YES;
}

- (BOOL) canBecomeKeyView {
    
	return _isEnabled;
}

- (void)mouseDown:(NSEvent*)theEvent {
    
    // For subclasses to implement
}

- (void) mouseDragged:(NSEvent*)theEvent {
    
    // For subclasses to implement
}

- (void)mouseUp:(NSEvent*)theEvent {
    
    // For subclasses to implement
}

- (void)keyDown:(NSEvent*)theEvent {
    
    // For subclasses to implement
}

#pragma mark -
#pragma mark Manipulating the gradient

- (void)moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation {
    
    // For subclasses to implement
}

- (void)makeNewStopAtLocation:(CGFloat)theLocation {
    
    // For subclasses to implement
}

- (void)removeStopAtIndex:(NSInteger)theIndex {
	
    // For subclasses to implement
}


#pragma mark -
#pragma mark Accessors

- (NSGradient *) gradientValue {
    
    return _gradientValue;
}

- (void)setGradientValue:(NSGradient*) theGradient {
    
	if(_gradientValue != theGradient) {
        
		[_gradientValue release];
        
		if(theGradient==nil)
			_gradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
		else {
            
			_gradientValue = [theGradient retain];
			[self performAction];
		}
        
		[self setNeedsDisplay:YES];
	}
}


#pragma mark -
#pragma mark NSColorPanel

- (IBAction) changeColor:(id)theSender {
    
	if(_activeColorStop == NSNotFound)
		return;
    
	// save the current color list and locations
	// get the color from the color panel
	NSInteger			aNumberOfStops = [_gradientValue numberOfColorStops];
	NSMutableArray *	aColorList = [NSMutableArray array];
	CGFloat				aLocationList[aNumberOfStops];
	
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)	{
        
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		if(i==_activeColorStop)
			aStopColor = [[NSColorPanel sharedColorPanel] color];
		[aColorList addObject:aStopColor];
		aLocationList[i]=aLocation;
	}
	
	NSGradient * aGradient = [[[NSGradient alloc] initWithColors:aColorList atLocations:aLocationList colorSpace:[NSColorSpace genericRGBColorSpace]]autorelease];
    
	[self setGradientValue:aGradient];
}

- (void)handleColorPanelDidClose:(NSNotification*)theNotification {
    
	[self setNeedsDisplay:YES];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NSWindowWillCloseNotification object:[NSColorPanel sharedColorPanel]];
}


#pragma mark -
#pragma mark Dealing with NSColorWells

- (void) handleColorWellActivated:(NSNotification*)theNotification {
    
	_activeColorStop = NSNotFound;
	[self setNeedsDisplay:YES];
}

- (void) recursiveDeactivateColorWellsInViews:(NSArray*)theViews
{
	for(NSView * aView in theViews) {
        
		if([[aView subviews] count] > 0)
			[self recursiveDeactivateColorWellsInViews:[aView subviews]];
		if([aView isKindOfClass:[NSColorWell class]])
			[(NSColorWell*)aView deactivate];
	}
}


#pragma mark -
#pragma mark Drawing/HitTest Rect Overrides

- (NSRect) gradientRect {
    
	// For subclasses to implement
    // Return the rect that bounds your picker control
    
    NSRect aViewRect = [self bounds];
    return aViewRect;
}

- (NSRect) rectForStopAtLocation:(CGFloat)theLocation {
    
	// For subclasses to implement
    // Return the rect that bounds your stop control handle

	NSRect aStopRect = NSZeroRect;
	return aStopRect;
}

@end

#pragma mark -
// =========== Checkerboard drawing category =========== //
#pragma mark -

#define kGridAlpha 0.5f
#define kGridSquareDimension = 13.0

@implementation XMGradientPicker (Checkerboard)

- (void) drawCheckerboardInContext:(CGContextRef)theContext {
    
    [NSGraphicsContext saveGraphicsState];

    // Set up clipping
	NSRect rect = [self gradientRect];	
    NSBezierPath* clipPath = [NSBezierPath bezierPathWithRect:rect];
    [clipPath addClip];
    
    // Fill the background
    [[NSColor whiteColor] set];
    NSRectFill(rect);
    
    // Draw the checkerboard - scale dimensions larger than our clip rect
    // to avoid banding in our checkerboard
    CGFloat tx = 13; CGFloat ty = tx; CGFloat scale = 2.0;
    NSInteger lx = rect.size.width / tx * scale; NSInteger ly = rect.size.height / ty * scale;
    NSInteger xb, yb, i = 0, j = 0;
    NSColor *oddColor, *evenColor;
    oddColor = [NSColor whiteColor]; evenColor = [NSColor lightGrayColor];
    
    NSRect drawRect = NSMakeRect(rect.origin.x, rect.origin.y, tx * lx, ty * ly);
        
    for (xb = drawRect.origin.x; xb <= drawRect.size.width; xb+=tx) {
                
        for (yb = drawRect.origin.y; yb <= drawRect.size.height; yb+=ty) {

            if (((i+j) % 2) != 0) { // it's an odd square
                
                [[oddColor colorWithAlphaComponent:kGridAlpha] set];
                NSRectFill(NSMakeRect(xb,yb,xb+tx,yb+ty));
            }
            else { // it's an even square 
             
                [[evenColor colorWithAlphaComponent:kGridAlpha] set];
                NSRectFill(NSMakeRect(xb,yb,xb+tx,yb+ty));
            }
            
            j++;
        }
        
        i++;
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
