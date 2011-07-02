//
//  XMGradientPicker.h
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTGradientPicker.h"

// Simply rotate the drawing code by 90 degrees, so our picker is portrait

@interface XMGradientPicker : KTGradientPicker {
    
    BOOL _doDrawMidline;
}

@property (assign) BOOL doDrawMidline;

@end

@interface XMGradientPicker (Checkerboard)
    
- (void) drawCheckersInContext:(CGContextRef)theContext;

@end
