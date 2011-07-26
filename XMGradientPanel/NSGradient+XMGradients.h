//
//  NSGradient+XMGradients.h
//  DateLine
//
//  Created by Alex Clarke on 10/02/10.
//  Copyright 2010 CocoaLab Software Australia. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "NSGradient+XMUtilities.h"

@interface NSGradient (XMGradients)

+ (NSGradient *) simpleGradient;
+ (NSGradient *) clearGradient;

+ (id) glossyGradient;
+ (id) inverseGlossyGradient;
+ (id) darkGlossyGradient;
+ (id) midGlossyGradient;
+ (id) redGlossyGradient;
+ (id) darkSubtleGradient;
+ (id) spectrumGradient;

+ (id) clockDarkGlossyGradient;
+ (id) codexFloatingWindowTitleGradient;
+ (id) codexFloatingWindowTitleInactiveGradient;

@end
