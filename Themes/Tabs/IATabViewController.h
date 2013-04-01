//
//  IATabViewController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IATabViewController <NSObject>
@optional

- (void)viewWillAppear;
- (void)viewDidDisappear;
- (NSView*)initialKeyView;

@required
@property (nonatomic, readonly) NSString *identifier;
@property (nonatomic, readonly) NSImage *toolbarItemImage;
@property (nonatomic, readonly) NSString *toolbarItemLabel;

@property (nonatomic, strong) IBOutlet NSDictionaryController *contentController;
@property (weak) IBOutlet NSTableView *tableView;

@end
