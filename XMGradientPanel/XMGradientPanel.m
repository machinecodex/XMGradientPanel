//
//  XMGradientPanel.m
//  DateLine 2
//
//  Created by Alex Clarke on 5/05/11.
//  Copyright 2011 PowerMax. All rights reserved.
//

#import "XMGradientPanel.h"
#import "NSGradient+XMGradients.h"
#import "XMGradientPicker.h"
#import "XMGradientWell.h"
#import "XMDefines.h"

static XMGradientPanel *sharedGradientPanel = nil;

@implementation XMGradientPanel


#pragma mark -
#pragma mark Singleton

+ (void) initialize
{
    if (self == [XMGradientPanel class])
    {
        // Initial version
        [self setVersion: 1];
    }
}

+ (XMGradientPanel *)sharedGradientPanel
{
    if (sharedGradientPanel == nil)
    {
        if (!sharedGradientPanel)
        {
            sharedGradientPanel = [[self alloc] init];
        }
    }
    
    return sharedGradientPanel;
}

+ (BOOL) sharedGradientPanelExists
{
    return (sharedGradientPanel == nil) ? NO : YES;
}


#pragma mark -
#pragma mark Setup

@synthesize picker = _picker;
@synthesize isContinuous = _isContinuous;
@synthesize action = _action;
@synthesize target = _target;
@synthesize gradient = _gradient;
@synthesize splitView;
@synthesize swatchWellsView;
@synthesize swatch;


- (id)init {
    
    self = [super init];
    if (self) {
                
        NSNib *cellNib = [[NSNib alloc] initWithNibNamed:@"GradientPanel" bundle:[NSBundle mainBundle]];
        NSArray *objects = nil;
                
        [cellNib instantiateNibWithOwner:nil topLevelObjects:&objects];
        for(id object in objects) {
            
            if([object isKindOfClass:[self class]]) {
                
                self = object;
                break;
            }
        }
        
        _isContinuous = YES;
        [splitView setDelegate:self];
    }
        
    return self;
}

- (void) setupSwatchWellsInView:(NSView *)aswatchWellsView {    
    
    NSInteger j;
    for (j = 0; j < 2; j++) {
        NSInteger i;
        for (i = 0; i < 10; i++) {
            
            CGFloat width = 16.0, height = width;
            NSRect viewRect = [aswatchWellsView bounds];
            NSRect swatchRect = NSMakeRect(i * width + viewRect.origin.x, 
                                           j * height, width, height);
            
            XMGradientWell * well = [[XMGradientWell alloc] initWithFrame:swatchRect];
            
            [well setGradient:nil];
            [well setIsSwatch:YES];
            [swatchWellsView addSubview: well];
        }
    }
    
    [self restoreGradientWells];
}

- (void) setupSwatch {
    
    [swatch setIsSwatch:YES];
    [swatch setGradient:self.gradient];
}

- (void) awakeFromNib {
        
    [_picker setTarget:self];
    [_picker setAction:@selector(takeValueFromPicker:)];
    
    _picker.gradient = self.gradient;
    
    [self setupSwatch];
    [self setupSwatchWellsInView:self.swatchWellsView];
}

- (void)dealloc
{
    [super dealloc];
}

- (void)performAction
{
	if([_target respondsToSelector:_action])
		[_target performSelector:_action withObject:self];
}

-(void)takeValueFromPicker:(id)gradientPicker {
        
    if (_isContinuous && (_action) && (_target != nil))
        [self performAction];  
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: XMGradientPanelGradientChangedNotification
     object: (id)self];
}

