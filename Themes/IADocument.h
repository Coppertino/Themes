//
//  IADocument.h
//  Themes
//
//  Created by Ivan Ablamskyi on 22.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "IATabViewController.h"
#import "CPTheme.h"

extern NSString *const kMASPreferencesWindowControllerDidChangeViewNotification;

@interface IADocument : NSDocument <NSToolbarDelegate>

@property (nonatomic, strong) CPTheme *remoteTheme;
@property (nonatomic, strong) NSDictionaryController *contentController;
@property (nonatomic, strong) NSDictionary *classes;

@end
