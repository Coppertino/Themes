//
//  IAImagesViewController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IATabViewController.h"

@interface IAImagesViewController : NSViewController <NSTableViewDataSource, NSTableViewDelegate, IATabViewController>
{
    IBOutlet __weak NSTableView *_tableView;
    IBOutlet NSDictionaryController *_contentController;
}

@property (weak) IBOutlet NSImageView *imageView;
@property (weak) IBOutlet NSImageView *retinaImageView;

- (IBAction)updateNormalImage:(id)sender;
- (IBAction)updateRetinaImage:(id)sender;

@end
