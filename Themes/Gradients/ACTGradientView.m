//
//  ACTGradientView.m
//  ACTGradientEditor
//
//  Created by Alex on 14/09/2011.
//  Copyright 2011 ACT Productions. All rights reserved.
//  Copyright 2012 Sergio Moura.

#import "ACTGradientView.h"

@implementation ACTGradientView

@synthesize gradient = _gradient;
@synthesize angle = _angle;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame: frame];
    if (self) {
        self.gradient = [[NSGradient alloc] initWithStartingColor: [NSColor whiteColor]
                                                      endingColor: [NSColor blackColor]];
        self.angle = 270;
    }
    
    return self;
}

- (void)drawRect: (NSRect)dirtyRect {
    if (self.gradient) {
        [self.gradient drawInRect: [self bounds] angle: self.angle];
    }
    else {
        NSLog(@"No gradient set up for ACTGradientView: %@", self);
    }
}

- (void)setGradient: (NSGradient*)gr {
    // Not so sure about this as for memory... (let's just say I love Garbage Collection very much :)
    if (![self.gradient isEqualTo:gr]) {
        [_gradient release];
        _gradient = [gr retain];
        
        [self setNeedsDisplay: TRUE];
    }
}

- (void)setAngle: (CGFloat)an {
    if (_angle == an)
        return;
    
    _angle = an;
    [self setNeedsDisplay: TRUE];
}

@end
