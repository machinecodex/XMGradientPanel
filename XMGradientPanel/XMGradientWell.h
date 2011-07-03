//
//  XMGradientWell.h
//  DateLine 2
//
//  Created by Alex Clarke on 4/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class NSColor;
@class NSGradient;
@class XMGradientPanel;

@interface XMGradientWell : NSControl  <NSCoding, NSWindowDelegate> {

    XMGradientPanel *panel;
    NSGradient *_gradient;
	SEL _action;
	id _target;
    
    BOOL _isActive;
    BOOL _isBordered;
    BOOL _isSwatch;
        
    BOOL badSelection;
    BOOL multipleSelection;
    
    NSUInteger lastDragged;
    NSImage * _dragImage;
}

@property (assign) SEL action;
@property (assign) id target;
@property (assign) BOOL isActive;
@property (assign) BOOL isBordered;
@property (assign) BOOL isSwatch;


@property (retain) NSImage * dragImage;

- (void) activate:(BOOL)exclusive;
- (void) deactivate;
- (void) deactivateOtherWells:(id)sender;

- (BOOL) isActive;
- (BOOL) isBordered;
- (void) setIsBordered:(BOOL)bordered;

- (NSGradient *) gradient;
- (void) setGradient:(NSGradient *) gradient;
- (void) takeGradientFrom:(id) sender;

- (void) drawWellInside:(NSRect) insideRect;

- (NSArray *)exposedBindings;

@end


#pragma mark -
#pragma mark -
#pragma mark Pasteboard 

@interface XMGradientWell (Pasteboard) <NSPasteboardWriting, NSPasteboardReading> 

- (NSImage *) dragImage;

- (NSArray *) pasteboardTypes;

- (NSArray *) writableTypesForPasteboard:(NSPasteboard *)pasteboard;
- (id) pasteboardPropertyListForType:(NSString *)type;

+ (NSArray *)readableTypesForPasteboard:(NSPasteboard *)pasteboard;


@end
