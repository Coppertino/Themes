//
//  COPDefaultGradients.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPDefaultGradients.h"

@implementation COPDefaultGradients

- (NSGradient *)grad0
{
    return [[NSGradient alloc] initWithColors:@[[NSColor whiteColor], [NSColor yellowColor]]];
}

- (NSGradient *)grad1
{
    return [[NSGradient alloc] initWithColors:@[[NSColor greenColor], [NSColor purpleColor]]];
}

@end