- (void) deactivateOtherWells:(id)sender {
    
    if ([_target respondsToSelector:@selector(deactivateOtherWells:)]) {
        
        [_target deactivateOtherWells:self];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}


#pragma mark -
#pragma mark PasteBoard support

//+ (BOOL) dragGradient: (NSGradient *)aGradient
//         withEvent: (NSEvent *)anEvent
//          fromView: (NSView *)sourceView
//{
//    NSPasteboard	*pb = [NSPasteboard pasteboardWithName: NSDragPboard];
//    NSImage	*image = [NSImage imageNamed: @"common_ColorSwatch"];
//    NSSize	size;
//    NSPoint	point;
//    
//    [pb declareTypes: [NSArray arrayWithObjects: NSColorPboardType, nil]
//               owner: aColor];
//    [aColor writeToPasteboard: pb];
//    [image setBackgroundColor: aColor];
//    
//    size = [image size];
//    point = [sourceView convertPoint: [anEvent locationInWindow] fromView: nil];
//    point.x -= size.width/2;
//    point.y -= size.width/2;
//    
//    [sourceView dragImage: image
//                       at: point
//                   offset: NSMakeSize(0,0)
//                    event: anEvent
//               pasteboard: pb
//                   source: sourceView
//                slideBack: NO];
    
//    return YES;
//}

#pragma mark -
#pragma mark Dynamic Accessors

- (NSGradient *) gradient
{
    return [_picker gradient];
}

- (void) setGradient: (NSGradient *)aGradient {
    
    if (aGradient != _gradient) {
        
        [aGradient retain];
        [_gradient release];
        _gradient = aGradient;
    }
        
    [_picker setGradient:aGradient];
    [swatch setGradient:self.gradient];
    
    if (_isContinuous && (_action) && (_target != nil))
        [self performAction];  
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: XMGradientPanelGradientChangedNotification
     object: (id)self];
}

//- (void) encodeWithCoder: (NSCoder*)aCoder
//{
//    [super encodeWithCoder: aCoder];
//}
//
//- (id) initWithCoder: (NSCoder*)aDecoder
//{
//    [super initWithCoder: aDecoder];
//    
//    return self;
//}


#pragma mark -
#pragma mark SplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)aSplitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex {

//    NSLog(@"[self frame].size.height %f", [self frame].size.height);

    return [self frame].size.height - 48.0 - [aSplitView dividerThickness];
}

- (BOOL)splitView:(NSSplitView *)aSplitView canCollapseSubview:(NSView *)subview {
    
    if (!(subview == [[aSplitView subviews] objectAtIndex:0])) return YES;
    return NO;
}

@end


#pragma mark -
#pragma mark -
#pragma mark Gradient List 

#import "XMApplicationSupport.h"

@implementation XMGradientPanel (GradientWells)

- (NSArray *) defaultGradients {
    
    return [NSArray arrayWithObjects:
            
            [NSGradient glossyGradient],
            [NSGradient redGlossyGradient],
            [NSGradient darkGlossyGradient],
            [NSGradient midGlossyGradient],
            [NSGradient darkSubtleGradient],
            
             nil];
}

- (void) initGradientWells {
    
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [XMApplicationSupport gradientsFilePath];
    
    if (![manager fileExistsAtPath:path]) {
        
        BOOL didSave = [NSKeyedArchiver archiveRootObject:[self defaultGradients] toFile:path];
        if (!didSave) NSLog(@"Error! Could not save gradients to %@", path);
    }
}

- (NSArray * ) gradients {
    
    NSFileManager * manager = [NSFileManager defaultManager];
    NSString * path = [XMApplicationSupport gradientsFilePath];
    
    if (![manager fileExistsAtPath:path]) {
        
        [self initGradientWells];
    }
    
    return [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
}

- (void) setGradients:(NSArray *)gradients {
    
    NSString * path = [XMApplicationSupport gradientsFilePath];
    BOOL didSave = [NSKeyedArchiver archiveRootObject:gradients toFile:path];
    if (!didSave) NSLog(@"Error! Could not save gradients to %@", path);
}

- (NSArray *) gradientWellViews {
    
    return [self.swatchWellsView subviews];
}

- (void) saveGradientWells {
    
    NSMutableArray * result = [NSMutableArray array];
    
    for (id well in [self gradientWellViews]) {
        
        if ([well valueForKey:@"gradient"])
            [result addObject:[well valueForKey:@"gradient"]];
    }

    [self setGradients:result];
}

- (void) restoreGradientWells {
    
    NSInteger i = 0;
    NSArray * gradients = [self gradients];
    
    for (id well in [self gradientWellViews]) {
        
        if (i >= [gradients count]) break;
        
        [well setValue:[gradients objectAtIndex:i] forKey:@"gradient"];
        i++;
    }
}

@end
