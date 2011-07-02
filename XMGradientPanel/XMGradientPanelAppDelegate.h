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
}

@property (strong) IBOutlet NSWindow *window;

- (IBAction) setGradient:(id)sender;

@end
