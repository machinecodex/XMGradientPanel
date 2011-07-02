//
//  XMGradientPicker.h
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

/* 
 
 This class is based on KTGradientPicker from KTUIKit.
 http://code.google.com/p/ktuikit/
 
*/


#import <Foundation/Foundation.h>
#import "XMViewControl.h"

typedef enum {
    
	kKTGradientPickerMouseDragState_NoDrag = 0,
	kKTGradientPickerMouseDragState_DraggingColorStop
	
} KTGradientPickerMouseDragState;


@interface XMGradientPicker : XMViewControl {
    
    BOOL _doDrawMidline;

    NSGradient *						_gradientValue;
	NSInteger							_activeColorStop;
	BOOL								_removeActiveColorStop;
	KTGradientPickerMouseDragState		_mouseDragState;
}

@property(readwrite,retain) NSGradient * gradientValue;
@property (assign) BOOL doDrawMidline;

@end

@interface XMGradientPicker (Checkerboard)
    
- (void) drawCheckerboardInContext:(CGContextRef)theContext;

@end
