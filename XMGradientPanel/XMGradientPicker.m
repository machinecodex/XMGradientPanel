//
//  XMGradientPicker.m
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMGradientPicker.h"
#import "KTColorWell.h"
#import "XMGradientWell.h"
#import "QuartzCore/CIFilter.h"

#define kStopControlSize 12
#define kGradientRectHeight 15
#define kStopYOffset 4

@interface KTGradientPicker (Private)

- (void)makeNewStopAtLocation:(CGFloat)theLocation;
- (void)removeStopAtIndex:(NSInteger)theIndex;
- (void)moveStopAtIndex:(NSInteger)theIndex toLocation:(CGFloat)theLocation;
- (NSRect)gradientRect;
- (NSRect)rectForStopAtLocation:(CGFloat)theLocation;
- (void)recursiveDeactivateColorWellsInViews:(NSArray*)theViews;

@end


@implementation XMGradientPicker

@synthesize doDrawMidline = _doDrawMidline;

- (void) deactivateOtherWells:(id)sender {
    
    if ([self.target respondsToSelector:@selector(deactivateOtherWells:)]) {
        
        [self.target deactivateOtherWells:self];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}

#pragma mark -
#pragma mark House Keeping
//=========================================================== 
// - initWithFrame:
//=========================================================== 
- (id)initWithFrame:(NSRect)theFrame
{
	if(![super initWithFrame:theFrame])
		return nil;
    
	_doDrawMidline = YES;
    
	return self;
}

//=========================================================== 
// - initWithCoder:
//=========================================================== 
- (id)initWithCoder:(NSCoder*)theCoder
{
	if (![super initWithCoder:theCoder])
		return nil;
    
	_doDrawMidline = [theCoder decodeBoolForKey:@"doDrawMidline"];

	return self;
}

//=========================================================== 
// - encodeWithCoder:
//=========================================================== 
- (void)encodeWithCoder:(NSCoder*)theCoder
{	
	[super encodeWithCoder:theCoder];
	[theCoder encodeBool:_doDrawMidline forKey:@"doDrawMidline"];
}

//=========================================================== 
// - dealloc
//=========================================================== 
- (void)dealloc
{
	[super dealloc];
}


#pragma mark -
#pragma mark Drawing
//=========================================================== 
// - drawInContext:
//=========================================================== 
- (void)drawInContext:(CGContextRef)theContext
{	
	CGFloat anEnabledAlpha = [self isEnabled] ? 1.0 : 0.4;
	
	NSRect aGradientRect = [self gradientRect];	
    [self drawCheckersInContext:theContext];

	[mGradientValue drawInRect:aGradientRect angle:90];
    
	[[NSColor colorWithDeviceWhite:.6 alpha:anEnabledAlpha] set];
	[NSBezierPath strokeRect:aGradientRect];
	
	// stops
	NSInteger aNumberOfStops = [mGradientValue numberOfColorStops];
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		CGFloat		anInset = 2;
		NSRect		aStopRect;
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		
		[mGradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		aStopRect = [self rectForStopAtLocation:aLocation];
		
		NSColor * aHighlightColor = nil;
		if(i==mActiveColorStop)
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

//=========================================================== 
// - mouseDown:
//=========================================================== 
- (void)mouseDown:(NSEvent*)theEvent
{
	if(mIsEnabled==NO)
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
	NSInteger aNumberOfStops = [mGradientValue numberOfColorStops];
	NSInteger i;
	for(i = 0; i < aNumberOfStops; i++)
	{
		NSRect		aStopRect;
		NSColor *	aStopColor = nil;	
		CGFloat		aLocation = 0;
		[mGradientValue getColor:&aStopColor location:&aLocation atIndex:i];
		aStopRect = [self rectForStopAtLocation:aLocation];
		
		if(NSPointInRect(aMousePoint, aStopRect))
		{
			mActiveColorStop = i;
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
	mActiveColorStop = NSNotFound;
	[self setNeedsDisplay:YES];
}

//=========================================================== 
// - mouseDragged:
//=========================================================== 
- (void)mouseDragged:(NSEvent*)theEvent
{
	if(		mActiveColorStop!=NSNotFound 
       &&  mActiveColorStop!=0
       &&	mActiveColorStop!=[mGradientValue numberOfColorStops]-1)
	{
		NSPoint aMousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil]; 
		
		CGFloat aLocationOfActiveStop;
		[mGradientValue getColor:nil location:&aLocationOfActiveStop atIndex:mActiveColorStop];
		if(		mMouseDragState == kKTGradientPickerMouseDragState_NoDrag
           &&	NSPointInRect(aMousePoint, [self rectForStopAtLocation:aLocationOfActiveStop]))
		{
			mMouseDragState = kKTGradientPickerMouseDragState_DraggingColorStop;
			
		}
		else if(mMouseDragState == kKTGradientPickerMouseDragState_DraggingColorStop)
		{
			NSRect aGradientRect = [self gradientRect];
			[self moveStopAtIndex:mActiveColorStop toLocation:((aMousePoint.y-.5-aGradientRect.origin.y)/aGradientRect.size.height)];
		}
	}
}


#pragma mark -
#pragma mark Drawing/HitTest Rect Overrides
//=========================================================== 
// - gradientRect
//=========================================================== 
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

//=========================================================== 
// - rectForStopAtLocation:
//=========================================================== 
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


@implementation XMGradientPicker (Checkerboard)

- (void) drawCheckersInContext:(CGContextRef)theContext {
    
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
