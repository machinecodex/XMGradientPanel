//
//  XMGradientPickerLinear.m
//  XMGradientPanel
//
//  Created by Alex Clarke on 3/07/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMGradientPickerLinear.h"
#import "XMColorWell.h"
#import "XMGradientWell.h"
#import "QuartzCore/CIFilter.h"

#define kStopControlSize 12
#define kGradientRectHeight 15
#define kStopYOffset 4

#define kTickMarkXOffsetBegin 19.0
#define kTickMarkXOffsetEnd 7.0

#pragma mark -

@interface XMGradientPicker (Private)

- (void) makeNewStopAtLocation:(CGFloat)theLocation;
- (void) removeStopAtIndex:(NSInteger)theIndex;
- (void) moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation;
- (NSRect) gradientRect;
- (NSRect) rectForStopAtLocation:(CGFloat)theLocation;
- (void) deactivateOtherWells:(id)sender;
- (void) recursiveDeactivateColorWellsInViews:(NSArray*)theViews;

@end


#pragma mark -

@implementation XMGradientPickerLinear

#pragma mark -
#pragma mark Setup

- (id)initWithFrame:(NSRect)theFrame {
    
	if(![super initWithFrame:theFrame])
		return nil;
    
    _doDrawTickMarks = YES;
    _numberOfTickMarks = 5;

	return self;
}

- (id)initWithCoder:(NSCoder*)theCoder {
    
	if (![super initWithCoder:theCoder])
		return nil;
    	
    return self;
}

- (void)encodeWithCoder:(NSCoder*)theCoder {
	
	[super encodeWithCoder:theCoder];
}

- (void)dealloc {
    
	[super dealloc];
}


#pragma mark -
#pragma mark Drawing

- (void) drawTickMarksInRect:(NSRect)aRect {
    
    NSInteger i;
    NSInteger n = _numberOfTickMarks - 1;
    CGFloat d = aRect.size.height/n;
    
    if (n < 1) return;
    
    [[[NSColor grayColor] colorWithAlphaComponent:0.5] set];
    
    for (i = 0; i <= n; i++) {
        
        NSBezierPath *line = [[NSBezierPath alloc] init];
        
        CGFloat x1 = aRect.origin.x - kTickMarkXOffsetBegin;
        CGFloat x2 = aRect.origin.x - kTickMarkXOffsetEnd;
        CGFloat y = aRect.origin.y + d * i;
        
        [line moveToPoint:NSMakePoint(floor(x1), 
                                      floor(y) + 0.5)];
        [line lineToPoint:NSMakePoint(floor(x2), 
                                      floor(y) + 0.5)];
        
        [line setLineWidth:1.0];
        [line stroke]; 
        [line closePath];
        [line release];
    }
}

