//
//  XMGradientPanelAppDelegate.m
//  XMGradientPanel
//
//  Created by Alex Clarke on 2/07/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMGradientPanelAppDelegate.h"
#import "NSGradient+XMGradients.h"

#import "XMGradientView.h"
#import "XMGradientWell.h"

@implementation XMGradientPanelAppDelegate

@synthesize window = _window;

- (void) applicationDidFinishLaunching:(NSNotification *)aNotification {

    [gradientWell setGradient:[NSGradient spectrumGradient]];
    
    [gradientWell setTarget:self];
    [gradientWell setAction:@selector(setGradient:)];
    
    [gradientTypeMatrix selectCellWithTag:[self gradientType]];
    
    [gradientWell performSelector:@selector(activatePanel)];
}

- (BOOL) applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    
	return YES;
}

- (IBAction) setGradient:(id)sender {
    
    [gradientView setGradient:[sender gradient]];
}

- (IBAction) setGradientAngle:(id)sender {

    [gradientView setGradientAngle:[sender doubleValue]];
}

- (IBAction) setGradientType:(id)sender {
    
    [gradientView setGradientType:[[sender selectedCell] tag]];
}

- (NSInteger) gradientType {
    
    return [gradientView gradientType];
}


@end
