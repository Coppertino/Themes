//
//  ACTGradientEditor.m
//  ACTGradientEditor
//
//  Created by Alex on 14/09/2011.
//  Copyright 2011 ACT Productions. All rights reserved.
//  Copyright 2012 Sergio Moura.

#import "ACTGradientEditor.h"
#import "BFColorPickerPopover.h"

// Colors
#define kTopKnobColor [NSColor colorWithCalibratedWhite: 0.95 alpha: 1]
#define kBottomKnobColor [NSColor colorWithCalibratedWhite: 0.6 alpha: 1]
#define kSelectedTopKnobColor [NSColor alternateSelectedControlColor]
#define kSelectedBottomKnobColor [[NSColor alternateSelectedControlColor] shadowWithLevel: 0.35]

#define kKnobBorderColor [[NSColor blackColor] colorWithAlphaComponent: 0.56]
#define kKnobInsideBorderColor [[NSColor blackColor] colorWithAlphaComponent: 0.56]
#define kViewBorderColor [[NSColor blackColor] colorWithAlphaComponent: 0.56]

#define kDefaultAddColor [NSColor whiteColor]

// Chessboard BG
#define kChessboardBGWidth 5
#define kChessboardBGColor1 [NSColor whiteColor]
#define kChessboardBGColor2 [NSColor lightGrayColor]

// Knob
#define kKnobDiameter 16
#define kKnobBorderWidth 1 // inner and outer borders alike

// Gradient 'view'
#define kViewBorderWidth 1
#define kViewCornerRoundness 3
#define kViewXOffset (kKnobDiameter/2 + kKnobBorderWidth) // how much to add to origin.x of the gradient rect

// Other
#define kArrowKeysMoveOffset 0.011 // color location in gradient

static BOOL pointsWithinDistance(NSPoint p1, NSPoint p2, CGFloat d) {
    return pow((p1.x - p2.x), 2) + pow((p1.y - p2.y), 2) <= pow(d, 2); 
}

// ------------

@interface ACTGradientEditor (Private)
- (void)_addColorAtLocation: (CGFloat)colorLocation;
- (void)_setLocation: (CGFloat)newColorLocation forKnobAtIndex: (NSInteger)knobIndex;
- (void)_setColor: (NSColor*)newColor forKnobAtIndex: (NSInteger)knobIndex;
- (void)_deleteColorAtIndex: (NSInteger)knobIndex;

- (void)_setGradientWarningTarget: (NSGradient*)gr;

- (NSRect)_gradientBounds;
- (NSPoint)_viewPointFromGradientLocation: (CGFloat)location;
- (CGFloat)_gradientLocationFromViewPoint: (NSPoint)point;

- (void)propagateValue:(id)value forBinding:(NSString*)binding;
@end

// ------------

@implementation ACTGradientEditor

@synthesize delegate = _delegate;
@synthesize gradient = _gradient;
@synthesize editable = _editable;
@synthesize gradientHeight = _gradientHeight;
@synthesize drawsChessboardBackground = _drawsChessboardBackground;

- (id)initWithFrame: (NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _gradient = [[NSGradient alloc] initWithColorsAndLocations: [NSColor lightGrayColor], 0.2, [NSColor grayColor], 0.8, nil];
        _editable = TRUE;
        _gradientHeight = kKnobDiameter + kKnobBorderWidth + 6;
        _drawsChessboardBackground = YES;
        
        _draggingKnobAtIndex = -1;
        _editingKnobAtIndex = -1;
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(windowWillClose:) 
                                                     name:@"NSWindowWillCloseNotification" 
                                                   object:nil];
    }
    
    return self;
}

