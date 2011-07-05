//
//  XMGradientWell.m
//  DateLine 2
//
//  Created by Alex Clarke on 4/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import "XMGradientWell.h"
#import "XMGradientPanel.h"
#import "NSGradient+XMGradients.h"

@implementation XMGradientWell

#define XMPasteboardTypeGradient @"com.machinecodex.pasteboard.gradient"

#pragma mark -
#pragma mark Setup and dealloc

#define kInsetRegular 5
#define kInsetSwatch 2


+ (void) initialize {
    
    [self exposeBinding:@"gradient"];
}

@synthesize target = _target;
@synthesize action = _action;
@synthesize isActive = _isActive;
@synthesize isSwatch = _isSwatch;
@synthesize dragImage = _dragImage;


- (id) initWithFrame:(NSRect)frameRect
{
	if((self=[super initWithFrame: frameRect]))
    {
		_isBordered = YES;
        _isSwatch = NO;
        _gradient = [[NSGradient clearGradient] retain];
    }
    
    [self registerForDraggedTypes:[self pasteboardTypes]];
	return self;
}

- (void) dealloc
{
    [_gradient release]; _gradient = nil;
    [_dragImage release]; _dragImage = nil;
	[super dealloc];
}


#pragma mark -
#pragma mark Drawing and mouse

- (id) controlInactiveBackgroundGradient; {
    
    NSColor * light = [NSColor colorWithCalibratedWhite:0.97 alpha:1.0];
    NSColor * lightGrey = [NSColor colorWithCalibratedWhite:0.9 alpha:1.0];
    NSColor * midGrey = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];

    return [[[NSGradient alloc] initWithColorsAndLocations:
     light, 0.0, 
     lightGrey, 0.85, 
     midGrey, 0.85, 
     light, 0.9, 
     nil] autorelease];
}

- (id) controlActiveBackgroundGradient; {
    
    NSColor * midGrey = [NSColor colorWithCalibratedWhite:0.85 alpha:1.0];
    NSColor * mid = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];
    NSColor * darkGrey = [NSColor colorWithCalibratedWhite:0.4 alpha:1.0];

    return [[[NSGradient alloc] initWithColorsAndLocations:
     mid, 0.0, 
     darkGrey, 0.88, 
     mid, 0.9, 
     midGrey, 1.0, 
     nil] autorelease];
}

- (void) drawRect:(NSRect)rect
{
	NSRect swatchRect;
    NSGradient * _backgroundGradient;
    CGFloat inset = kInsetRegular;
    NSBezierPath * p = [NSBezierPath bezierPathWithRect:[self bounds]];

    if (_isSwatch) { 
        
        inset = kInsetSwatch;
        
        [[NSColor whiteColor] set];
        NSRectFill([self bounds]);
        
        [[NSColor lightGrayColor] set];
        NSFrameRect(rect);
    }
    else {

        if (!_isActive) // Draw the background
        {                    
            _backgroundGradient = [self controlInactiveBackgroundGradient];
        }
        else
        {                    
            _backgroundGradient = [self controlActiveBackgroundGradient];
        }
        
        [_backgroundGradient drawInBezierPath:p angle:90];
    
        if (!_isActive)
            [[NSColor grayColor] set];
        else
            [[NSColor darkGrayColor] set];
        
        NSFrameRect(rect);
    }
        
    if (_gradient == nil) return;
    
    swatchRect = NSInsetRect(_bounds, inset, inset);
    [self drawWellInside:swatchRect]; // Draw the swatch
}

- (void) drawWellInside:(NSRect)insideRect
{
    [_gradient drawInRect:insideRect angle:90]; // Draw the swatch
    
    if (!_isActive) // Draw the border
        [[NSColor grayColor] set];
    else
        [[NSColor darkGrayColor] set];

    NSFrameRect(insideRect);
}

- (void) activatePanel {
    
    [self activate:YES];
    panel = [XMGradientPanel sharedGradientPanel];
    [panel setDelegate:self];
    [panel setFloatingPanel:NO];
    [panel setIsContinuous:YES];
    [panel orderFront:nil];
    [panel setAction:@selector(takeGradientFrom:)];
    [panel setTarget:self];
    [panel setGradient:_gradient];
    [self setNeedsDisplay:YES];
}

- (void) performSwatchAction {
    
    // We are in the panel
    [self activate:YES];
    panel = [XMGradientPanel sharedGradientPanel];
    [panel setDelegate:self];
    [panel setIsContinuous:YES];
    [panel setGradient:_gradient];
    [self setNeedsDisplay:YES];
}

- (void) mouseDown:(NSEvent*)event {
    
	_isActive = !(_isActive);
    [self setNeedsDisplay:YES];
        
    if (_isSwatch) { 
        
        [self performSwatchAction];
        return;
    }
    
	if(_isActive) [self activatePanel];
}

