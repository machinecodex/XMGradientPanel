//
//  XMGradientPicker.m
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMGradientPicker.h"
#import "XMColorWell.h"
#import "XMGradientWell.h"
#import "QuartzCore/CIFilter.h"

#define kStopControlSize 12
#define kGradientRectHeight 15
#define kStopYOffset 4

@interface XMGradientPicker (Private)

- (void)makeNewStopAtLocation:(CGFloat)theLocation;
- (void)removeStopAtIndex:(NSInteger)theIndex;
- (void)moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation;
- (NSRect)gradientRect;
- (NSRect)rectForStopAtLocation:(CGFloat)theLocation;
- (void)recursiveDeactivateColorWellsInViews:(NSArray*)theViews;

@end


@implementation XMGradientPicker

@synthesize doDrawMidline = _doDrawMidline;

#pragma mark -
#pragma mark Setup

- (id)initWithFrame:(NSRect)theFrame
{
    
	if(![super initWithFrame:theFrame])
		return nil;
    
    NSLog(@"initWithFrame");

	_gradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    _doDrawMidline = YES;
	_activeColorStop = NSNotFound;
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorWellActivated:) name:@"XMColorWellDidActivateNotification" object:nil];
	return self;
}

- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;

    _doDrawMidline = [theCoder decodeBoolForKey:@"doDrawMidline"];
	NSGradient * aGradientValue = [theCoder decodeObjectForKey:@"gradientValue"];
    
	if(aGradientValue == nil)
		aGradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
    
	[self setGradientValue:aGradientValue];
	_activeColorStop = NSNotFound;
    
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorWellActivated:) name:@"XMColorWellDidActivateNotification" object:nil];
	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeObject:[self gradientValue] forKey:@"gradientValue"];
	[theCoder encodeBool:_doDrawMidline forKey:@"doDrawMidline"];
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

- (void)drawInContext:(CGContextRef)theContext {
	
    NSLog(@"drawInContext");

	CGFloat anEnabledAlpha = [self isEnabled] ? 1.0 : 0.4;
	
	NSRect aGradientRect = [self gradientRect];	
    [self drawCheckerboardInContext:theContext];

	[_gradientValue drawInRect:aGradientRect angle:90];
    
	[[NSColor colorWithDeviceWhite:.6 alpha:anEnabledAlpha] set];
	[NSBezierPath strokeRect:aGradientRect];
	
	// stops
	NSInteger aNumberOfStops = [_gradientValue numberOfColorStops];
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		CGFloat		anInset = 2;
		NSRect		aStopRect;
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		aStopRect = [self rectForStopAtLocation:aLocation];
		
		NSColor * aHighlightColor = nil;
		if(i==_activeColorStop)
		{
			if([[NSColorPanel sharedColorPanel] isVisible])
			{
				[[NSColor colorWithDeviceWhite:.45 alpha:anEnabledAlpha] set];
				[NSBezierPath fillRect:aStopRect];
			}
			aHighlightColor = [NSColor colorWithDeviceWhite:0 alpha:anEnabledAlpha];
		}
		else
			aHighlightColor = [NSColor colorWithDeviceWhite:.5 alpha:anEnabledAlpha];
        
		[[aStopColor colorWithAlphaComponent:anEnabledAlpha] set];
		[NSBezierPath fillRect:NSInsetRect(aStopRect, anInset, anInset)];
		
		[aHighlightColor set];
		[NSBezierPath strokeRect:aStopRect];
		[NSBezierPath strokeRect:NSInsetRect(aStopRect, anInset, anInset)];
        
		CGFloat aLocationY = aGradientRect.origin.y+aGradientRect.size.height*aLocation;
        
		[NSBezierPath strokeLineFromPoint:
         NSMakePoint(aStopRect.origin.x+aStopRect.size.width, 
                     aStopRect.origin.y+aStopRect.size.height*.5)
								  toPoint:
         NSMakePoint(aStopRect.origin.x+aStopRect.size.width+aGradientRect.size.width+10, 
                     aStopRect.origin.y+aStopRect.size.height*.5)];
        
		[NSBezierPath fillRect:NSMakeRect(aGradientRect.origin.x+aGradientRect.size.width, aLocationY-2.5, 5, 5)];
	}	
    
    if (self.doDrawMidline) {
        
        NSBezierPath *line = [NSBezierPath bezierPath];
        
        [line moveToPoint:NSMakePoint(aGradientRect.origin.x - 24, 
                                      aGradientRect.origin.y + aGradientRect.size.height/2)];
        [line lineToPoint:NSMakePoint(NSMaxX(aGradientRect), 
                                      aGradientRect.origin.y + aGradientRect.size.height/2)];
        
        [[NSColor blackColor] set];
        [line setLineWidth:1.0];
        [line stroke];
    }
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
    
	if(_isEnabled==NO)
		return;
    
	NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
	NSRect aGradientRect = [self gradientRect];
    
	// check gradient rect
	if(NSPointInRect(aMousePoint, aGradientRect))
	{
		// gotta convert the point so that it's in the gradient rect
		CGFloat aNewStopLocation = ((aMousePoint.x-.5-aGradientRect.origin.x)/aGradientRect.size.width);
		[self makeNewStopAtLocation:aNewStopLocation];
		return;
	}
	
	// stops
	NSInteger aNumberOfStops = [_gradientValue numberOfColorStops];
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		NSRect		aStopRect;
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		aStopRect = [self rectForStopAtLocation:aLocation];
		
		if(NSPointInRect(aMousePoint, aStopRect))
		{
			_activeColorStop = i;
			[self recursiveDeactivateColorWellsInViews:[NSArray arrayWithObject:[[self window] contentView]]];
            
			if([theEvent clickCount] == 1)
			{
				// throw up a color panel
				NSColorPanel * aColorPanel = [NSColorPanel sharedColorPanel];
				[aColorPanel setColor:aStopColor];
				[aColorPanel orderFront:self];
				[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleColorPanelDidClose:) name:NSWindowWillCloseNotification object:aColorPanel];
                [self deactivateOtherWells:self];
			}
			[self setNeedsDisplay:YES];
			return;
		}
	}
	
	// didn't click on anything
	_activeColorStop = NSNotFound;
	[self setNeedsDisplay:YES];
}