- (void)drawRect: (NSRect)dirtyRect {
    [NSGraphicsContext saveGraphicsState];

    NSRect viewRect = [self _gradientBounds];
    
    NSBezierPath* viewOutline = [NSBezierPath bezierPathWithRoundedRect: viewRect xRadius: kViewCornerRoundness yRadius: kViewCornerRoundness];
    [viewOutline setLineWidth: kViewBorderWidth];
    
    // DRAW BG
    if (self.drawsChessboardBackground) {
        NSColor* bgColor = [NSColor chessboardColorWithFirstColor: kChessboardBGColor1 secondColor: kChessboardBGColor2 squareWidth: kChessboardBGWidth];
        [bgColor set];
        [viewOutline fill];
    }
    
    // DRAW GRADIENT AREA
    [self.gradient drawInBezierPath: viewOutline angle: 0];
    
    // DRAW VIEW BORDER
    [kViewBorderColor set];
    [viewOutline stroke];
    
    // DRAW KNOBS
    int i;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: i];
        
        // These are drwan in the end so they are always above the others
        if (i == _draggingKnobAtIndex || i == _editingKnobAtIndex) { continue; }
        
        [self drawKnobForColor: color atPoint: [self _viewPointFromGradientLocation: location]
                      selected: _draggingKnobAtIndex == i editing: _editingKnobAtIndex == i];
    }
    
    if (_editingKnobAtIndex > -1) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: _editingKnobAtIndex];
        [self drawKnobForColor: color
                       atPoint: [self _viewPointFromGradientLocation: location]
                      selected: _draggingKnobAtIndex == _editingKnobAtIndex
                       editing: YES];
    }
    
    if (_draggingKnobAtIndex > -1 && _draggingKnobAtIndex != _editingKnobAtIndex) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: _draggingKnobAtIndex];
        [self drawKnobForColor: color
                       atPoint: [self _viewPointFromGradientLocation: location]
                      selected: YES
                       editing: NO];
    }
    
    [NSGraphicsContext restoreGraphicsState];
}
- (void)drawKnobForColor: (NSColor*)knobColor atPoint: (NSPoint)knobPoint selected: (BOOL)selected editing: (BOOL)editing
{
    CGFloat knobSize = kKnobDiameter;
    CGFloat angle = selected ? 90 : 270;
    
    // PATHS
    NSBezierPath* outline = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(knobPoint.x - knobSize / 2, knobPoint.y - knobSize / 2, knobSize, knobSize)];
    NSBezierPath* color = [NSBezierPath bezierPathWithOvalInRect: NSMakeRect(knobPoint.x - knobSize / 4, knobPoint.y - knobSize / 4, knobSize / 2, knobSize / 2)];
    [outline setWindingRule: NSEvenOddWindingRule];
    [outline setLineWidth: kKnobBorderWidth];
    [color setLineWidth: kKnobBorderWidth];
    [outline appendBezierPath: color];
    
    // SHADOW
    /*NSShadow* theShadow = [[NSShadow alloc] init];
    [theShadow setShadowOffset: NSZeroSize];
    [theShadow setShadowBlurRadius: 5.0];
    [theShadow setShadowColor: [[NSColor blackColor] colorWithAlphaComponent: 0.4]];
    [theShadow set];*/
    
    // DRAW BG
    NSGradient* bgKnobGr;
    if (editing) {
        bgKnobGr = [[NSGradient alloc] initWithStartingColor: kSelectedTopKnobColor endingColor: kSelectedBottomKnobColor];
    }
    else {
        bgKnobGr = [[NSGradient alloc] initWithStartingColor: kTopKnobColor endingColor: kBottomKnobColor];
    }
    
    [bgKnobGr drawInBezierPath: outline angle: angle];
    [kKnobBorderColor set];
    [outline stroke];
    
    //[theShadow setShadowColor: [NSColor clearColor]];
    
    // DRAW COLOR
    [knobColor set];
    [color fill];
    [kKnobInsideBorderColor set];
    [color stroke];
}

