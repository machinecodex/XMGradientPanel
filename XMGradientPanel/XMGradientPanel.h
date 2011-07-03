//
//  XMGradientPanel.h
//  DateLine 2
//
//  Created by Alex Clarke on 5/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XMGradientPicker;
@class XMGradientWell;

@interface XMGradientPanel : NSPanel <NSSplitViewDelegate> {

    XMGradientPicker * _picker;
    NSGradient * _gradient;
    
    NSSplitView * splitView;
    NSView * swatchWellsView;
    XMGradientWell * swatch;
    
    BOOL _isContinuous;
    SEL _action;
    id target;
}

+ (XMGradientPanel *)sharedGradientPanel;
+ (BOOL)sharedGradientPanelExists;

@property (retain) IBOutlet XMGradientPicker * picker;
@property (retain) IBOutlet XMGradientWell * swatch;
@property (assign) IBOutlet NSSplitView * splitView;
@property (assign) IBOutlet NSView * swatchWellsView;
@property (assign) BOOL isContinuous;
@property (assign) SEL action;
@property (assign) id target;
@property (nonatomic, retain) NSGradient * gradient;

- (void) deactivateOtherWells:(id)sender;

@end


#pragma mark -
#pragma mark -
#pragma mark Gradient List 

@interface XMGradientPanel (GradientWells)

- (void) restoreGradientWells;
- (void) saveGradientWells;

@end
