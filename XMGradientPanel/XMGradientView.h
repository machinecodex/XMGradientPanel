//
//  GradientView.h
//  TechRequest
//
//  Created by Alex Clarke on 10/04/08.
//  Copyright 2008 CocoaLab Software Australia. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMGradientView : NSView {
	
	BOOL _doesDrawOutline;
	BOOL _doesDrawTopBorder;
	BOOL _doesDrawBottomBorder;	
	BOOL _doesDrawLeftBorder;
	BOOL _doesDrawRightBorder;	
	
	NSColor * _outlineColor;
	
	NSGradient * _gradient;
    CGFloat _gradientAngle;
}

@property (nonatomic, assign) BOOL doesDrawOutline;
@property (nonatomic, assign) BOOL doesDrawTopBorder;
@property (nonatomic, assign) BOOL doesDrawBottomBorder;
@property (nonatomic, assign) BOOL doesDrawLeftBorder;
@property (nonatomic, assign) BOOL doesDrawRightBorder;

@property (nonatomic, retain) NSColor *outlineColor;

@property (nonatomic, retain) NSGradient *gradient;
@property (assign) CGFloat gradientAngle;

@end





