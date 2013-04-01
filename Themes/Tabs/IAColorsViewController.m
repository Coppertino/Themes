//
//  IAColorsViewController.m
//  Themes
//
//  Created by Ivan Ablamskyi on 26.03.13.
//  Copyright (c) 2013 Coppertino Inc. All rights reserved.
//

#import "IAColorsViewController.h"

@interface IAColorsViewController ()

@end

@implementation IAColorsViewController
@synthesize contentController = _contentController;
@synthesize tableView = _tableView;

- (NSString *)nibName { return NSStringFromClass(self.class); }
- (NSString *)identifier { return @"colors"; }
- (NSString *)toolbarItemLabel { return @"Colors"; }
- (NSImage *)toolbarItemImage { return [NSImage imageNamed:NSImageNameColorPanel]; }

#pragma mark - TableView delegate
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [tableView makeViewWithIdentifier:@"MainCell" owner:self];
}

@end
