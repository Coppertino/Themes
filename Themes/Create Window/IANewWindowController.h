//
//  IANewWindowController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 29.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef void (^newWindowAction)(BOOL haveApplication, NSString *bundleId);

@interface IANewWindowController : NSWindowController
@property (weak) IBOutlet NSProgressIndicator *indicator;
@property (strong) IBOutlet NSDictionaryController *contentController;
@property (nonatomic, strong) NSMutableDictionary *apps;
@property (copy) newWindowAction action;

- (IBAction)closeWindow:(id)sender;


@end
