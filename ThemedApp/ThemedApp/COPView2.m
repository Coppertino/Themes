//
//  COPView2.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPView2.h"

@implementation COPView2

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    // Drawing code here.
    NSFrameRect(self.bounds);
    NSGradient *g = [COPTheme.gradients valueForKey:_gradient];
    [g drawInRect:self.bounds angle:-90];
    
}

@end