- (void) mouseDragged:(NSEvent*)theEvent {
    
	if(_activeColorStop != NSNotFound 
       &&  _activeColorStop != 0
       &&	_activeColorStop != [_gradientValue numberOfColorStops]-1)
	{
		NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
		
		CGFloat aLocationOfActiveStop;
		[_gradientValue getColor:nil location:&aLocationOfActiveStop atIndex:_activeColorStop];
		if(		_mouseDragState == kKTGradientPickerMouseDragState_NoDrag
           &&	NSPointInRect(aMousePoint, [self rectForStopAtLocation:aLocationOfActiveStop]))
		{
			_mouseDragState = kKTGradientPickerMouseDragState_DraggingColorStop;
			
		}
		else if(_mouseDragState == kKTGradientPickerMouseDragState_DraggingColorStop)
		{
			NSRect aGradientRect = [self gradientRect];
			[self moveStopAtIndex:_activeColorStop toLocation:((aMousePoint.y-.5-aGradientRect.origin.y)/aGradientRect.size.height)];
		}
	}
}

- (void)mouseUp:(NSEvent*)theEvent
{
	if(_mouseDragState != kKTGradientPickerMouseDragState_NoDrag)
	{
		if(_removeActiveColorStop)
		{
			[self removeStopAtIndex:_activeColorStop];
			[[NSCursor arrowCursor] set];
		}
		_mouseDragState = kKTGradientPickerMouseDragState_NoDrag;
	}
    
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent*)theEvent
{
	unichar aKey = [[theEvent characters] characterAtIndex:0];
    
	switch(aKey)
	{
		case NSBackTabCharacter:
            if(_activeColorStop==NSNotFound)
                _activeColorStop=[_gradientValue numberOfColorStops]-1;
            else
            {
                _activeColorStop--;
                if(_activeColorStop<0)
                {
                    _activeColorStop=0;
                    [[self window] makeFirstResponder:[self previousKeyView]];
                }
            }
            [self setNeedsDisplay:YES];
            break;
            
		case NSTabCharacter:
            if(_activeColorStop==NSNotFound)
                _activeColorStop = 0;
            else
            {		
                _activeColorStop++;
                if(_activeColorStop>[_gradientValue numberOfColorStops]-1)
                {
                    _activeColorStop = [_gradientValue numberOfColorStops]-1;
                    [[self window] makeFirstResponder:[self nextValidKeyView]];
                }
            }
            [self setNeedsDisplay:YES];
            break;
	}
}

#pragma mark -
#pragma mark Manipulating the gradient

