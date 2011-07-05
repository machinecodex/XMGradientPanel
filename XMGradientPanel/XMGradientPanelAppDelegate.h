//
//  XMGradientPanelAppDelegate.h
//  XMGradientPanel
//
//  Created by Alex Clarke on 2/07/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class XMGradientView;
@class XMGradientWell;

@interface XMGradientPanelAppDelegate : NSObject <NSApplicationDelegate> {

    NSWindow *_window;
    
    IBOutlet XMGradientView * gradientView;
    IBOutlet XMGradientWell * gradientWell;
    IBOutlet NSMatrix * gradientTypeMatrix;
}

@property (retain) IBOutlet NSWindow *window;

- (IBAction) setGradient:(id)sender;
- (IBAction) setGradientAngle:(id)sender;
- (IBAction) setGradientType:(id)sender;

- (NSInteger) gradientType;

@end