- (void)_addColorAtLocation: (CGFloat)colorLocation
{
    CGFloat editingColorLocation;
    if (_editingKnobAtIndex > -1) {
        [self.gradient getColor: nil location: &editingColorLocation atIndex: _editingKnobAtIndex];
    }
    
    NSMutableArray* newColors = [NSMutableArray arrayWithCapacity: [self.gradient numberOfColorStops] + 1];
    CGFloat locations[[self.gradient numberOfColorStops] + 1];
    
    int i;
    int colorIndex = -1;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: i];
        [newColors addObject: color];
        locations[i] = location;
        
        if (colorLocation < location && colorIndex == -1) {
            colorIndex = MAX(i - 1, 0);
        }
    }
    
    [newColors addObject: kDefaultAddColor];
    locations[[self.gradient numberOfColorStops]] = colorLocation;
    if (colorIndex == -1) { colorIndex = (int)[self.gradient numberOfColorStops] + 1; }
    
    if ((colorIndex < _editingKnobAtIndex) || (colorIndex == 0 && _editingKnobAtIndex == 0 && colorLocation < editingColorLocation)) {
        _editingKnobAtIndex++;
        [self setNeedsDisplay: YES];
    }
    if ((colorIndex < _draggingKnobAtIndex) || (colorIndex == 0 && _draggingKnobAtIndex == 0 && colorLocation < editingColorLocation)) {
        _draggingKnobAtIndex++;
        [self setNeedsDisplay: YES];
    }
    
    self.gradient = [[NSGradient alloc] initWithColors: newColors atLocations: locations colorSpace: [NSColorSpace genericRGBColorSpace]];
}
- (void)_setLocation: (CGFloat)newColorLocation forKnobAtIndex: (NSInteger)knobIndex
{
    CGFloat oldColorLocation;
    [self.gradient getColor: nil location: &oldColorLocation atIndex: knobIndex];
        
    CGFloat editingColorLocation;
    if (_editingKnobAtIndex > -1) {
        [self.gradient getColor: nil location: &editingColorLocation atIndex: _editingKnobAtIndex];
    }
        
    // Placeholders for new values
    NSMutableArray* newColors = [NSMutableArray arrayWithCapacity: [self.gradient numberOfColorStops]];
    CGFloat locations[[self.gradient numberOfColorStops]];
    
    // Check for this color passing other colors (to change _dragging)
    int i;
    int nColorsPassed = 0;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        CGFloat location;
        [self.gradient getColor: nil location: &location atIndex: i];
                
        // Shouldn't compare the dragged color with itself
        if (i == knobIndex) { continue; }
        
        if (oldColorLocation < location && location <= newColorLocation) {
            nColorsPassed++;
        }
        else if (newColorLocation <= location && location < oldColorLocation) {
            nColorsPassed--;
        }
        
        if (location == newColorLocation) {
            // Add (or subtract depending on movement direction) just a tad to make sure the changed color is after the other color
            // since we are adding 1 to _currentlyDraggingKnobAtIndex
            if (oldColorLocation < newColorLocation) { newColorLocation += 0.01; } // Going ->
            else { newColorLocation -= 0.01; } // <-
        }
    }
    
    // Check if we moved the color to before or after _editing
    int editingIndexOffset = 0;
    if (knobIndex == _editingKnobAtIndex) {
        editingIndexOffset = nColorsPassed;
    }
    else {
        if (oldColorLocation < editingColorLocation && editingColorLocation < newColorLocation) {
            editingIndexOffset--;
        }
        else if (oldColorLocation > editingColorLocation && editingColorLocation > newColorLocation) {
            editingIndexOffset++;
        }
    }
    
    // Check boundaries
    if (newColorLocation > 1) { newColorLocation = 1; }
    if (newColorLocation < 0) { newColorLocation = 0; }
    
    // Rebuild gradient with new color location
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        NSColor* color;
        CGFloat location;
                
        [self.gradient getColor: &color location: &location atIndex: i];
        
        [newColors addObject: color];
        
        if (knobIndex == i) { locations[i] = newColorLocation; }
        else { locations[i] = location; }
    }
    
    // So we continue dragging the same color (and editing if we are editing any color)
    _editingKnobAtIndex += editingIndexOffset;
    _draggingKnobAtIndex += nColorsPassed;
    
    self.gradient = [[NSGradient alloc] initWithColors: newColors atLocations: locations colorSpace: [NSColorSpace genericRGBColorSpace]];
}
- (void)_setColor: (NSColor*)newColor forKnobAtIndex: (NSInteger)knobIndex
{
    NSMutableArray* newColors = [NSMutableArray arrayWithCapacity: [self.gradient numberOfColorStops]];
    CGFloat locations[[self.gradient numberOfColorStops]];
    
    int i;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: i];
        
        if (knobIndex == i) {
            [newColors addObject: newColor];
        }
        else {
            [newColors addObject: color];
        }
        
        locations[i] = location;
    }
    
    self.gradient = [[NSGradient alloc] initWithColors: newColors atLocations: locations colorSpace: [NSColorSpace genericRGBColorSpace]];
}
- (void)_deleteColorAtIndex: (NSInteger)colorIndex
{
    if (!([self.gradient numberOfColorStops] > 2)) { return; }
    
    NSMutableArray* newColors = [NSMutableArray arrayWithCapacity: [self.gradient numberOfColorStops] - 1];
    CGFloat locations[[self.gradient numberOfColorStops] - 1];
    
    int i;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        NSColor* color;
        CGFloat location;
        [self.gradient getColor: &color location: &location atIndex: i];
        
        if (colorIndex != i) {
            [newColors addObject: color];
            locations[[newColors count] - 1] = location;
        }
    }
    
    if (colorIndex < _editingKnobAtIndex) { _editingKnobAtIndex--; [self setNeedsDisplay: YES]; }
    else if (colorIndex == _editingKnobAtIndex) { _editingKnobAtIndex = -1; }
    
    if (colorIndex < _draggingKnobAtIndex) { _draggingKnobAtIndex--; [self setNeedsDisplay: YES]; }
    else if (colorIndex == _draggingKnobAtIndex) { _draggingKnobAtIndex = -1; }
    
    self.gradient = [[NSGradient alloc] initWithColors: newColors atLocations: locations colorSpace: [self.gradient colorSpace]];
}

