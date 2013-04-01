//
//  IADocumentWindowController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 29.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IATabViewController.h"

@interface IADocumentWindowController : NSWindowController

@property (nonatomic, strong) NSViewController <IATabViewController> *selectedViewController;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *viewControllers;
@property (assign) IBOutlet NSPopUpButton *themeSelectionButton;
@property (strong) IBOutlet NSView *statusView;
@property (strong) NSString *application;

@property (nonatomic, strong) IBOutlet NSDictionaryController *contentController;

- (id)initWithViewControllers:(NSArray *)viewControllers;
- (id)initWithViewControllers:(NSArray *)viewControllers title:(NSString *)title;

@end