- (void) mouseDragged:(NSEvent *)event {
    
//    NSPoint location = [event locationInWindow];
    NSPoint location = [self bounds].origin;
    NSSize offset = NSZeroSize;
    NSSize size;
    
    if (!self.dragImage) self.dragImage = [self dragImage];

    NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    [pboard declareTypes:[NSArray arrayWithObject: XMPasteboardTypeGradient] owner:self];
    
    BOOL didCopyData = [pboard setData:[self pasteboardPropertyListForType:XMPasteboardTypeGradient] forType:XMPasteboardTypeGradient];
    
    if (self.dragImage && didCopyData) {
        
        size = [self.dragImage size];
        location.x = ([self bounds].size.width - size.width)/2;
        location.y = ([self bounds].size.height - size.height)/2;
        
        _isActive = NO;
        [self setNeedsDisplay];
    }
    
    [self dragImage:self.dragImage at:location offset:offset event:event pasteboard:pboard source:self slideBack:YES];  
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}


#pragma mark -
#pragma mark NSPanel Delegate

- (BOOL) windowShouldClose:(id)sender { 
    
    // Called when the GradientPanel closes so we can update ui
    
    _isActive = NO;
	[self setNeedsDisplay:YES];

    return YES;
}


#pragma mark -
#pragma mark Actions

- (void)recursiveDeactivateGradientWellsInViews:(NSArray*)theViews {
        
	for(NSView * aView in theViews)
	{
		if([[aView subviews] count] > 0)
			[self recursiveDeactivateGradientWellsInViews:[aView subviews]];
		if([aView isKindOfClass:[XMGradientWell class]] && (XMGradientWell*)aView != self)
			[(XMGradientWell*)aView deactivate];
		if([aView isKindOfClass:[NSColorWell class]])
			[(NSColorWell*)aView deactivate];
	}
    
    [self setNeedsDisplay:YES];
}

- (void) deactivateOtherWells:(id)sender {
    
    NSArray * views = [[self superview] subviews];
    [self recursiveDeactivateGradientWellsInViews:views];
}

- (void) activate:(BOOL)exclusive {
    
    if(exclusive) 
        [self deactivateOtherWells:self];
    
	_isActive = YES;
    [self setNeedsDisplay:YES];
}

- (void) deactivate {
    
	_isActive = NO;
    [self setNeedsDisplay:YES];
}

- (BOOL) isOpaque {
    
    return _isBordered; 
}

- (BOOL) isBordered {
    
    return _isBordered; 
}

- (void)performAction {
    
//    if (!self.isActive) return;
    
	if([self.target respondsToSelector:self.action])
		[self.target performSelector:self.action withObject:self];
}

- (NSGradient *) gradient {
    
    return _gradient; 
}

- (void) setGradient:(NSGradient *)gradient {
    
    if (_gradient != gradient) {
        [_gradient release];
        _gradient = [gradient retain];
        [self setNeedsDisplay:YES];
    }
}

- (void) setIsBordered:(BOOL)bordered
{
	_isBordered = bordered;
	[self setNeedsDisplay];
}

- (void) takeGradientFrom:(id)sender {
    
    if (!self.isActive) return;

	if([sender respondsToSelector:@selector(gradient)]) {
        
		[self setGradient:[sender gradient]];
        [self performAction];
    }
}


#pragma mark -
#pragma mark NSCoding

- (void) encodeWithCoder:(NSCoder *) aCoder
{
	[super encodeWithCoder:aCoder];
	[aCoder encodeObject: _gradient];
	[aCoder encodeBool:_isBordered forKey:@"isBorderd"];
	[aCoder encodeBool:_isSwatch forKey:@"_isSwatch"];
}

- (id) initWithCoder:(NSCoder *) aDecoder
{
	self = [super initWithCoder:aDecoder];
        
    _gradient = [[aDecoder decodeObjectForKey:@"NSGradient"] retain];
    _isBordered = [aDecoder decodeBoolForKey:@"isBordered"];
    _isSwatch = [aDecoder decodeBoolForKey:@"isSwatch"];

	return self;
}


#pragma mark -
#pragma mark Bindings support

- (NSArray *) exposedBindings
{
	return [NSArray arrayWithObjects:@"gradient", nil];	
}

- (Class) valueClassForBinding:(NSString *)binding
{
	if ([binding isEqualToString:@"gradient"]) {
		return [NSGradient class];
	}
	return nil;
}

- (void) bind:(NSString *)bindingName toObject:(id)observableController withKeyPath:(NSString *)keyPath options:(NSDictionary *)options {
	
    if ([bindingName isEqualToString:@"gradient"])
    {
		[observableController addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:nil];
	}
	
	[super bind:bindingName toObject:observableController withKeyPath:keyPath options:options];
	[self setNeedsDisplay:YES];
}

