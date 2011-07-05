//
//  XMGradientPanel.m
//  DateLine 2
//
//  Created by Alex Clarke on 5/05/11.
//  Copyright 2011 MachineCodex Software. All rights reserved.
//

#import "XMGradientPanel.h"
#import "NSGradient+XMGradients.h"
#import "XMGradientPicker.h"
#import "XMGradientWell.h"

static XMGradientPanel *sharedGradientPanel = nil;


@implementation XMGradientPanel

#pragma mark -
#pragma mark Singleton

+ (void)initializeColorPanel {
    
	NSColorPanel * colorPanel = [NSColorPanel sharedColorPanel];
	[colorPanel setShowsAlpha:YES];
}

+ (void) initialize
{
    if (self == [XMGradientPanel class])
    {
        // Initial version
        [self setVersion: 1];
        [self initializeColorPanel];
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

@synthesize picker = _picker;
@synthesize isContinuous = _isContinuous;
@synthesize action = _action;
@synthesize target = _target;
@synthesize gradient = _gradient;
@synthesize splitView;
@synthesize swatchWellsView;
@synthesize previewSwatch;


#pragma mark - Setup

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

- (void) setupPreviewSwatch {
    
    [previewSwatch setIsSwatch:YES];
    [previewSwatch setGradient:self.gradient];
}

- (void) awakeFromNib {
        
    [self setTitle:NSLocalizedString(@"Gradients", NULL)];
    
    [_picker setTarget:self];
    [_picker setAction:@selector(takeValueFromPicker:)];
    
    _picker.gradientValue = self.gradient;
    
    [self setupPreviewSwatch];
    [self setupSwatchWellsInView:self.swatchWellsView];
}

- (void)dealloc
{
    [_picker release]; _picker = nil;
    [_gradient release]; _gradient = nil;
    
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
    
    [previewSwatch setGradient:self.gradient];
}

- (void) deactivateOtherWells:(id)sender {
    
    if ([_target respondsToSelector:@selector(deactivateOtherWells:)]) {
        
        [_target deactivateOtherWells:self];
    }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent {
    
    return YES;
}

- (IBAction) reverseGradient:(id)sender {
    
    NSGradient * reverse = [NSGradient reverseGradient:self.gradient];
    self.gradient = reverse;
}


#pragma mark -
#pragma mark Dynamic Accessors

- (NSGradient *) gradient
{
    return [_picker gradientValue];
}

- (void) setGradient: (NSGradient *)aGradient {
    
    if (aGradient != _gradient) {
        
        [aGradient retain];
        [_gradient release];
        _gradient = aGradient;
    }
        
    [_picker setGradientValue:aGradient];
    [previewSwatch setGradient:self.gradient];
    
    if (_isContinuous && (_action) && (_target != nil))
        [self performAction];  
    
    [[NSNotificationCenter defaultCenter]
     postNotificationName: XMGradientPanelGradientChangedNotification
     object: (id)self];
}


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
#pragma mark - Gradient List 

#import "XMApplicationSupport.h"

@implementation XMGradientPanel (GradientWells)

- (NSArray *) defaultGradients {
    
    return [NSArray arrayWithObjects:
            
            [NSGradient clearGradient],
            [NSGradient simpleGradient],
            [NSGradient spectrumGradient],
            [NSGradient glossyGradient],
            [NSGradient darkGlossyGradient],
            [NSGradient midGlossyGradient],
            [NSGradient darkSubtleGradient],
            [NSGradient redGlossyGradient],
            
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
