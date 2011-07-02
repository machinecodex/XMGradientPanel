//
//  XMViewControl.h
//  XMGradientPanel
//
//  Created by Alex Clarke on 2/07/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface XMViewControl : NSView {
    
    BOOL					_isEnabled;

    @private
    NSObject *				_target;
    SEL						_action;
}


@property (readwrite, assign) BOOL isEnabled;
@property (readwrite, assign) id target;
@property (readwrite, assign) SEL action;
- (void)performAction;

@end