- (void)mouseDown: (NSEvent*)theEvent {
    if (!self.editable) { return; }
    
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];
    
    int i;
    for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
        CGFloat location;
        [self.gradient getColor: nil location: &location atIndex: i];
                
        if (pointsWithinDistance([self _viewPointFromGradientLocation: location], mouseLocation, kKnobDiameter)) {
            _draggingKnobAtIndex = i;
        }
    }
    
    [self setNeedsDisplay: TRUE];
}
- (void)mouseDragged: (NSEvent*)theEvent
{
    if (!self.editable) { return; }
    if (_draggingKnobAtIndex == -1) { return; }
    
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];
        
    [self _setLocation: [self _gradientLocationFromViewPoint: mouseLocation] forKnobAtIndex: _draggingKnobAtIndex];
    [self _setGradientWarningTarget: self.gradient];
    [self setNeedsDisplay: TRUE];
    
    // Check for being outside gradient bounds. If so then change the cursor
    int gHeight = [self _gradientBounds].size.height;
    int outBoundTop = ([self bounds].size.height + gHeight) / 2;
    int outBoundBottom = ([self bounds].size.height - gHeight) / 2;
    if ((mouseLocation.y > outBoundTop || mouseLocation.y < outBoundBottom) && [self.gradient numberOfColorStops] > 2) {
        [[NSCursor disappearingItemCursor] set];
    }
    else {
        [[NSCursor arrowCursor] set];
    }
}