- (void)moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation
{
	// double check we aren't trying to move the first or last stop
	if(		theIndex==0
       ||	theIndex==[_gradientValue numberOfColorStops]-1)
		return;
    
	// check the location of the stop before and after this stop
	// if they are on top of each other, remove the active stop
	CGFloat aLocationOfPreviousStop, aLocationOfNextStop;
	[_gradientValue getColor:nil location:&aLocationOfPreviousStop atIndex:_activeColorStop-1];
	[_gradientValue getColor:nil location:&aLocationOfNextStop atIndex:_activeColorStop+1];
	
	if(		theLocation<=aLocationOfPreviousStop
       ||	theLocation>=aLocationOfNextStop )
	{
		// on mouse up remove this stop
		_removeActiveColorStop = YES;
		[[NSCursor disappearingItemCursor] set];
		return;
	}
	else
	{
		_removeActiveColorStop = NO;
		[[NSCursor arrowCursor] set];
	}		
	NSInteger			aNumberOfStops = [_gradientValue numberOfColorStops];
	NSMutableArray *	aCurrentColorList = [[[NSMutableArray alloc] init] autorelease];
	CGFloat				aCurrentLocationList[aNumberOfStops];
    
	// build lists of current stops and locations
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		[aCurrentColorList addObject:aStopColor];
		if(i==theIndex)
			aCurrentLocationList[i]=theLocation;
		else
			aCurrentLocationList[i]=aLocation;
	}
	NSGradient * aNewGradient = [[[NSGradient alloc] initWithColors:aCurrentColorList atLocations:aCurrentLocationList colorSpace:[NSColorSpace genericRGBColorSpace]]autorelease];
	[self setGradientValue:aNewGradient];
}

- (void)makeNewStopAtLocation:(CGFloat)theLocation {
    
	// we'll go through out color list
	// when we get to a location larger than 'theLocation'
	// we'll insert the new color before it
	NSInteger			aNumberOfStops = [_gradientValue numberOfColorStops];
	NSMutableArray *	aCurrentColorList = [[[NSMutableArray alloc] init] autorelease];
	NSMutableArray *	aNewColorList = [[[NSMutableArray alloc] init] autorelease];
	CGFloat				aCurrentLocationList[aNumberOfStops];
	CGFloat				aNewLocationList[aNumberOfStops+1];
	BOOL				aFoundSpotForNewStop = NO;
	
	// build lists of current stops and locations
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		[aCurrentColorList addObject:aStopColor];
		aCurrentLocationList[i]=aLocation;
	}
	
	// go through the locations and find the spot to insert
	int j = 0;
	for(i = 0; i < aNumberOfStops; i++)
	{
		if(		aFoundSpotForNewStop==NO
           &&	aCurrentLocationList[i]>theLocation)
		{
			aNewLocationList[i]=theLocation;
			_activeColorStop = i;
			[aNewColorList addObject:[NSColor whiteColor]];
			aFoundSpotForNewStop = YES;
			j++;
		}
		[aNewColorList addObject:[aCurrentColorList objectAtIndex:i]];
		aNewLocationList[i+j]=aCurrentLocationList[i];	
	}
	
	NSGradient * aNewGradient = [[[NSGradient alloc] initWithColors:aNewColorList atLocations:aNewLocationList colorSpace:[NSColorSpace genericRGBColorSpace]]autorelease];
	[self setGradientValue:aNewGradient];
}

