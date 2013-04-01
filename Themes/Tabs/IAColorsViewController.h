//
//  IAColorsViewController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IATabViewController.h"

@interface IAColorsViewController : NSViewController <NSTableViewDelegate, IATabViewController>
{
    IBOutlet __weak NSTableView *_tableView;
    IBOutlet NSDictionaryController *_contentController;
}

@end
