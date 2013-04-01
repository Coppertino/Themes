//
//  COPAppDelegate.m
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "COPAppDelegate.h"

@implementation COPAppDelegate

+ (NSSet *)keyPathsForValuesAffectingTheme
{
    return [NSSet setWithObjects:@"colors", nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    self.theme = COPTheme;
    [self.theme allowRemoteConnections];
}

@end
