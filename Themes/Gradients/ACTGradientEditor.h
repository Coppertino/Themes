//
//  ACTGradientEditor.h
//  ACTGradientEditor
//
//  Created by Alex on 14/09/2011.
//  Copyright 2011 ACT Productions. All rights reserved.
//  Copyright 2012 Sergio Moura.

#import <Cocoa/Cocoa.h>
#import "NSColor+ChessboardColor.h"

@class ACTGradientEditor;

@protocol ACTGradientEditorDelegate <NSObject>

-(void)GradientEditorChangedGradient:(ACTGradientEditor*)editor;

@end

@interface ACTGradientEditor : NSView {
    @private
    NSInteger _draggingKnobAtIndex;
    NSInteger _editingKnobAtIndex;
}

@property (nonatomic, retain) id<ACTGradientEditorDelegate> delegate;
@property (nonatomic, retain) NSGradient* gradient;
@property (nonatomic, assign) CGFloat gradientHeight; // if (<= 0 || >= [view bounds]) { fill completely the view }

@property (assign) BOOL editable;
@property (nonatomic, assign) BOOL drawsChessboardBackground;

// Not that much functions actually:

// -- only these two everyone knows
- (id)initWithFrame: (NSRect)frame;
- (void)drawRect: (NSRect)dirtyRect;

// -- this method that DWIS (does what it says :) - It's more for subclassing and cleaner code than to be called by others though.
- (void)drawKnobForColor: (NSColor*)knobColor atPoint: (NSPoint)knobPoint selected: (BOOL)selected editing: (BOOL)editing;

// -- and the getters/setters

// For subclassing (why would you do that if you have the code?)
// you have the method drawKnobForColor:atPoint:selected:editing:

@end