- (void)mouseUp: (NSEvent*)theEvent {
    if (!self.editable) { return; }
    
    NSPoint mouseLocation = [theEvent locationInWindow];
    mouseLocation = [self convertPoint: mouseLocation fromView: nil];
    
    if ([theEvent clickCount] == 2) {
        int i;
        BOOL addKnob = YES;
        for (i = 0; i < [self.gradient numberOfColorStops]; i++) {
            NSColor* color;
            CGFloat location;
            [self.gradient getColor: &color location: &location atIndex: i];
            
            if (pointsWithinDistance([self _viewPointFromGradientLocation: location], mouseLocation, kKnobDiameter)) {
                _editingKnobAtIndex = i;
                addKnob = NO;
                
                BFColorPickerPopover *colorPopover = [BFColorPickerPopover sharedPopover];
                colorPopover.color = color;
                colorPopover.target = self;
                colorPopover.action = @selector(changeKnobColor:);
                [colorPopover showRelativeToRect:(NSRect){mouseLocation, NSZeroSize} ofView:self preferredEdge:CGRectMaxXEdge];
                
            }
        }
        
        if (addKnob) {
            CGFloat colorLocation = [self _gradientLocationFromViewPoint: mouseLocation];
            [self _addColorAtLocation: colorLocation];
            [self _setGradientWarningTarget: self.gradient];
        }
    }
    else if (_draggingKnobAtIndex != -1) {
        int gHeight = [self _gradientBounds].size.height;
        int outBoundTop = ([self bounds].size.height + gHeight) / 2;
        int outBoundBottom = ([self bounds].size.height - gHeight) / 2;
        
        if ((mouseLocation.y > outBoundTop || mouseLocation.y < outBoundBottom) && [self.gradient numberOfColorStops] > 2) {
            //[NSClassFromString(@"NSToolbarPoofAnimator") runPoofAtPoint: [NSEvent mouseLocation]]; // !!! UNDOCUMENTED -> USE WITH CAUTION!
            
            [self _deleteColorAtIndex: _draggingKnobAtIndex];
            [self _setGradientWarningTarget: self.gradient];
        }
        
        [[NSCursor arrowCursor] set];
    }
    
    _draggingKnobAtIndex = -1;
    [self setNeedsDisplay: TRUE];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}
- (void)keyDown: (NSEvent*)theEvent
{
    if (!(self.editable && _editingKnobAtIndex != -1)) { return; }
    
    if ([theEvent modifierFlags] & NSNumericPadKeyMask) {
        [self interpretKeyEvents: [NSArray arrayWithObject: theEvent]];
    }
    else if ([[theEvent charactersIgnoringModifiers] characterAtIndex: 0] == NSDeleteCharacter) {
        [self deleteBackward: self];
    }
    else {
        [super keyDown: theEvent];
    }
}
- (IBAction)moveLeft: (id)sender
{
    CGFloat location;
    [self.gradient getColor: nil location: &location atIndex: _editingKnobAtIndex];
    
    [self _setLocation: MAX(location - kArrowKeysMoveOffset, 0) forKnobAtIndex: _editingKnobAtIndex];
    [self _setGradientWarningTarget: self.gradient];
    [self setNeedsDisplay: TRUE];
}
- (IBAction)moveRight: (id)sender
{
    CGFloat location;
    [self.gradient getColor: nil location: &location atIndex: _editingKnobAtIndex];

    [self _setLocation: MIN(location + kArrowKeysMoveOffset, 1) forKnobAtIndex: _editingKnobAtIndex];
    [self _setGradientWarningTarget: self.gradient];
    [self setNeedsDisplay: TRUE];
}
- (IBAction)deleteBackward: (id)sender
{
    [self _deleteColorAtIndex: _editingKnobAtIndex];
    [self _setGradientWarningTarget: self.gradient];
    [self setNeedsDisplay: YES];
}

- (void)changeKnobColor: (id)sender
{
    if (_editingKnobAtIndex != -1) {
        [self _setColor: [sender color] forKnobAtIndex: _editingKnobAtIndex];
        [self _setGradientWarningTarget: self.gradient];
        [self setNeedsDisplay: TRUE];
    }
}
- (void)windowWillClose: (NSNotification*)aNot
{
    if ([[aNot object] isKindOfClass:[NSColorPanel class]]) {
        //[aNot object] == [NSColorPanel sharedColorPanel]) {
        if (_editingKnobAtIndex != -1) {
            _editingKnobAtIndex = -1;
            [self setNeedsDisplay: TRUE];
        }
    }
}

