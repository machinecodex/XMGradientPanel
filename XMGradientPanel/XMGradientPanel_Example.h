//
//  XMGradientPanel.h
//  DateLine 2
//
//  Created by Alex Clarke on 4/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSView;
//@class NSColorList;
@class NSEvent;

//enum {
//    NSGrayModeColorPanel,
//    NSRGBModeColorPanel,
//    NSCMYKModeColorPanel,
//    NSHSBModeColorPanel,
//    NSCustomPaletteModeColorPanel,
//    NSColorListModeColorPanel,
//    NSWheelModeColorPanel,
//    NSCrayonModeColorPanel 
//};
//
//enum {
//    NSColorPanelGrayModeMask = 1,
//    NSColorPanelRGBModeMask = 2,
//    NSColorPanelCMYKModeMask = 4,
//    NSColorPanelHSBModeMask = 8,
//    NSColorPanelCustomPaletteModeMask = 16,
//    NSColorPanelColorListModeMask = 32,
//    NSColorPanelWheelModeMask = 64,
//    NSColorPanelCrayonModeMask = 128,
//    NSColorPanelAllModesMask = 255
//};

@interface NSApplication (XMGradientPanel_Example)

- (void) orderFrontGradientPanel: (id)sender;

@end


@interface XMGradientPanel_Example : NSPanel
{
    // Attributes
    NSView		*_topView;
    NSColorWell		*_colorWell;
    NSButton		*_magnifyButton;
    NSMatrix		*_pickerMatrix;
    NSBox			*_pickerBox;
    NSSlider		*_alphaSlider;
    NSSplitView		*_splitView;
    NSView		*_accessoryView;
    
    //NSMatrix		*_swatches;
    
    NSMutableArray	*_pickers;
    id<NSColorPickingCustom,NSColorPickingDefault> _currentPicker;
    id			_target;
    SEL			_action;
    BOOL			_isContinuous;
    BOOL                  _showsAlpha;
}

//
// Creating the NSColorPanel 
//
+ (NSColorPanel *)sharedGradientPanel;
+ (BOOL)sharedGradientPanelExists;

//
// Setting the NSColorPanel 
//
//+ (void)setPickerMask:(int)mask;
//+ (void)setPickerMode:(int)mode;
//- (NSView *)accessoryView;
- (BOOL)isContinuous;
//- (int)mode;
- (void)setAccessoryView:(NSView *)aView;
- (void)setAction:(SEL)aSelector;
- (void)setContinuous:(BOOL)flag;
- (void)setMode:(int)mode;
//- (void)setShowsAlpha:(BOOL)flag;
- (void)setTarget:(id)anObject;
//- (BOOL)showsAlpha;

//
// Attaching a Color List
//
- (void)attachColorList:(NSColorList *)aColorList;
- (void)detachColorList:(NSColorList *)aColorList;

//
// Setting Color
//
+ (BOOL)dragColor:(NSColor *)aColor
        withEvent:(NSEvent *)anEvent
         fromView:(NSView *)sourceView;
- (void)setColor:(NSColor *)aColor;

- (float)alpha;
- (NSColor *)color;

@end
//
///* Notifications */
//APPKIT_EXPORT NSString *NSColorPanelColorChangedNotification;