- (void) drawInContext:(CGContextRef)theContext {
	
	CGFloat anEnabledAlpha = [self isEnabled] ? 1.0 : 0.4;
	
	NSRect aGradientRect = [self gradientRect];	
    [self drawCheckerboardInContext:theContext];
    
	[_gradientValue drawInRect:aGradientRect angle:90];
    
	[[NSColor colorWithDeviceWhite:.6 alpha:anEnabledAlpha] set];
	[NSBezierPath strokeRect:aGradientRect];
	
	// Draw stops
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
		if(i == _activeColorStop) {
            
			if([[NSColorPanel sharedColorPanel] isVisible]) {
                
				[[NSColor colorWithDeviceWhite:.45 alpha:anEnabledAlpha] set];
				[NSBezierPath fillRect:NSIntegralRect(aStopRect)];
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
        
		CGFloat aLocationY = aGradientRect.origin.y + aGradientRect.size.height*aLocation;
        
        // Draw line across view
		[NSBezierPath strokeLineFromPoint:
         NSMakePoint(aStopRect.origin.x+aStopRect.size.width, 
                     aStopRect.origin.y+aStopRect.size.height*.5)
								  toPoint:
         NSMakePoint(aStopRect.origin.x+aStopRect.size.width+aGradientRect.size.width+10, 
                     aStopRect.origin.y+aStopRect.size.height*.5)];
        
        // Draw stop square at far end of line
		[NSBezierPath fillRect:NSIntegralRect(NSMakeRect(aGradientRect.origin.x+aGradientRect.size.width, aLocationY-2.5, 5, 5))];
	}	
    
    if (self.doDrawTickMarks) [self drawTickMarksInRect:aGradientRect];
}


#pragma mark -
#pragma mark Events

- (void)mouseDown:(NSEvent*)theEvent {
    
	if(_isEnabled==NO)
		return;
    
	NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
	NSRect aGradientRect = [self gradientRect];
    
	// check gradient rect
	if(NSPointInRect(aMousePoint, aGradientRect))
	{
		// gotta convert the point so that it's in the gradient rect
		CGFloat aNewStopLocation = ((aMousePoint.y-.5-aGradientRect.origin.y)/aGradientRect.size.height);
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
    
	if(_activeColorStop != NSNotFound &&
       _activeColorStop != 0 &&
       _activeColorStop != [_gradientValue numberOfColorStops]-1) {
        
		NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
		
		CGFloat aLocationOfActiveStop;
		[_gradientValue getColor:nil location:&aLocationOfActiveStop atIndex:_activeColorStop];
        
		if( _mouseDragState == kXMGradientPickerMouseDragState_NoDrag &&	
           NSPointInRect(aMousePoint, [self rectForStopAtLocation:aLocationOfActiveStop])) {
            
			_mouseDragState = kXMGradientPickerMouseDragState_DraggingColorStop;
		}
		else if(_mouseDragState == kXMGradientPickerMouseDragState_DraggingColorStop) {
            
			NSRect aGradientRect = [self gradientRect];
			[self moveStopAtIndex:_activeColorStop toLocation:((aMousePoint.y-.5-aGradientRect.origin.y)/aGradientRect.size.height)];
		}
	}
}

- (void)mouseUp:(NSEvent*)theEvent {
    
	if(_mouseDragState != kXMGradientPickerMouseDragState_NoDrag) {
        
		if(_removeActiveColorStop) {
            
			[self removeStopAtIndex:_activeColorStop];
			[[NSCursor arrowCursor] set];
		}
        
		_mouseDragState = kXMGradientPickerMouseDragState_NoDrag;
	}
    
	[self setNeedsDisplay:YES];
}

- (void)keyDown:(NSEvent*)theEvent {
    
	unichar aKey = [[theEvent characters] characterAtIndex:0];
    
	switch(aKey) {
            
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

- (void)moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation {
    
	// double check we aren't trying to move the first or last stop
	if( theIndex==0 ||	
       theIndex==[_gradientValue numberOfColorStops]-1) return;
    
	// check the location of the stop before and after this stop
	// if they are on top of each other, remove the active stop
	CGFloat aLocationOfPreviousStop, aLocationOfNextStop;
	[_gradientValue getColor:nil location:&aLocationOfPreviousStop atIndex:_activeColorStop-1];
	[_gradientValue getColor:nil location:&aLocationOfNextStop atIndex:_activeColorStop+1];
	
	if(theLocation <= aLocationOfPreviousStop ||	
       theLocation >= aLocationOfNextStop ) {
        
		// on mouse up remove this stop
		_removeActiveColorStop = YES;
		[[NSCursor disappearingItemCursor] set];
		return;
	}
	else {
        
		_removeActiveColorStop = NO;
		[[NSCursor arrowCursor] set];
	}	
	
	NSInteger			aNumberOfStops = [_gradientValue numberOfColorStops];
	NSMutableArray *	aCurrentColorList = [[[NSMutableArray alloc] init] autorelease];
	CGFloat				aCurrentLocationList[aNumberOfStops];
    
	// build lists of current stops and locations
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++) {
        
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
	for(i = 0; i < aNumberOfStops; i++) {
        
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		[_gradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		[aCurrentColorList addObject:aStopColor];
		aCurrentLocationList[i]=aLocation;
	}
	
	// go through the locations and find the spot to insert
	int j = 0;
	for(i = 0; i < aNumberOfStops; i++) {
        
		if(aFoundSpotForNewStop == NO &&	
           aCurrentLocationList[i] > theLocation) {
            
			aNewLocationList[i]=theLocation;
			_activeColorStop = i;
			[aNewColorList addObject:[NSColor whiteColor]];
			aFoundSpotForNewStop = YES;
			j++;
		}
        
		[aNewColorList addObject:[aCurrentColorList objectAtIndex:i]];
		aNewLocationList[i+j] = aCurrentLocationList[i];	
	}
	
	NSGradient * aNewGradient = [[[NSGradient alloc] initWithColors:aNewColorList atLocations:aNewLocationList colorSpace:[NSColorSpace genericRGBColorSpace]]autorelease];
	[self setGradientValue:aNewGradient];
}

- (void)removeStopAtIndex:(NSInteger)theIndex {
	
	NSInteger aNumberOfStops = [_gradientValue numberOfColorStops];
    
	if(theIndex <= 0 || theIndex >= aNumberOfStops-1) return;
	
	NSMutableArray * aColorList = [[[NSMutableArray alloc] init] autorelease];
	CGFloat aLocationList[aNumberOfStops-1];
	
	// rebuild the list from current gradient, skipping index from argument
	NSInteger i;
	NSInteger j = 0;
	for(i = 0; i < aNumberOfStops; i++) {
        
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
#pragma mark Drawing/HitTest Rect Overrides

- (NSRect) gradientRect {
    
	NSRect aViewRect = [self bounds];
	aViewRect.size.width -= 35;
	aViewRect.size.height -= 23;
	aViewRect.origin.x += 10.5;
	aViewRect.origin.y += 15.5;
    
	NSRect aGradientRect;
    
    CGFloat dimension = MAX(kGradientRectHeight, aViewRect.size.width - 34);
    
	aGradientRect.origin.y = aViewRect.origin.y + kStopControlSize*.5;
	aGradientRect.origin.x = aViewRect.origin.x + aViewRect.size.width 
    - dimension - kStopYOffset;
	aGradientRect.size.height = aViewRect.size.height - kStopControlSize;
	aGradientRect.size.width = dimension;
    
	return aGradientRect;
}

- (NSRect) rectForStopAtLocation:(CGFloat)theLocation {
    
	NSRect aStopRect;
	NSRect aGradientRect = [self gradientRect];
	aStopRect.size = NSMakeSize(kStopControlSize, kStopControlSize);
	aStopRect.origin.y = aGradientRect.origin.y + aGradientRect.size.height * theLocation;
	aStopRect.origin.y -= kStopControlSize * .5;
	aStopRect.origin.x = aGradientRect.origin.x - kStopControlSize - kStopYOffset;
	
	return aStopRect;
}

@end

