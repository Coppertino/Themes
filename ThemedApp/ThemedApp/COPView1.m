//
//  COPView1.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPView1.h"

@implementation COPView1

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
    COPDefaultColors *colors = COPTheme.colors;
    [COPTheme.colors.whiteColor setFill];
    
    [[colors redColor] setFill];
    NSRectFill(dirtyRect);
    
    NSLog(@"colors; %@", [COPTheme.colors allValues]);
}

@end
