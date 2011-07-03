//
//  XMGradientPicker.h
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

/* 
 
 This is the abstract superclass for all Gradient Pickers.

 Based on KTGradientPicker from KTUIKit.
 http://code.google.com/p/ktuikit/
  
*/

#import <Foundation/Foundation.h>
#import "XMViewControl.h"

typedef enum {
    
	kXMGradientPickerMouseDragState_NoDrag = 0,
	kXMGradientPickerMouseDragState_DraggingColorStop
	
} XMGradientPickerMouseDragState;


@interface XMGradientPicker : XMViewControl {
    
    NSGradient *						_gradientValue;
	NSInteger							_activeColorStop;
	BOOL								_removeActiveColorStop;
	XMGradientPickerMouseDragState		_mouseDragState;
    
    BOOL _doDrawTickMarks;
    NSInteger _numberOfTickMarks;
}

@property (readwrite,retain) NSGradient * gradientValue;
@property (assign) BOOL doDrawTickMarks;
@property (assign) NSInteger numberOfTickMarks;

@end


#pragma mark -
#pragma mark -

@interface XMGradientPicker (Checkerboard)
    
- (void) drawCheckerboardInContext:(CGContextRef)theContext;

@end
