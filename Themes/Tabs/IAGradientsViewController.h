//
//  IAGradientsViewController.h
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "IATabViewController.h"
#import "ACTGradientEditor.h"
#import "ACTGradientView.h"

@interface IAGradientsViewController : NSViewController <IATabViewController, NSTableViewDataSource, NSTableViewDelegate, ACTGradientEditorDelegate>
{
    IBOutlet __weak NSTableView *_tableView;
    IBOutlet NSDictionaryController *_contentController;
}

@property (weak) IBOutlet NSSearchField *searchField;
@property (weak) IBOutlet ACTGradientEditor *gradientEditor;
@property (weak) IBOutlet ACTGradientView *gradientView;

@end