- (void)setGradient: (NSGradient*)gr {
    if (![self.gradient isEqualTo:gr]) {
        [_gradient release];
        _gradient = [gr retain];
        
        [self setNeedsDisplay: TRUE];
    }
}
- (void)setGradientHeight: (CGFloat)h {
    if (_gradientHeight == h)
        return;
    _gradientHeight = h;
    [self setNeedsDisplay: TRUE];
}

- (void)setDrawsChessboardBackground: (BOOL)v {
    if (_drawsChessboardBackground == v)
        return;
    
    _drawsChessboardBackground = v;
    [self setNeedsDisplay: TRUE];
}

- (void)_setGradientWarningTarget: (NSGradient*)gr {
    self.gradient = gr;

    if (self.delegate) {
        [self.delegate GradientEditorChangedGradient:self];
    }
    
    [self propagateValue:self.gradient forBinding:@"gradient"];
}

- (NSRect)_gradientBounds {
    NSRect viewRect = [self bounds];
    viewRect.origin.x += kViewXOffset;
    viewRect.size.width -= kViewXOffset * 2;
    
    if (_gradientHeight > 0 && _gradientHeight < [self bounds].size.height) {
        viewRect.size.height = _gradientHeight;
        viewRect.origin.y += ([self bounds].size.height - _gradientHeight) / 2;
    }
    
    return viewRect;
}
- (NSPoint)_viewPointFromGradientLocation: (CGFloat)location {
    return NSMakePoint(location * [self _gradientBounds].size.width + kViewXOffset, [self bounds].size.height / 2);
}

- (CGFloat)_gradientLocationFromViewPoint: (NSPoint)point {
    return((point.x - kViewXOffset) / [self _gradientBounds].size.width);
}

#pragma mark - Bindings functionality

+ (void)initialize {
    [self exposeBinding:@"gradient"];
}

- (Class)valueClassForBinding:(NSString *)binding {
    if ([binding isEqualToString:@"gradient"]) {
        return([NSGradient class]);
    }

    return(nil);
}

- (NSArray*)exposedBindings {
    return([NSArray arrayWithObjects:@"gradient",nil]);
}

- (void)propagateValue:(id)value forBinding:(NSString*)binding {
    // Kindly borrowed from tomdalling at http://www.tomdalling.com/blog/cocoa/implementing-your-own-cocoa-bindings
    NSParameterAssert(binding != nil);
    
    NSDictionary *bindingInfo = [self infoForBinding:binding];
    if (!bindingInfo)
        return;
    
    NSDictionary *bindingOptions = [bindingInfo objectForKey:NSOptionsKey];
    if (bindingOptions) {
        NSValueTransformer *transformer = [bindingOptions valueForKey:NSValueTransformerBindingOption];
        if (!transformer || (id)transformer == [NSNull null]) {
            NSString *transformerName = [bindingOptions valueForKey:NSValueTransformerBindingOption];
            if (transformerName && (id)transformerName != [NSNull null]) {
                transformer = [NSValueTransformer valueTransformerForName:transformerName];
            }
        }
        
        if (transformer && (id)transformer != [NSNull null]) {
            if ([[transformer class] allowsReverseTransformation]) {
                value = [transformer reverseTransformedValue:value];
            }
            else {
                NSLog(@"WARNING: binding\"%@\" has value transformer, but it doesn't allow reverse transformations in %s", binding, __PRETTY_FUNCTION__);
            }
        }
    }
    
    id boundObject = [bindingInfo objectForKey:NSObservedObjectKey];
    if (!boundObject || boundObject == [NSNull null]) {
        NSLog(@"ERROR: NSObservedObjectKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }
    
    NSString *boundKeyPath = [bindingInfo objectForKey:NSObservedKeyPathKey];
    if (!boundKeyPath || (id)boundKeyPath == [NSNull null]) {
        NSLog(@"ERROR: NSObservedKeyPathKey was nil for binding \"%@\" in %s", binding, __PRETTY_FUNCTION__);
        return;
    }
    
    [boundObject setValue:value forKeyPath:boundKeyPath];
}

@end