- (void)unbind:bindingName
{
    if ([bindingName isEqualToString:@"gradient"]) {

		NSDictionary *bindingInfo = [self infoForBinding:@"gradient"];
		id gradient = [bindingInfo objectForKey:NSObservedObjectKey];
		NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
		
		[gradient removeObserver:self forKeyPath:observedKeyPath];
    }	

	[super unbind:bindingName];
	[self setNeedsDisplay:YES];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
		
    NSDictionary *bindingInfo = [self infoForBinding:@"gradient"];
    id observedObject = [bindingInfo objectForKey:NSObservedObjectKey];
    NSString *observedKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
        
    id newGradient = [observedObject valueForKeyPath:observedKeyPath];
    
    if ((newGradient == NSNoSelectionMarker) || (newGradient == NSNotApplicableMarker)
        || ((newGradient == NSMultipleValuesMarker))) {
        
        badSelection = YES;
    }
    else {
        
        badSelection = NO;
        
        if (newGradient == NSMultipleValuesMarker) {
            multipleSelection = YES;
        }
        else {
            [self setGradient:newGradient];
            multipleSelection = NO;
        }
    }

    [self setNeedsDisplay:YES];
}


#pragma mark -
#pragma mark Drag and drop

// this is called when the drag enters our view
// by returning NSDragOperationCopy
- (NSDragOperation) draggingEntered: (id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    
    lastDragged = NSDragOperationNone;
    pboard = [sender draggingPasteboard];
    
    // we don't acept drags if we are the provider!!
    if ([sender draggingSource] == self) return NSDragOperationNone;
    
    if ([[pboard types] containsObject:XMPasteboardTypeGradient]) {
        
        if (self.dragImage == nil) {
            
            self.dragImage = [self dragImage]; 
        }

        [self setNeedsDisplay];
        
        lastDragged = [sender draggingSourceOperationMask]; 
    }
    return lastDragged;
}

// instead of constantly rechecking the pasteboard as the mouse moves inside the view
// we'll simply return the cached value that we set in 'last' in draggingEntered:
- (NSUInteger) draggingUpdated:sender
{
    return lastDragged;
}

// Because we're providing feedback by setting the file right when the user enters
// we'll need to undo that work if the user does not let go of the drag inside and exits instead:
- (void) draggingExited:sender {
    
    lastDragged = NSDragOperationNone;
}

// any dragging clean up might be done here
// don't forget to return YES!
- (BOOL) prepareForDragOperation:sender {
    
    return YES;
}

// Actually do the work in this method if it's not too time consuming
// Otherwise, you may consider returning YES, and doing the work
// in concludeDragOperation to prevent the drag from sliding back
// because it "timed out"
- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender {
    
    NSPasteboard *pboard;
    pboard = [sender draggingPasteboard];
        
    NSData* data = [pboard dataForType:XMPasteboardTypeGradient];
    NSGradient * gradient = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    if (gradient) {

        [self setGradient:gradient];
        return YES;
    }
    return NO;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender {

    [self performAction];
}

- (NSUInteger) draggingSourceOperationMaskForLocal: (BOOL)flag {
    
    return NSDragOperationGeneric;
}


@end


#pragma mark -
#pragma mark -
#pragma mark Pasteboard

@implementation XMGradientWell (Pasteboard)

- (NSImage *) dragImage {
            
    NSRect swatchRect = NSMakeRect(0, 0, 12, 12);
    
    NSImage* image = [[NSImage alloc] initWithSize:NSMakeSize(12.0, 12.0)];
    [image lockFocus];
    [self drawWellInside:swatchRect];
    [image unlockFocus];
    
    self.dragImage = image;
    
    return image;
}

- (NSArray *) pasteboardTypes {
    
    return [NSArray arrayWithObjects:
            
            XMPasteboardTypeGradient,
            
            nil];
}

- (NSArray *) writableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *writableTypes = nil;
    
    if (!writableTypes) {
        writableTypes = [[NSArray alloc] initWithObjects:
                         
                         XMPasteboardTypeGradient,
                         
                          nil];
    }
    return writableTypes;
}

- (id) pasteboardPropertyListForType:(NSString *)type {
    
    if ([type isEqualToString:XMPasteboardTypeGradient]) {
        
        return [NSKeyedArchiver archivedDataWithRootObject:_gradient];
    }
    
    return nil;
}

+ (NSArray *) readableTypesForPasteboard:(NSPasteboard *)pasteboard {
    
    static NSArray *readableTypes = nil;
    
    if (!readableTypes) {
        
        readableTypes = [[NSArray alloc] initWithObjects:
                         
                         XMPasteboardTypeGradient,
                         
                         nil];
    }
    return readableTypes;
}

+ (NSPasteboardReadingOptions) readingOptionsForType:(NSString *)type pasteboard:(NSPasteboard *)pboard {
    
    if ([type isEqualToString:XMPasteboardTypeGradient]) {

        return NSPasteboardReadingAsKeyedArchive;
    }
    return 0;
}

@end
