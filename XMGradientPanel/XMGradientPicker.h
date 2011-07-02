//
//  XMGradientPicker.h
//  DateLine 2
//
//  Created by Alex Clarke on 3/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KTGradientPicker.h"

/* Based on KTGradientPicker. We simply rotate the drawing code by 90 degrees, so our picker is
 portrait orientation, and add a midline.
 At some point it would be good to make this a standalone class for independence, to use this we need to include a lot of KTUIKit classes as dependencies.
*/

@interface XMGradientPicker : KTGradientPicker {
    
    BOOL _doDrawMidline;
}

@property (assign) BOOL doDrawMidline;

@end

@interface XMGradientPicker (Checkerboard)
    
- (void) drawCheckersInContext:(CGContextRef)theContext;

@end
