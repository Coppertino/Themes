//
//  COPAppDelegate.h
//  ThemedApp
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "COPDefaultTheme.h"

@interface COPAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (strong) COPDefaultTheme *theme;

@end
