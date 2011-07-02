//
//  GradientView.h
//  TechRequest
//
//  Created by Alex Clarke on 10/04/08.
//  Copyright 2008 CocoaLab Software Australia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMGradientView : NSView {
	
	BOOL doesDrawOutline;
	BOOL doesDrawTopBorder;
	BOOL doesDrawBottomBorder;	
	
	NSColor * outlineColor;
	NSColor * topBorderColor;
	NSColor * bottomBorderColor;
	
	NSGradient * gradient;
}

@property (nonatomic, retain) NSColor *outlineColor;
@property (nonatomic, retain) NSColor *bottomBorderColor;
@property (nonatomic, retain) NSColor *topBorderColor;
@property (nonatomic, assign) BOOL doesDrawBottomBorder;
@property (nonatomic, assign) BOOL doesDrawTopBorder;
@property (nonatomic, assign) BOOL doesDrawOutline;
@property (nonatomic, retain) NSGradient *gradient;

@end





