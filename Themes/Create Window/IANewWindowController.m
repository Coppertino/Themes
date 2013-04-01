//
//  IANewWindowController.m
//  Themes
//
//  Created by Ivan Ablamskyi on 29.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "IANewWindowController.h"

@interface IANewWindowController ()

@end

@implementation IANewWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        _apps = [NSMutableDictionary dictionary];
    }
    
    return self;
}

- (NSString *)windowNibName { return NSStringFromClass(self.class); }

- (void)windowDidLoad
{
    [super windowDidLoad];
    [self.indicator startAnimation:self];
//    [NSApp readInBackgroundAndNotifyForModes:[NSRunLoop currentRunLoop]];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.contentController addObserver:self forKeyPath:@"selection" options:NSKeyValueObservingOptionNew context:NULL];
    }];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    NSLog(@"new val: %@", change);
    NSString *newApp = [self.contentController valueForKeyPath:@"selection.key"];
    if (newApp && [newApp isNotEqualTo:NSNoSelectionMarker] && self.action)
    {
        _action(YES, newApp);
//        [NSApp stopModalWithCode:NSOKButton];
        [self.window close];
    }
    
}

- (IBAction)closeWindow:(id)sender;
{
//    [NSApp stopModalWithCode:NSCancelButton];   
    [self.window close];
}

@end