- (void)removeStopAtIndex:(NSInteger)theIndex {
	
	NSInteger aNumberOfStops = [_gradientValue numberOfColorStops];
	if(theIndex<=0 || theIndex>=aNumberOfStops-1)
		return;
	
	NSMutableArray * aColorList = [[[NSMutableArray alloc] init] autorelease];
	CGFloat aLocationList[aNumberOfStops-1];
	
	// rebuild the list from current gradient, skipping index from argument
	NSInteger i;
	NSInteger j = 0;
	for(i = 0; i < aNumberOfStops; i++)
	{
		if(i!=theIndex) {
            
			NSColor * aStopColor = nil;	
			CGFloat aLocation = 0;
			[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
			[aColorList addObject:aStopColor];
			aLocationList[j]=aLocation;
			j++;
		}
	}
	
	NSGradient * aNewGradient = [[[NSGradient alloc] initWithColors:aColorList atLocations:aLocationList colorSpace:[NSColorSpace genericRGBColorSpace]]autorelease];
	[self setGradientValue:aNewGradient];
}


#pragma mark -
#pragma mark Accessors

- (NSGradient *)gradientValue {
    
    return _gradientValue;
}

- (void)setGradientValue:(NSGradient*)theGradient {
    
	if(_gradientValue != theGradient)
	{
		[_gradientValue release];
		if(theGradient==nil)
			_gradientValue = [[NSGradient alloc] initWithStartingColor:[NSColor whiteColor] endingColor:[NSColor blackColor]];
		else
		{
			_gradientValue = [theGradient retain];
			[self performAction];
		}
		[self setNeedsDisplay:YES];
	}
}


#pragma mark -
#pragma mark NSColorPanel

- (IBAction)changeColor:(id)theSender
{
	if(_activeColorStop == NSNotFound)
		return;
    
	// save the current color list and locations
	// get the color from the color panel
	NSInteger			aNumberOfStops = [_gradientValue numberOfColorStops];
	NSMutableArray *	aColorList = [NSMutableArray array];
	CGFloat				aLocationList[aNumberOfStops];
	
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
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

- (void)handleColorWellActivated:(NSNotification*)theNotification {
    
	_activeColorStop = NSNotFound;
	[self setNeedsDisplay:YES];
}

- (void)recursiveDeactivateColorWellsInViews:(NSArray*)theViews
{
	for(NSView * aView in theViews)
	{
		if([[aView subviews] count] > 0)
			[self recursiveDeactivateColorWellsInViews:[aView subviews]];
		if([aView isKindOfClass:[NSColorWell class]])
			[(NSColorWell*)aView deactivate];
	}
}


#pragma mark -
#pragma mark Drawing/HitTest Rect Overrides

- (NSRect)gradientRect
{
	NSRect aViewRect = [self bounds];
	aViewRect.size.width -= 2;
	aViewRect.size.height -= 2;
	aViewRect.origin.x += 1.5;
	aViewRect.origin.y += 1.5;
	NSRect aGradientRect;
    CGFloat dimension = MAX(kGradientRectHeight, aViewRect.size.width - 20);
    
	aGradientRect.origin.y = aViewRect.origin.x + kStopControlSize*.5;
	aGradientRect.origin.x = aViewRect.origin.y+aViewRect.size.width - dimension - kStopYOffset;
	aGradientRect.size.height = aViewRect.size.height-kStopControlSize;
	aGradientRect.size.width = dimension;
	return aGradientRect;
}

- (NSRect)rectForStopAtLocation:(CGFloat)theLocation
{
	NSRect aStopRect;
	NSRect aGradientRect = [self gradientRect];
	aStopRect.size = NSMakeSize(kStopControlSize, kStopControlSize);
	aStopRect.origin.y = aGradientRect.origin.y+aGradientRect.size.height*theLocation;
	aStopRect.origin.y-=kStopControlSize*.5;
	aStopRect.origin.x=aGradientRect.origin.x - kStopControlSize - kStopYOffset;
	
	return aStopRect;
}

@end

#pragma mark -
// =========== Checkerboard drawing category =========== //
#pragma mark -

@implementation XMGradientPicker (Checkerboard)

- (void) drawCheckerboardInContext:(CGContextRef)theContext {
    
    [NSGraphicsContext saveGraphicsState];

	NSRect rect = [self gradientRect];	
    NSBezierPath* clipPath = [NSBezierPath bezierPathWithRect:rect];
    [clipPath addClip];
    
    NSInteger tx = 13; NSInteger ty = tx; 
    NSInteger lx = rect.size.width / tx * 1.2; NSInteger ly = rect.size.height / ty * 1.2;
    NSInteger xb, yb, i = 0, j = 0;
    NSColor *oddColor, *evenColor;
    oddColor = [NSColor whiteColor]; evenColor = [NSColor lightGrayColor];
    
    NSRect drawRect = NSMakeRect(rect.origin.x, rect.origin.y, tx * lx, ty * ly);
        
    for (xb = drawRect.origin.x; xb <= drawRect.size.width; xb+=tx) {
                
        for (yb = drawRect.origin.y; yb <= drawRect.size.height; yb+=ty) {

            if (((i+j) % 2) != 0) { // it's an odd square
                
                [[oddColor colorWithAlphaComponent:0.25] set];
                NSRectFill(NSMakeRect(xb,yb,xb+tx,yb+ty));
            }
            else { // it's an even square 
             
                [[evenColor colorWithAlphaComponent:0.25] set];
                NSRectFill(NSMakeRect(xb,yb,xb+tx,yb+ty));
            }
            
            j++;
        }
        
        i++;
    }
    
    [NSGraphicsContext restoreGraphicsState];
}

@end
