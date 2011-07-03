//
//  XMColorWell.m
//  XMGradientPanel
//
//  Created by Alex Clarke on 2/07/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import "XMColorWell.h"


@implementation XMColorWell

- (void)activate:(BOOL)exclusive
{
	// make NSColorWell slightly more friendly by broadcasting a notificaiton that it is is now active 
	// so that other custom views using the color panel can stop listening to the color changes
	[[NSNotificationCenter defaultCenter] postNotificationName:XMColorWellDidActivateNotification object:self userInfo:nil];
	[super activate:exclusive];
    
}

@end
